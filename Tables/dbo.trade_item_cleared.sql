CREATE TABLE [dbo].[trade_item_cleared]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[contr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lot_quantity] [decimal] (20, 8) NULL,
[clr_brkr_num] [int] NULL,
[contr_price] [decimal] (20, 8) NULL,
[contr_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_cleared_deltrg]
on [dbo].[trade_item_cleared]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(trade_item_cleared) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_trade_item_cleared
(  
   trade_num,
   order_num,
   item_num,
   contr_code,
   contr_period,
   clr_mkt_code,
   p_s_ind,
   lot_quantity,
   clr_brkr_num,
   contr_price,
   contr_price_curr_code,
   trans_id,
   resp_trans_id
)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.contr_code,
   d.contr_period,
   d.clr_mkt_code,
   d.p_s_ind,
   d.lot_quantity,
   d.clr_brkr_num,
   d.contr_price,
   d.contr_price_curr_code,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_cleared_updtrg]
on [dbo].[trade_item_cleared]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id)
begin
   raiserror ('(trade_item_cleared) The change needs to be attached with a new trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(trade_item_cleared) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and
                 i.order_num = d.order_num and
		             i.item_num = d.item_num)
begin
   select @errmsg = '(trade_item_cleared) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.trade_num) + ',' + convert(varchar, i.order_num) + ',' + + convert(varchar, i.item_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(trade_num) or
   update(order_num) or
   update(item_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and
                                   i.order_num = d.order_num and
				                           i.item_num = d.item_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_item_cleared) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_trade_item_cleared
     (trade_num,
      order_num,
      item_num,
      contr_code,
      contr_period,
      clr_mkt_code,
      p_s_ind,
      lot_quantity,
      clr_brkr_num,
      contr_price,
      contr_price_curr_code,
      trans_id,
      resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.contr_code,
      d.contr_period,
      d.clr_mkt_code,
      d.p_s_ind,
      d.lot_quantity,
      d.clr_brkr_num,
      d.contr_price,
      d.contr_price_curr_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
	       d.item_num = i.item_num

return
GO
ALTER TABLE [dbo].[trade_item_cleared] ADD CONSTRAINT [trade_item_cleared_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_cleared] ADD CONSTRAINT [trade_item_cleared_fk1] FOREIGN KEY ([contr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_cleared] ADD CONSTRAINT [trade_item_cleared_fk2] FOREIGN KEY ([clr_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[trade_item_cleared] ADD CONSTRAINT [trade_item_cleared_fk3] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item_cleared] ADD CONSTRAINT [trade_item_cleared_fk4] FOREIGN KEY ([contr_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[trade_item_cleared] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_cleared] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_cleared] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_cleared] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_cleared', NULL, NULL
GO

CREATE TABLE [dbo].[trade_item_pl]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[mtm_pl] [float] NULL,
[mtm_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_asof_date] [datetime] NULL,
[contr_mtm_pl] [float] NULL,
[addl_cost_sum] [float] NULL,
[trans_id] [int] NOT NULL,
[price_fx_rate] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_pl_deltrg]
on [dbo].[trade_item_pl]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(trade_item_pl) Failed to obtain a valid responsible trans_id. '
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_trade_item_pl
   (trade_num,
    order_num,
    item_num,
    mtm_pl,	
    mtm_pl_curr_code,
    pl_asof_date,
    contr_mtm_pl,
    addl_cost_sum,
    price_fx_rate,   
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.mtm_pl,	
   d.mtm_pl_curr_code,
   d.pl_asof_date,
   d.contr_mtm_pl,
   d.addl_cost_sum,
   d.price_fx_rate,  
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_pl_updtrg]
on [dbo].[trade_item_pl]
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
   raiserror ('(trade_item_pl) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_item_pl) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(trade_item_pl) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.trade_num) + ',' + 
                                        convert(varchar, i.order_num) + ',' + 
                                        convert(varchar, i.item_num) + ')'
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
      raiserror ('(trade_item_pl) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_pl
      (trade_num,
       order_num,
       item_num,
       mtm_pl,	
       mtm_pl_curr_code,
       pl_asof_date,
       contr_mtm_pl,
       addl_cost_sum,
       price_fx_rate,       
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.mtm_pl,	
      d.mtm_pl_curr_code,
      d.pl_asof_date,
      d.contr_mtm_pl,
      d.addl_cost_sum,
      d.price_fx_rate,      
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and 
         d.item_num = i.item_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[trade_item_pl] ADD CONSTRAINT [trade_item_pl_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_pl] ADD CONSTRAINT [trade_item_pl_fk2] FOREIGN KEY ([mtm_pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[trade_item_pl] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_pl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_pl] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_pl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_pl', NULL, NULL
GO

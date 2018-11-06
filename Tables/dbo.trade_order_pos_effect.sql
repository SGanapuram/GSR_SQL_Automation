CREATE TABLE [dbo].[trade_order_pos_effect]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[long_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_order_pos_effect_deltrg]
on [dbo].[trade_order_pos_effect]
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
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(trade_order_pos_effect) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_order_pos_effect
   (trade_num,
    order_num,
    long_cmdty_code,
    long_mkt_code,
    short_cmdty_code,
    short_mkt_code,
    real_port_num,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.long_cmdty_code,
   d.long_mkt_code,
   d.short_cmdty_code,
   d.short_mkt_code,
   d.real_port_num,
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

create trigger [dbo].[trade_order_pos_effect_updtrg]
on [dbo].[trade_order_pos_effect]
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
   raiserror ('(trade_order_pos_effect) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_order_pos_effect) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num )
begin
   raiserror ('(trade_order_pos_effect) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or  
   update(order_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_order_pos_effect) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_order_pos_effect
      (trade_num,
       order_num,
       long_cmdty_code,
       long_mkt_code,
       short_cmdty_code,
       short_mkt_code,
       real_port_num,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.long_cmdty_code,
      d.long_mkt_code,
      d.short_cmdty_code,
      d.short_mkt_code,
      d.real_port_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[trade_order_pos_effect] ADD CONSTRAINT [trade_order_pos_effect_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_order_pos_effect] ADD CONSTRAINT [trade_order_pos_effect_fk1] FOREIGN KEY ([long_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_order_pos_effect] ADD CONSTRAINT [trade_order_pos_effect_fk2] FOREIGN KEY ([short_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_order_pos_effect] ADD CONSTRAINT [trade_order_pos_effect_fk3] FOREIGN KEY ([long_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[trade_order_pos_effect] ADD CONSTRAINT [trade_order_pos_effect_fk4] FOREIGN KEY ([short_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
GRANT DELETE ON  [dbo].[trade_order_pos_effect] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_order_pos_effect] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_order_pos_effect] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_order_pos_effect] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_order_pos_effect', NULL, NULL
GO

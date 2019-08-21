CREATE TABLE [dbo].[trade_order_railcar]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[freight_acct_num] [int] NOT NULL,
[agreement_init_month] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_order_railcar_updtrg]
on [dbo].[trade_order_railcar]
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
   raiserror ('(trade_order_railcar) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_order_railcar) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num )
begin
   raiserror ('(trade_order_railcar) new trans_id must not be older than current trans_id.',16,1)
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
      raiserror ('(trade_order_railcar) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[trade_order_railcar] ADD CONSTRAINT [trade_order_railcar_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_order_railcar] ADD CONSTRAINT [trade_order_railcar_fk1] FOREIGN KEY ([freight_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[trade_order_railcar] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_order_railcar] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_order_railcar] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_order_railcar] TO [next_usr]
GO

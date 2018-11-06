CREATE TABLE [dbo].[feed_cash_inbound]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[voucher_num] [int] NULL,
[sap_invoice_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_num] [int] NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[feed_cash_inbound_updtrg]
on [dbo].[feed_cash_inbound]
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
   raiserror ('(feed_cash_inbound) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(feed_cash_inbound) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(feed_cash_inbound) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(feed_cash_inbound) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end
return
GO
ALTER TABLE [dbo].[feed_cash_inbound] ADD CONSTRAINT [feed_cash_inbound_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_cash_inbound] ADD CONSTRAINT [feed_cash_inbound_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[feed_cash_inbound] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_cash_inbound] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_cash_inbound] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_cash_inbound] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'feed_cash_inbound', NULL, NULL
GO

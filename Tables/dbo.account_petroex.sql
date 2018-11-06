CREATE TABLE [dbo].[account_petroex]
(
[acct_num] [int] NOT NULL,
[petroex_num] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[usage_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_petroex_updtrg]
on [dbo].[account_petroex]
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
   raiserror ('(account_petroex) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(account_petroex) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num and 
                 i.petroex_num = d.petroex_num)
begin
   raiserror ('(account_petroex) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) or  
   update(petroex_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num and 
                                   i.petroex_num = d.petroex_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_petroex) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[account_petroex] ADD CONSTRAINT [account_petroex_pk] PRIMARY KEY CLUSTERED  ([acct_num], [petroex_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [acct_petroex_idx3] ON [dbo].[account_petroex] ([acct_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [acct_petroex_idx2] ON [dbo].[account_petroex] ([petroex_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_petroex] ADD CONSTRAINT [account_petroex_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[account_petroex] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_petroex] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_petroex] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_petroex] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'account_petroex', NULL, NULL
GO

CREATE TABLE [dbo].[mf_account_group]
(
[related_acct_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[acct_group_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parent_acct_own_pcnt] [float] NULL,
[acct_group_relation] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mf_account_group_updtrg]
on [dbo].[mf_account_group]
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
   raiserror ('(mf_account_group) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(mf_account_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.related_acct_num = d.related_acct_num and 
                 i.acct_num = d.acct_num and 
                 i.acct_group_type_code = d.acct_group_type_code )
begin
   raiserror ('(mf_account_group) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(related_acct_num) or 
   update(acct_num) or  
   update(acct_group_type_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.related_acct_num = d.related_acct_num and 
                                   i.acct_num = d.acct_num and 
                                   i.acct_group_type_code = d.acct_group_type_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mf_account_group) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[mf_account_group] ADD CONSTRAINT [mf_account_group_pk] PRIMARY KEY CLUSTERED  ([related_acct_num], [acct_num], [acct_group_type_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mf_account_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mf_account_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mf_account_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mf_account_group] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'mf_account_group', NULL, NULL
GO

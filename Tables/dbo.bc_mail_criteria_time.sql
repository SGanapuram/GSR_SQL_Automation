CREATE TABLE [dbo].[bc_mail_criteria_time]
(
[bc_mail_criteria_time_code] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_mail_criteria_time_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bc_mail_criteria_time_updtrg]
on [dbo].[bc_mail_criteria_time]
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
   raiserror ('(bc_mail_criteria_time) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(bc_mail_criteria_time) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.bc_mail_criteria_time_code = d.bc_mail_criteria_time_code )
begin
   raiserror ('(bc_mail_criteria_time) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(bc_mail_criteria_time_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.bc_mail_criteria_time_code = d.bc_mail_criteria_time_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bc_mail_criteria_time) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[bc_mail_criteria_time] ADD CONSTRAINT [bc_mail_criteria_time_pk] PRIMARY KEY CLUSTERED  ([bc_mail_criteria_time_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[bc_mail_criteria_time] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[bc_mail_criteria_time] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[bc_mail_criteria_time] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[bc_mail_criteria_time] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[bc_mail_criteria_time] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bc_mail_criteria_time] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bc_mail_criteria_time] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bc_mail_criteria_time] TO [next_usr]
GO

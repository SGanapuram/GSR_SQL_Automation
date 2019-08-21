CREATE TABLE [dbo].[als_run_status]
(
[als_run_status_id] [smallint] NOT NULL,
[als_run_status_desc] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[als_run_status_updtrg]
on [dbo].[als_run_status]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(als_run_status) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(als_run_status) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.als_run_status_id = d.als_run_status_id )
begin
   raiserror ('(als_run_status) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(als_run_status_id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.als_run_status_id = d.als_run_status_id)
   if (@count_num_rows <> @num_rows)
   begin
      raiserror ('(als_run_status) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[als_run_status] ADD CONSTRAINT [als_run_status_pk] PRIMARY KEY CLUSTERED  ([als_run_status_id]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[als_run_status] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[als_run_status] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[als_run_status] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[als_run_status] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[als_run_status] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[als_run_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[als_run_status] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[als_run_status] TO [next_usr]
GO

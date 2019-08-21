CREATE TABLE [dbo].[pass_schedule]
(
[job_schedule_num] [int] NOT NULL,
[asof_date] [datetime] NOT NULL,
[asof_date_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[icts_username] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[icts_password] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[icts_dbname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[task_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_num_list] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[end_of_day_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[logging_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pass_schedule_deltrg]
on [dbo].[pass_schedule]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(pass_schedule) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[pass_schedule_updtrg]
on [dbo].[pass_schedule]
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
   raiserror ('(pass_schedule) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(pass_schedule) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.job_schedule_num = d.job_schedule_num)
begin
   raiserror ('(pass_schedule) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(job_schedule_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.job_schedule_num = d.job_schedule_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(pass_schedule) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[pass_schedule] ADD CONSTRAINT [pass_schedule_pk] PRIMARY KEY CLUSTERED  ([job_schedule_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pass_schedule] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pass_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pass_schedule] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pass_schedule] TO [next_usr]
GO

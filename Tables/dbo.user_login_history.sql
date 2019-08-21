CREATE TABLE [dbo].[user_login_history]
(
[oid] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_host_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_pool_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_port_number] [int] NOT NULL,
[originating_ip_address] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[session_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[termination_status_type] [int] NULL,
[start_date] [datetime] NOT NULL,
[end_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[user_login_history_deltrg]
on [dbo].[user_login_history]
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
   select @errmsg = '(user_login_history) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_user_login_history
   (oid,
    user_init,
    app_host_name,
    app_name,
    app_pool_name,
    app_port_number,
    originating_ip_address,
    session_id,
    termination_status_type,
    start_date,
    end_date,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.user_init,
   d.app_host_name,
   d.app_name,
   d.app_pool_name,
   d.app_port_number,
   d.originating_ip_address,
   d.session_id,
   d.termination_status_type,
   d.start_date,
   d.end_date,
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

create trigger [dbo].[user_login_history_updtrg]
on [dbo].[user_login_history]
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
   raiserror ('(user_login_history) The change needs to be attached with a new trans_id',16,1)
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
   if (select count(*) from inserted, deleted 
       where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(user_login_history) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(user_login_history) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

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
      raiserror ('(user_login_history) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_user_login_history
      (oid,
       user_init,
       app_host_name,
       app_name,
       app_pool_name,
       app_port_number,
       originating_ip_address,
       session_id,
       termination_status_type,
       start_date,
       end_date,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.user_init,
      d.app_host_name,
      d.app_name,
      d.app_pool_name,
      d.app_port_number,
      d.originating_ip_address,
      d.session_id,
      d.termination_status_type,
      d.start_date,
      d.end_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[user_login_history] ADD CONSTRAINT [user_login_history_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [user_login_history_idx2] ON [dbo].[user_login_history] ([app_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [user_login_history_idx3] ON [dbo].[user_login_history] ([start_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [user_login_history_idx1] ON [dbo].[user_login_history] ([user_init]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_login_history] ADD CONSTRAINT [user_login_history_fk1] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[user_login_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[user_login_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[user_login_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[user_login_history] TO [next_usr]
GO

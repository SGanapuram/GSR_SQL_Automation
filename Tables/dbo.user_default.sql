CREATE TABLE [dbo].[user_default]
(
[oid] [int] NOT NULL,
[defaults_key] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[domain_id] [int] NOT NULL,
[may_not_override] [bit] NOT NULL CONSTRAINT [DF__user_defa__may_n__3EB236BE] DEFAULT ((0)),
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[defaults_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[user_default_deltrg]
on [dbo].[user_default]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.user_default 
from deleted d
where user_default.oid = d.oid

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(user_default) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_user_default
   (oid,
    defaults_key,
    domain_id,
    may_not_override,
    user_init,
    defaults_value,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.defaults_key,
   d.domain_id,
   d.may_not_override,
   d.user_init,
   d.defaults_value,
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

create trigger [dbo].[user_default_updtrg]
on [dbo].[user_default]
instead of update
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
   raiserror ('(user_default) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(user_default) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(user_default) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(user_default) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update dbo.user_default
set defaults_key = i.defaults_key,
    domain_id = i.domain_id,
    may_not_override = i.may_not_override,
    user_init = i.user_init,
    defaults_value = i.defaults_value,
    trans_id = i.trans_id
from deleted d, inserted i
where user_default.oid = d.oid and
      d.oid = i.oid

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_user_default
      (oid,
       defaults_key,
       domain_id,
       may_not_override,
       user_init,
       defaults_value,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.defaults_key,
      d.domain_id,
      d.may_not_override,
      d.user_init,
      d.defaults_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[user_default] ADD CONSTRAINT [user_default_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [user_default_idx1] ON [dbo].[user_default] ([user_init], [domain_id], [defaults_key]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_default] ADD CONSTRAINT [user_default_fk1] FOREIGN KEY ([domain_id]) REFERENCES [dbo].[defaults_domain] ([oid])
GO
ALTER TABLE [dbo].[user_default] ADD CONSTRAINT [user_default_fk2] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[user_default] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[user_default] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[user_default] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[user_default] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'user_default', NULL, NULL
GO

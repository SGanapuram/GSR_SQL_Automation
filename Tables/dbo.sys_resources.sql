CREATE TABLE [dbo].[sys_resources]
(
[oid] [int] NOT NULL,
[domain_id] [int] NOT NULL,
[culture] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[res_type] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[res_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[res_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sub_fieldname_0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[sys_resources_deltrg]
on [dbo].[sys_resources]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
delete dbo.sys_resources 
from deleted d
where sys_resources.oid = d.oid


/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(sys_resources) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_sys_resources
(
   oid,
   domain_id,
   culture,
   res_type,
   res_key,
   res_value,
   sub_fieldname_0,
   sub_fieldname_1,
   sub_fieldname_2,
   sub_fieldname_3,
   sub_fieldname_4,
   sub_fieldname_5,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.domain_id,
   d.culture,
   d.res_type,
   d.res_key,
   d.res_value,
   d.sub_fieldname_0,
   d.sub_fieldname_1,
   d.sub_fieldname_2,
   d.sub_fieldname_3,
   d.sub_fieldname_4,
   d.sub_fieldname_5,
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

create trigger [dbo].[sys_resources_updtrg]
on [dbo].[sys_resources]
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
   raiserror ('(sys_resources) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(sys_resources) New trans_id must be larger than original trans_id.'
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
   raiserror ('(sys_resources) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(sys_resources) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update dbo.sys_resources
set domain_id	= i.domain_id,
    culture	= i.culture,
    res_type = i.res_type,
    res_key	= i.res_key,
    res_value	= i.res_value,
    sub_fieldname_0	= i.sub_fieldname_0,
    sub_fieldname_1	= i.sub_fieldname_1,
    sub_fieldname_2	= i.sub_fieldname_2,
    sub_fieldname_3	= i.sub_fieldname_3,
    sub_fieldname_4	= i.sub_fieldname_4,
    sub_fieldname_5	= i.sub_fieldname_5,
    trans_id = i.trans_id
from deleted d, inserted i
where sys_resources.oid = d.oid and
      d.oid = i.oid
      
/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_sys_resources
   (
      oid,
      domain_id,
      culture,
      res_type,
      res_key,
      res_value,
      sub_fieldname_0,
      sub_fieldname_1,
      sub_fieldname_2,
      sub_fieldname_3,
      sub_fieldname_4,
      sub_fieldname_5,
      trans_id,
      resp_trans_id
   )
   select 
      d.oid,
      d.domain_id,
      d.culture,
      d.res_type,
      d.res_key,
      d.res_value,
      d.sub_fieldname_0,
      d.sub_fieldname_1,
      d.sub_fieldname_2,
      d.sub_fieldname_3,
      d.sub_fieldname_4,
      d.sub_fieldname_5,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[sys_resources] ADD CONSTRAINT [sys_resources_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sys_resources] ADD CONSTRAINT [sys_resources_fk1] FOREIGN KEY ([domain_id]) REFERENCES [dbo].[defaults_domain] ([oid])
GO
ALTER TABLE [dbo].[sys_resources] ADD CONSTRAINT [sys_resources_fk2] FOREIGN KEY ([res_type]) REFERENCES [dbo].[resource_type] ([res_type])
GO
GRANT DELETE ON  [dbo].[sys_resources] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[sys_resources] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[sys_resources] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[sys_resources] TO [next_usr]
GO

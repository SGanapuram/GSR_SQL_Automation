CREATE TABLE [dbo].[entity_tag_insp_attr]
(
[entity_tag_id] [int] NOT NULL,
[entity_tag_attr_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_tag_attr_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[entity_tag_insp_attr_deltrg]
on [dbo].[entity_tag_insp_attr]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.entity_tag_insp_attr 
from deleted d
where entity_tag_insp_attr.entity_tag_id = d.entity_tag_id and
      entity_tag_insp_attr.entity_tag_attr_name = d.entity_tag_attr_name

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(entity_tag_insp_attr) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   rollback tran
   return
end

/* AUDIT_CODE_BEGIN */
insert dbo.aud_entity_tag_insp_attr
   (entity_tag_id,
    entity_tag_attr_name,
    entity_tag_attr_value,
    trans_id,
    resp_trans_id)
select
   d.entity_tag_id,
   d.entity_tag_attr_name,
   d.entity_tag_attr_value,
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

create trigger [dbo].[entity_tag_insp_attr_updtrg]
on [dbo].[entity_tag_insp_attr]
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
   raiserror('(entity_tag_insp_attr) The change needs to be attached with a new trans_id', 16, 1)
   rollback tran
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
      select @errmsg = '(comment) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 16, 1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.entity_tag_id = d.entity_tag_id and
                 i.entity_tag_attr_name = d.entity_tag_attr_name )
begin
   raiserror('(entity_tag_insp_attr) new trans_id must not be older than current trans_id.', 16, 1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(entity_tag_id) or
   update(entity_tag_attr_name) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.entity_tag_id = d.entity_tag_id and
                                   i.entity_tag_attr_name = d.entity_tag_attr_name )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror('(entity_tag_insp_attr) primary key can not be changed.', 16, 1)
      rollback tran
      return
   end
end

update dbo.entity_tag_insp_attr
set entity_tag_attr_value = i.entity_tag_attr_value,
    trans_id = i.trans_id
from deleted d, inserted i
where entity_tag_insp_attr.entity_tag_id = d.entity_tag_id and
      entity_tag_insp_attr.entity_tag_attr_name = d.entity_tag_attr_name and
      d.entity_tag_id = i.entity_tag_id and
      d.entity_tag_attr_name = i.entity_tag_attr_name
      
/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_entity_tag_insp_attr
      (entity_tag_id,
       entity_tag_attr_name,
       entity_tag_attr_value,
       trans_id,
       resp_trans_id)
   select
      d.entity_tag_id,
      d.entity_tag_attr_name,
      d.entity_tag_attr_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.entity_tag_id = i.entity_tag_id and
         d.entity_tag_attr_name = i.entity_tag_attr_name 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[entity_tag_insp_attr] ADD CONSTRAINT [entity_tag_insp_attr_pk] PRIMARY KEY CLUSTERED  ([entity_tag_id], [entity_tag_attr_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entity_tag_insp_attr] ADD CONSTRAINT [entity_tag_insp_attr_fk1] FOREIGN KEY ([entity_tag_id]) REFERENCES [dbo].[entity_tag_definition] ([oid])
GO
GRANT DELETE ON  [dbo].[entity_tag_insp_attr] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[entity_tag_insp_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[entity_tag_insp_attr] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[entity_tag_insp_attr] TO [next_usr]
GO

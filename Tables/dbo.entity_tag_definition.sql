CREATE TABLE [dbo].[entity_tag_definition]
(
[oid] [int] NOT NULL,
[entity_tag_name] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_tag_desc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_entity_id] [int] NULL,
[tag_required_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_entity_tag_definition_tag_required_ind] DEFAULT ('N'),
[tag_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_entity_tag_definition_tag_status] DEFAULT ('A'),
[entity_id] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[entity_tag_definition_deltrg]
on [dbo].[entity_tag_definition]
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
   select @errmsg = '(entity_tag_definition) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg, 16, 1)
   rollback tran
   return
end

/* AUDIT_CODE_BEGIN */
insert dbo.aud_entity_tag_definition
   (oid,
    entity_tag_name,
    entity_tag_desc,
    target_entity_id,
    tag_required_ind,
    tag_status,
    entity_id,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.entity_tag_name,
   d.entity_tag_desc,
   d.target_entity_id,
   d.tag_required_ind,
   d.tag_status,
   d.entity_id,
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
create trigger [dbo].[entity_tag_definition_instrg]  
on [dbo].[entity_tag_definition]  
for insert  
as  
declare @num_rows        int,  
        @entity_id       int  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
   -- Here, whenever an entity_tag_definition was added. We want to  
   -- add the this entry into the portfolio_tag_definition table as well  
   -- if the entry is related to Portfolio.  
  
   select @entity_id = oid   
   from dbo.icts_entity_name  
   where entity_name = 'Portfolio'  
  
   insert into dbo.portfolio_tag_definition  
      (tag_name, tag_desc, tag_status, tag_required_ind, trans_id)  
   select entity_tag_name,  
          entity_tag_desc,  
          tag_status, 
		  tag_required_ind,
          trans_id  
   from inserted i  
   where entity_id = @entity_id and  
         not exists (select 1  
                     from dbo.portfolio_tag_definition b  
                     where i.entity_tag_name = b.tag_name)  
   -- for DEBUG  
   -- select @num_rows = @@rowcount  
   -- if @num_rows > 0  
   --    print 'New portfolio_tag_definition row(s) were added successfully!'  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
create trigger [dbo].[entity_tag_definition_updtrg]  
on [dbo].[entity_tag_definition]  
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
   raiserror ('(entity_tag_definition) The change needs to be attached with a new trans_id', 16, 1)  
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
      select @errmsg = '(entity_tag_definition) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror(@errmsg, 16, 1)  
      rollback tran  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.oid = d.oid )  
begin  
   raiserror('(entity_tag_definition) new trans_id must not be older than current trans_id.', 16, 1)  
   rollback tran  
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
      raiserror('(entity_tag_definition) primary key can not be changed.', 16, 1)  
      rollback tran  
      return  
   end  
end  
  
if update(tag_status)   
begin  
   if exists (select 1   
              from dbo.portfolio_tag_definition ptd, deleted d  
              where ptd.tag_name = d.entity_tag_name)  
   begin  
      update dbo.portfolio_tag_definition  
      set tag_status = i.tag_status,  
          trans_id = i.trans_id  
      from inserted i  
      where tag_name = i.entity_tag_name  
   end  
end
 
if update(tag_required_ind)   
begin  
   if exists (select 1   
              from dbo.portfolio_tag_definition ptd, deleted d  
              where ptd.tag_name = d.entity_tag_name)  
   begin  
      update dbo.portfolio_tag_definition  
      set tag_required_ind = i.tag_required_ind,
          trans_id = i.trans_id  
      from inserted i  
      where tag_name = i.entity_tag_name  
   end  
end  
  
  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_entity_tag_definition  
      (oid,  
       entity_tag_name,  
       entity_tag_desc,  
       target_entity_id,  
       tag_required_ind,  
       tag_status,  
       entity_id,  
       trans_id,  
       resp_trans_id)  
   select  
      d.oid,  
      d.entity_tag_name,  
      d.entity_tag_desc,  
      d.target_entity_id,  
      d.tag_required_ind,  
      d.tag_status,  
      d.entity_id,  
      d.trans_id,  
      i.trans_id  
   from deleted d, inserted i  
   where d.oid = i.oid   
  
/* AUDIT_CODE_END */  
  
return  
GO
ALTER TABLE [dbo].[entity_tag_definition] ADD CONSTRAINT [chk_entity_tag_definition_tag_required_ind] CHECK (([tag_required_ind]='N' OR [tag_required_ind]='Y'))
GO
ALTER TABLE [dbo].[entity_tag_definition] ADD CONSTRAINT [chk_entity_tag_definition_tag_status] CHECK (([tag_status]='S' OR [tag_status]='I' OR [tag_status]='A'))
GO
ALTER TABLE [dbo].[entity_tag_definition] ADD CONSTRAINT [entity_tag_definition_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entity_tag_definition_idx2] ON [dbo].[entity_tag_definition] ([entity_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [entity_tag_definition_idx3] ON [dbo].[entity_tag_definition] ([entity_tag_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entity_tag_definition_idx1] ON [dbo].[entity_tag_definition] ([target_entity_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entity_tag_definition] ADD CONSTRAINT [entity_tag_definition_fk1] FOREIGN KEY ([target_entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
ALTER TABLE [dbo].[entity_tag_definition] ADD CONSTRAINT [entity_tag_definition_fk2] FOREIGN KEY ([entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
GRANT DELETE ON  [dbo].[entity_tag_definition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[entity_tag_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[entity_tag_definition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[entity_tag_definition] TO [next_usr]
GO

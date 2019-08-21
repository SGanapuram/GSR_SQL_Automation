CREATE TABLE [dbo].[entity_tag]
(
[entity_tag_key] [int] NOT NULL,
[entity_tag_id] [int] NOT NULL,
[key1] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key7] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key8] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key1] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key2] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key3] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key4] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key5] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key6] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key7] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_key8] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[entity_tag_deltrg]
on [dbo].[entity_tag]
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
   select @errmsg = '(entity_tag) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   rollback tran
   return
end

/* AUDIT_CODE_BEGIN */
insert dbo.aud_entity_tag
   (entity_tag_key,
    entity_tag_id,
    key1,
    key2,
    key3,
    key4,
    key5,
    key6,
    key7,
    key8,
    target_key1,
    target_key2,
    target_key3,
    target_key4,
    target_key5,
    target_key6,
    target_key7,
    target_key8,
    trans_id,
    resp_trans_id)
select
   d.entity_tag_key,
   d.entity_tag_id,
   d.key1,
   d.key2,
   d.key3,
   d.key4,
   d.key5,
   d.key6,
   d.key7,
   d.key8,
   d.target_key1,
   d.target_key2,
   d.target_key3,
   d.target_key4,
   d.target_key5,
   d.target_key6,
   d.target_key7,
   d.target_key8,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'EntityTag',
       'DIRECT',
       convert(varchar(40), d.entity_tag_key),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
      
/* END_TRANSACTION_TOUCH */

-- Here, whenever an entity_tag was deleted. We want to
-- remove the correspinding entry in the portfolio_tag table.
-- if the entry is related to Portfolio.

declare @entity_id       int

select @entity_id = oid
from dbo.icts_entity_name with (nolock)
where entity_name = 'Portfolio'

if exists (select 1
           from deleted d, 
                dbo.entity_tag_definition b
           where d.entity_tag_id = b.oid and
                 b.entity_id = @entity_id)
begin
   delete dbo.portfolio_tag 
   from deleted d, 
        dbo.entity_tag_definition b, 
        dbo.portfolio_tag ptag
   where d.entity_tag_id = b.oid and
         b.entity_id = @entity_id and
         b.entity_tag_name = ptag.tag_name and
         ptag.port_num = convert(int, d.key1) and
         ptag.tag_value = d.target_key1
end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[entity_tag_instrg]
on [dbo].[entity_tag]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255),
        @entity_id       int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'INSERT',
       'EntityTag',
       'DIRECT',
       convert(varchar(40), i.entity_tag_key),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

   -- Here, whenever an entity_tag was added. We want to
   -- add the this entry into the portfolio_tag table as well
   -- if the entry is related to Portfolio.

   select @entity_id = oid 
   from dbo.icts_entity_name with (nolock)
   where entity_name = 'Portfolio'

   if exists (select 1
              from inserted i, 
                   dbo.entity_tag_definition b
              where i.entity_tag_id = b.oid and
                    b.entity_id = @entity_id) 
   begin
      insert into dbo.portfolio_tag
         (tag_name, port_num, tag_value, trans_id)
      select b.entity_tag_name,
             convert(int, i.key1),
             case when b.entity_tag_name = 'JMSRPT' then 'JMS REPORT'
                  else isnull(i.target_key1, '')
             end,
             1
      from inserted i, 
           dbo.entity_tag_definition b
      where i.entity_tag_id = b.oid and
            b.entity_id = @entity_id and 
            not exists (select 1
                        from dbo.portfolio_tag ptag
                        where ptag.tag_name = b.entity_tag_name and
                              ptag.port_num = convert(int, i.key1) and
                              ptag.tag_value = case when ptag.tag_name = 'JMSRPT' then 'JMS REPORT'
                                                    else isnull(i.target_key1, '')
                                               end)
      -- for DEBUG
      -- select @num_rows = @@rowcount
      -- if @num_rows > 0
      --    print 'A new portfolio_tag row was added successfully!'
   
      -- make sure that each port_num added into portfolio_tag table has the
      -- PIVOT tag 'JMSRPT'
      insert into dbo.portfolio_tag
         (tag_name, port_num, tag_value, trans_id)
      select 'JMSRPT',
             convert(int, i.key1),
             'JMS REPORT',
             1
      from inserted i, 
           dbo.entity_tag_definition b
      where i.entity_tag_id = b.oid and
            b.entity_id = @entity_id and 
            not exists (select 1
                        from dbo.portfolio_tag ptag
                        where ptag.tag_name = 'JMSRPT' and
                              ptag.port_num = convert(int, i.key1))
      -- for DEBUG
      -- select @num_rows = @@rowcount
      -- if @num_rows > 0
      --    print 'A new portfolio_tag PIVOT row was added successfully!'
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[entity_tag_updtrg]
on [dbo].[entity_tag]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255),
        @entity_id        int

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(entity_tag) The change needs to be attached with a new trans_id',16,1)
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
      raiserror (@errmsg,16,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.entity_tag_key = d.entity_tag_key )
begin
   raiserror('(entity_tag) new trans_id must not be older than current trans_id.', 16, 1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(entity_tag_key)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.entity_tag_key = d.entity_tag_key )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(entity_tag) primary key can not be changed.',16,1)
      rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
begin
   insert dbo.aud_entity_tag
      (entity_tag_key,
       entity_tag_id,
       key1,
       key2,
       key3,
       key4,
       key5,
       key6,
       key7,
       key8,
       target_key1,
       target_key2,
       target_key3,
       target_key4,
       target_key5,
       target_key6,
       target_key7,
       target_key8,
       trans_id,
       resp_trans_id)
   select
      d.entity_tag_key,
      d.entity_tag_id,
      d.key1,
      d.key2,
      d.key3,
      d.key4,
      d.key5,
      d.key6,
      d.key7,
      d.key8,
      d.target_key1,
      d.target_key2,
      d.target_key3,
      d.target_key4,
      d.target_key5,
      d.target_key6,
      d.target_key7,
      d.target_key8,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.entity_tag_key = i.entity_tag_key

   /* BEGIN_TRANSACTION_TOUCH */

   insert dbo.transaction_touch
   select 'UPDATE',
          'EntityTag',
          'DIRECT',
          convert(varchar(40), i.entity_tag_key),
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'

   /* END_TRANSACTION_TOUCH */

   select @entity_id = oid 
   from dbo.icts_entity_name with (nolock)
   where entity_name = 'Portfolio'
  
   -- The primary key of the portfolio_tag table is <tag_name, port_num>, therefore, the
   -- key1 of the tags associated with the entity 'Portfolio' is not allowed to be changed.
   if exists (select 1
              from inserted i,
                   deleted d,
                   dbo.entity_tag_definition tagdef
              where i.entity_tag_id = tagdef.oid and
                    tagdef.entity_id = @entity_id and
                    d.entity_tag_key = i.entity_tag_key and
                    d.key1 <> i.key1)
   begin
      rollback tran
      raiserror ('(entity_tag) The <tag_name, key1> for the entity ''Portfolio'' can not be changed.', 16, 1)
      return
   end                    

   if exists (select 1
              from inserted i,
                   deleted d,
                   dbo.entity_tag_definition tagdef
              where i.entity_tag_id = tagdef.oid and
                    tagdef.entity_id = @entity_id and
                    d.entity_tag_key = i.entity_tag_key and
                    isnull(d.target_key1, '') <> isnull(i.target_key1, ''))   
   begin
      update dbo.portfolio_tag
      set tag_value = isnull(i.target_key1, ''),
          trans_id = i.trans_id
      from inserted i,
           dbo.entity_tag_definition tagdef,
           dbo.portfolio_tag porttag
      where i.entity_tag_id = tagdef.oid and
            tagdef.entity_id = @entity_id and
            porttag.tag_name = tagdef.entity_tag_name and
            porttag.port_num = convert(int, i.key1)            
   end                    
end

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[entity_tag] ADD CONSTRAINT [entity_tag_pk] PRIMARY KEY CLUSTERED  ([entity_tag_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entity_tag_idx1] ON [dbo].[entity_tag] ([entity_tag_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entity_tag_idx3] ON [dbo].[entity_tag] ([entity_tag_id], [key1], [key2], [key3]) INCLUDE ([target_key1], [target_key2], [target_key3], [target_key4], [target_key5], [target_key6], [target_key7], [target_key8], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entity_tag_idx2] ON [dbo].[entity_tag] ([key1], [key2], [key3], [key4], [key5], [key6], [key7], [key8]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entity_tag] ADD CONSTRAINT [entity_tag_fk1] FOREIGN KEY ([entity_tag_id]) REFERENCES [dbo].[entity_tag_definition] ([oid])
GO
GRANT DELETE ON  [dbo].[entity_tag] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[entity_tag] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[entity_tag] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[entity_tag] TO [next_usr]
GO

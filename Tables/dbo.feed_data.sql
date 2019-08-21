CREATE TABLE [dbo].[feed_data]
(
[oid] [int] NOT NULL,
[request_xml_id] [int] NOT NULL,
[response_xml_id] [int] NOT NULL,
[number_of_rows] [int] NOT NULL CONSTRAINT [df_feed_data_number_of_rows] DEFAULT ((0)),
[feed_id] [int] NOT NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_feed_data_status] DEFAULT ('PENDING'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[feed_data_deltrg]
on [dbo].[feed_data]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(feed_data) Failed to obtain a valid responsible trans_id. '
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

insert dbo.aud_feed_data
(  
 	 oid,
   request_xml_id,
   response_xml_id,
   number_of_rows,
   feed_id,             
   status,
   trans_id,
   resp_trans_id
)
select
 	 d.oid,
   d.request_xml_id,
   d.response_xml_id,
   d.number_of_rows,
   d.feed_id,             
   d.status,
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

CREATE trigger [dbo].[feed_data_instrg]
on [dbo].[feed_data]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return   

declare @the_sequence       numeric(32, 0),        
        @the_entity_name    varchar(30)

   select @the_entity_name = 'FeedData'

   if @num_rows = 1
   begin
      select @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from inserted i

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      
      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[feed_data_updtrg]
on [dbo].[feed_data]
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
   raiserror ('(feed_data) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(feed_data) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(feed_data) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
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
      raiserror ('(feed_data) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_feed_data
      (oid,
       request_xml_id,
       response_xml_id,
       number_of_rows,
       feed_id,             
       status,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.request_xml_id,
      d.response_xml_id,
      d.number_of_rows,
      d.feed_id,             
      d.status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 


declare @the_sequence       numeric(32, 0),           
        @the_entity_name    varchar(30)    
    
   select @the_entity_name = 'FeedData'    
    
   if @num_rows = 1    
   begin    
      select @the_sequence = it.sequence    
      from dbo.icts_transaction it WITH (NOLOCK),    
           inserted i    
      where it.trans_id = i.trans_id    
    
    
      /* BEGIN_TRANSACTION_TOUCH */    
    
      insert dbo.transaction_touch    
      select 'UPDATE',    
             @the_entity_name,    
             'DIRECT',    
             convert(varchar(40),oid),    
             null,    
             null,    
             null,    
             null,    
             null,    
             null,    
             null,    
             i.trans_id,    
             @the_sequence    
      from inserted i    
    
      /* END_TRANSACTION_TOUCH */    
   end    
   else    
   begin  /* if @num_rows > 1 */    
         
      /* BEGIN_TRANSACTION_TOUCH */    
    
      insert dbo.transaction_touch    
      select 'UPDATE',    
             @the_entity_name,    
             'DIRECT',    
             convert(varchar(40),oid),    
             null,    
             null,    
             null,    
             null,    
             null,    
             null,    
             null,    
             i.trans_id,    
             it.sequence    
      from dbo.icts_transaction it WITH (NOLOCK),    
           inserted i    
      where i.trans_id = it.trans_id    
    
      /* END_TRANSACTION_TOUCH */    
   end    
    
return 
GO
ALTER TABLE [dbo].[feed_data] ADD CONSTRAINT [feed_data_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_data_idx1] ON [dbo].[feed_data] ([status]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_data] ADD CONSTRAINT [feed_data_fk1] FOREIGN KEY ([feed_id]) REFERENCES [dbo].[feed_definition] ([oid])
GO
ALTER TABLE [dbo].[feed_data] ADD CONSTRAINT [feed_data_fk2] FOREIGN KEY ([request_xml_id]) REFERENCES [dbo].[feed_xsd_xml_text] ([oid])
GO
ALTER TABLE [dbo].[feed_data] ADD CONSTRAINT [feed_data_fk3] FOREIGN KEY ([response_xml_id]) REFERENCES [dbo].[feed_xsd_xml_text] ([oid])
GO
ALTER TABLE [dbo].[feed_data] ADD CONSTRAINT [feed_data_fk4] FOREIGN KEY ([status]) REFERENCES [dbo].[feed_status] ([status])
GO
GRANT DELETE ON  [dbo].[feed_data] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_data] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_data] TO [next_usr]
GO

CREATE TABLE [dbo].[feed_definition]
(
[oid] [int] NOT NULL,
[feed_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[request_xsd_id] [int] NULL,
[response_xsd_id] [int] NULL,
[mapping_xml_id] [int] NULL,
[active_ind] [bit] NOT NULL CONSTRAINT [df_feed_definition_active_ind] DEFAULT ((1)),
[trans_id] [int] NOT NULL,
[display_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[interface] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[feed_definition_deltrg]
on [dbo].[feed_definition]
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
   select @errmsg = '(feed_definition) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_feed_definition
   (
oid,
feed_name,
request_xsd_id,
response_xsd_id,
mapping_xml_id,
active_ind,
trans_id,
display_name,
interface,
resp_trans_id
)
select
d.oid,
d.feed_name,
d.request_xsd_id,
d.response_xsd_id,
d.mapping_xml_id,
d.active_ind,
d.trans_id,
d.display_name,
d.interface,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[feed_definition_updtrg]
on [dbo].[feed_definition]
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
   raiserror ('(feed_definition) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(feed_definition) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(feed_definition) new trans_id must not be older than current trans_id.',16,1)
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
      raiserror ('(feed_definition) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_feed_definition
 (
oid,
feed_name,
request_xsd_id,
response_xsd_id,
mapping_xml_id,
active_ind,
trans_id,
display_name,
interface,
resp_trans_id)
   select
d.oid,
d.feed_name,
d.request_xsd_id,
d.response_xsd_id,
d.mapping_xml_id,
d.active_ind,
d.trans_id,
d.display_name,
d.interface,
i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[feed_definition] ADD CONSTRAINT [feed_definition_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_definition_idx1] ON [dbo].[feed_definition] ([feed_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_definition] ADD CONSTRAINT [feed_definition_fk1] FOREIGN KEY ([request_xsd_id]) REFERENCES [dbo].[feed_definition_xsd_xml] ([oid])
GO
ALTER TABLE [dbo].[feed_definition] ADD CONSTRAINT [feed_definition_fk2] FOREIGN KEY ([response_xsd_id]) REFERENCES [dbo].[feed_definition_xsd_xml] ([oid])
GO
ALTER TABLE [dbo].[feed_definition] ADD CONSTRAINT [feed_definition_fk3] FOREIGN KEY ([mapping_xml_id]) REFERENCES [dbo].[feed_definition_xsd_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[feed_definition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_definition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_definition] TO [next_usr]
GO

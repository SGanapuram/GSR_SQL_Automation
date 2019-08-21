CREATE TABLE [dbo].[feed_refdata_mapping]
(
[oid] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_id] [int] NULL,
[external_key1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_key2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_key3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key1_value_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key2_value_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key3_value_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key4_value_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key5_value_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key6_value_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[feed_refdata_mapping_updtrg]
on [dbo].[feed_refdata_mapping]
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
   raiserror ('(feed_refdata_mapping) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(feed_refdata_mapping) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(feed_refdata_mapping) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(feed_refdata_mapping) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[feed_refdata_mapping] ADD CONSTRAINT [feed_refdata_mapping_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_refdata_mapping_idx1] ON [dbo].[feed_refdata_mapping] ([alias_source_code], [entity_id], [external_key1], [external_key2], [external_key3]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_refdata_mapping_idx2] ON [dbo].[feed_refdata_mapping] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_refdata_mapping] ADD CONSTRAINT [feed_refdata_mapping_fk1] FOREIGN KEY ([alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
ALTER TABLE [dbo].[feed_refdata_mapping] ADD CONSTRAINT [feed_refdata_mapping_fk2] FOREIGN KEY ([entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
GRANT DELETE ON  [dbo].[feed_refdata_mapping] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_refdata_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_refdata_mapping] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_refdata_mapping] TO [next_usr]
GO

CREATE TABLE [dbo].[ext_refdata_mapping]
(
[oid] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_id] [int] NOT NULL,
[external_key1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[external_key2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_key3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_key1_value_id] [int] NOT NULL,
[entity_key2_value_id] [int] NULL,
[entity_key3_value_id] [int] NULL,
[entity_key4_value_id] [int] NULL,
[entity_key5_value_id] [int] NULL,
[entity_key6_value_id] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ext_refdata_mapping_deltrg]
on [dbo].[ext_refdata_mapping]
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
   select @errmsg = '(ext_refdata_mapping) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_ext_refdata_mapping
(  
 	 oid,
   alias_source_code,
   entity_id,
   external_key1,
   external_key2,
   external_key3,
   entity_key1_value_id,
   entity_key2_value_id,
   entity_key3_value_id,
   entity_key4_value_id,
   entity_key5_value_id,
   entity_key6_value_id,
   trans_id,
   resp_trans_id
)
select
 	 d.oid,
   d.alias_source_code,
   d.entity_id,
   d.external_key1,
   d.external_key2,
   d.external_key3,
   d.entity_key1_value_id,
   d.entity_key2_value_id,
   d.entity_key3_value_id,
   d.entity_key4_value_id,
   d.entity_key5_value_id,
   d.entity_key6_value_id,
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

create trigger [dbo].[ext_refdata_mapping_updtrg]
on [dbo].[ext_refdata_mapping]
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
   raiserror ('(ext_refdata_mapping) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(ext_refdata_mapping) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(ext_refdata_mapping) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(ext_refdata_mapping) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_ext_refdata_mapping
 	    (oid,
       alias_source_code,
       entity_id,
       external_key1,
       external_key2,
       external_key3,
       entity_key1_value_id,
       entity_key2_value_id,
       entity_key3_value_id,
       entity_key4_value_id,
       entity_key5_value_id,
       entity_key6_value_id,
       trans_id,
       resp_trans_id)
   select
 	    d.oid,
      d.alias_source_code,
      d.entity_id,
      d.external_key1,
      d.external_key2,
      d.external_key3,
      d.entity_key1_value_id,
      d.entity_key2_value_id,
      d.entity_key3_value_id,
      d.entity_key4_value_id,
      d.entity_key5_value_id,
      d.entity_key6_value_id,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk1] FOREIGN KEY ([alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk2] FOREIGN KEY ([entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk3] FOREIGN KEY ([entity_key1_value_id]) REFERENCES [dbo].[ext_ref_keys] ([oid])
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk4] FOREIGN KEY ([entity_key2_value_id]) REFERENCES [dbo].[ext_ref_keys] ([oid])
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk5] FOREIGN KEY ([entity_key3_value_id]) REFERENCES [dbo].[ext_ref_keys] ([oid])
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk6] FOREIGN KEY ([entity_key4_value_id]) REFERENCES [dbo].[ext_ref_keys] ([oid])
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk7] FOREIGN KEY ([entity_key5_value_id]) REFERENCES [dbo].[ext_ref_keys] ([oid])
GO
ALTER TABLE [dbo].[ext_refdata_mapping] ADD CONSTRAINT [ext_refdata_mapping_fk8] FOREIGN KEY ([entity_key6_value_id]) REFERENCES [dbo].[ext_ref_keys] ([oid])
GO
GRANT DELETE ON  [dbo].[ext_refdata_mapping] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ext_refdata_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ext_refdata_mapping] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ext_refdata_mapping] TO [next_usr]
GO

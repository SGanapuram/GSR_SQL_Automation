CREATE TABLE [dbo].[contract_amendable_field]
(
[oid] [int] NOT NULL,
[entity_id] [int] NOT NULL,
[entity_field] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_field_datatype] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract_amendable_field] ADD CONSTRAINT [contract_amendable_field_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[contract_amendable_field] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[contract_amendable_field] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[contract_amendable_field] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[contract_amendable_field] TO [next_usr]
GO

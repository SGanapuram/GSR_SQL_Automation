CREATE TABLE [dbo].[aud_contract_amendable_field]
(
[oid] [int] NOT NULL,
[entity_id] [int] NOT NULL,
[entity_field] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_field_datatype] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_amendable_field] ON [dbo].[aud_contract_amendable_field] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_amendable_field_idx1] ON [dbo].[aud_contract_amendable_field] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_contract_amendable_field] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_contract_amendable_field] TO [next_usr]
GO

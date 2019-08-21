CREATE TABLE [dbo].[aud_external_mapping]
(
[oid] [int] NOT NULL,
[external_trade_source_oid] [int] NOT NULL,
[mapping_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[external_value1] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_value2] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_value3] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_value4] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alias_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_mapping] ON [dbo].[aud_external_mapping] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_mapping_idx1] ON [dbo].[aud_external_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_external_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_mapping] TO [next_usr]
GO

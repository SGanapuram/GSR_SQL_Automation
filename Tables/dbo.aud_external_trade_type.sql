CREATE TABLE [dbo].[aud_external_trade_type]
(
[oid] [int] NOT NULL,
[external_trade_source_oid] [int] NOT NULL,
[trade_type_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_type_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade_type_idx1] ON [dbo].[aud_external_trade_type] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade_type_idx2] ON [dbo].[aud_external_trade_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_external_trade_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_trade_type] TO [next_usr]
GO

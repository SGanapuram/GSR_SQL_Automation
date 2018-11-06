CREATE TABLE [dbo].[aud_lm_marketdata_mapping]
(
[oid] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[exch_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exch_cmpx_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[product_family_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[product_family_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cb_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_marketdata_mapping] ON [dbo].[aud_lm_marketdata_mapping] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_marketdata_mapping_idx1] ON [dbo].[aud_lm_marketdata_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lm_marketdata_mapping] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lm_marketdata_mapping] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lm_marketdata_mapping] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lm_marketdata_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lm_marketdata_mapping] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lm_marketdata_mapping', NULL, NULL
GO

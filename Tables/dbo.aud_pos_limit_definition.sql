CREATE TABLE [dbo].[aud_pos_limit_definition]
(
[oid] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[pos_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pos_limit_definition] ON [dbo].[aud_pos_limit_definition] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pos_limit_definition_idx1] ON [dbo].[aud_pos_limit_definition] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pos_limit_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pos_limit_definition] TO [next_usr]
GO

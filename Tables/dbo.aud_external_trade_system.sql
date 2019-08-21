CREATE TABLE [dbo].[aud_external_trade_system]
(
[oid] [int] NOT NULL,
[external_trade_system_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade_system] ON [dbo].[aud_external_trade_system] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade_system_idx1] ON [dbo].[aud_external_trade_system] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_external_trade_system] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_trade_system] TO [next_usr]
GO

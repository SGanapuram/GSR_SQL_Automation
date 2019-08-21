CREATE TABLE [dbo].[aud_trade_sync]
(
[trade_num] [int] NOT NULL,
[trade_sync_inds] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_sync] ON [dbo].[aud_trade_sync] ([trade_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_sync_idx1] ON [dbo].[aud_trade_sync] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_sync] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_sync] TO [next_usr]
GO

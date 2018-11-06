CREATE TABLE [dbo].[aud_trade_group_cmdty_mkt]
(
[trade_group_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_exclusion_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_group_cmdty_mkt] ON [dbo].[aud_trade_group_cmdty_mkt] ([trade_group_num], [commkt_key], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_group_cmdty_mkt_idx1] ON [dbo].[aud_trade_group_cmdty_mkt] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_group_cmdty_mkt] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_group_cmdty_mkt] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_group_cmdty_mkt] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_group_cmdty_mkt] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_group_cmdty_mkt] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_group_cmdty_mkt', NULL, NULL
GO

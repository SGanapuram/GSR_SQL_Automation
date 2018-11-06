CREATE TABLE [dbo].[aud_trade_tenor]
(
[tenor_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tenor_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_tenor] ON [dbo].[aud_trade_tenor] ([tenor_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_tenor_idx1] ON [dbo].[aud_trade_tenor] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_tenor] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_tenor] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_tenor] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_tenor] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_tenor] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_tenor', NULL, NULL
GO

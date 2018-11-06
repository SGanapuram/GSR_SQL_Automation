CREATE TABLE [dbo].[aud_strategy]
(
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strategy_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_strategy_idx] ON [dbo].[aud_strategy] ([user_init], [strategy_name], [port_num], [cmdty_code], [mkt_code], [trading_prd], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_strategy] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_strategy] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_strategy] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_strategy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_strategy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_strategy', NULL, NULL
GO

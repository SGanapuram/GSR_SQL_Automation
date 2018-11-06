CREATE TABLE [dbo].[aud_option_strike]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_strike_price] [float] NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_option_strike] ON [dbo].[aud_option_strike] ([commkt_key], [trading_prd], [opt_strike_price], [put_call_ind], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_option_strike_idx1] ON [dbo].[aud_option_strike] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_option_strike] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_option_strike] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_option_strike] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_option_strike] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_option_strike] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_option_strike', NULL, NULL
GO

CREATE TABLE [dbo].[aud_realiza_price_frg_cost]
(
[crude_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[flat_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ws_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_realiza_price_frg_cost_idx] ON [dbo].[aud_realiza_price_frg_cost] ([crude_cmdty_code], [mkt_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_realiza_price_frg_cost] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_realiza_price_frg_cost] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_realiza_price_frg_cost] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_realiza_price_frg_cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_realiza_price_frg_cost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_realiza_price_frg_cost', NULL, NULL
GO

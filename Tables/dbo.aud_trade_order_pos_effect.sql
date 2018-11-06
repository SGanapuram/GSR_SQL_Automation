CREATE TABLE [dbo].[aud_trade_order_pos_effect]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[long_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_torder_pos_effect_idx1] ON [dbo].[aud_trade_order_pos_effect] ([trade_num], [order_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_pos_effe_idx2] ON [dbo].[aud_trade_order_pos_effect] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_order_pos_effect] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_order_pos_effect] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_order_pos_effect] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_order_pos_effect] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_order_pos_effect] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_order_pos_effect', NULL, NULL
GO

CREATE TABLE [dbo].[aud_trade_item_cleared]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[contr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lot_quantity] [decimal] (20, 8) NULL,
[clr_brkr_num] [int] NULL,
[contr_price] [decimal] (20, 8) NULL,
[contr_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_cleared] ON [dbo].[aud_trade_item_cleared] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_cleared_idx1] ON [dbo].[aud_trade_item_cleared] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_cleared] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_cleared] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_cleared] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_cleared] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_cleared] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_cleared', NULL, NULL
GO

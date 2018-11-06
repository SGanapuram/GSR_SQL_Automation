CREATE TABLE [dbo].[aud_trade_item_curr]
(
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[item_num] [int] NOT NULL,
[payment_date] [datetime] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_spot_rate] [numeric] (20, 8) NULL,
[pay_curr_amt] [numeric] (20, 8) NOT NULL,
[pay_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rec_curr_amt] [numeric] (20, 8) NOT NULL,
[rec_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_curr_idx1] ON [dbo].[aud_trade_item_curr] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_curr_idx2] ON [dbo].[aud_trade_item_curr] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_curr] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_curr] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_curr] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_curr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_curr] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_curr', NULL, NULL
GO

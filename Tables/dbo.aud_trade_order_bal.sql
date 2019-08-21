CREATE TABLE [dbo].[aud_trade_order_bal]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_settlement_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_min_qty] [float] NULL,
[bal_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_deadline_date] [datetime] NULL,
[bal_mth] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_year] [smallint] NULL,
[bal_price] [float] NULL,
[bal_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_uom_conv_rate] [float] NULL,
[formula_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_bal] ON [dbo].[aud_trade_order_bal] ([trade_num], [order_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_bal_idx1] ON [dbo].[aud_trade_order_bal] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_order_bal] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_order_bal] TO [next_usr]
GO

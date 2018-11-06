CREATE TABLE [dbo].[aud_trade_item_cash_phy]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_settled_qty] [float] NULL,
[settled_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_imp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_exp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[margin_conv_factor] [float] NULL,
[cfd_swap_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[efs_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[execution_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_cash_phy] ON [dbo].[aud_trade_item_cash_phy] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_cash_phy_idx1] ON [dbo].[aud_trade_item_cash_phy] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_cash_phy] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_cash_phy] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_cash_phy] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_cash_phy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_cash_phy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_cash_phy', NULL, NULL
GO

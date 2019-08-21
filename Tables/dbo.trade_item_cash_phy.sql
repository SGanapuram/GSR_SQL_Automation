CREATE TABLE [dbo].[trade_item_cash_phy]
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
[execution_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk1] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk2] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk4] FOREIGN KEY ([min_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk5] FOREIGN KEY ([max_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_cash_phy] ADD CONSTRAINT [trade_item_cash_phy_fk6] FOREIGN KEY ([settled_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_cash_phy] TO [next_usr]
GO

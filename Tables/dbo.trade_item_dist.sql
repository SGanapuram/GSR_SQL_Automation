CREATE TABLE [dbo].[trade_item_dist]
(
[dist_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NULL,
[qpp_num] [smallint] NULL,
[pos_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[dist_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_synth_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bus_date] [datetime] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_qty] [float] NOT NULL,
[alloc_qty] [float] NOT NULL,
[discount_qty] [float] NOT NULL,
[priced_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom_conv_rate] [float] NULL,
[price_curr_code_conv_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_conv_rate] [float] NULL,
[price_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_conv_rate] [float] NULL,
[spread_pos_group_num] [int] NULL,
[delivered_qty] [float] NULL,
[open_pl] [float] NULL,
[pl_asof_date] [datetime] NULL,
[closed_pl] [float] NULL,
[addl_cost_sum] [float] NULL,
[sec_conversion_factor] [float] NULL,
[sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [bigint] NOT NULL,
[estimate_qty] [numeric] (20, 8) NULL,
[formula_num] [int] NULL,
[formula_body_num] [int] NULL,
[parcel_num] [int] NULL,
[parent_dist_num] [int] NULL,
[int_value] [int] NULL,
[float_value] [float] NULL,
[string_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_source_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_item_dist_equiv_source_ind] DEFAULT ('N'),
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exec_inv_num] [int] NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_pk] PRIMARY KEY CLUSTERED  ([dist_num]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx3] ON [dbo].[trade_item_dist] ([bus_date]) INCLUDE ([accum_num], [alloc_qty], [commkt_key], [delivered_qty], [discount_qty], [dist_num], [dist_qty], [dist_type], [formula_body_num], [formula_num], [is_equiv_ind], [item_num], [order_num], [p_s_ind], [pos_num], [price_curr_conv_rate], [priced_qty], [qpp_num], [qty_uom_code], [qty_uom_code_conv_to], [qty_uom_conv_rate], [real_port_num], [real_synth_ind], [sec_conversion_factor], [sec_qty_uom_code], [trade_num], [trading_prd]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_TS_idx90] ON [dbo].[trade_item_dist] ([dist_type], [real_synth_ind], [real_port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx2] ON [dbo].[trade_item_dist] ([pos_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx5] ON [dbo].[trade_item_dist] ([real_port_num]) INCLUDE ([accum_num], [alloc_qty], [bus_date], [commkt_key], [delivered_qty], [discount_qty], [dist_num], [dist_qty], [dist_type], [formula_body_num], [formula_num], [is_equiv_ind], [item_num], [order_num], [p_s_ind], [pos_num], [price_curr_conv_rate], [priced_qty], [qpp_num], [qty_uom_code], [qty_uom_code_conv_to], [qty_uom_conv_rate], [real_synth_ind], [sec_conversion_factor], [sec_qty_uom_code], [trade_num], [trading_prd]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx1] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [accum_num], [qpp_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx7] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [bus_date]) INCLUDE ([accum_num], [alloc_qty], [commkt_key], [delivered_qty], [discount_qty], [dist_num], [dist_qty], [dist_type], [formula_body_num], [formula_num], [is_equiv_ind], [p_s_ind], [pos_num], [price_curr_conv_rate], [priced_qty], [qpp_num], [qty_uom_code], [qty_uom_code_conv_to], [qty_uom_conv_rate], [real_port_num], [real_synth_ind], [sec_conversion_factor], [sec_qty_uom_code], [trading_prd]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx6] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [real_port_num], [dist_type], [is_equiv_ind], [what_if_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_dist_idx4] ON [dbo].[trade_item_dist] ([trade_num], [order_num], [item_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk10] FOREIGN KEY ([price_uom_code_conv_to]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk11] FOREIGN KEY ([sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk12] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk15] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk16] FOREIGN KEY ([exec_inv_num]) REFERENCES [dbo].[exec_phys_inv] ([exec_inv_num])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk2] FOREIGN KEY ([price_curr_code_conv_to]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk8] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dist] ADD CONSTRAINT [trade_item_dist_fk9] FOREIGN KEY ([qty_uom_code_conv_to]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_dist] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_dist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_dist] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_dist] TO [next_usr]
GO

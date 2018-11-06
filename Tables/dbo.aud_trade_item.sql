CREATE TABLE [dbo].[aud_trade_item]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[item_status_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty] [float] NULL,
[contr_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accum_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_conv_rate] [float] NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_priced_qty] [float] NULL,
[priced_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_bb_ref_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_contr_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_profit_center] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_acct_alloc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[brkr_num] [int] NULL,
[brkr_cont_num] [int] NULL,
[brkr_comm_amt] [float] NULL,
[brkr_comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fut_trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_item_num] [smallint] NULL,
[real_port_num] [int] NULL,
[amend_num] [smallint] NULL,
[amend_creation_date] [datetime] NULL,
[amend_effect_start_date] [datetime] NULL,
[amend_effect_end_date] [datetime] NULL,
[summary_item_num] [smallint] NULL,
[pooling_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pooling_port_num] [int] NULL,
[pooling_port_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_sch_qty] [float] NULL,
[sch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[open_qty] [float] NULL,
[open_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_pl] [float] NULL,
[mtm_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_pl_as_of_date] [datetime] NULL,
[strip_item_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[estimate_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[billing_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sched_status] [smallint] NULL,
[hedge_rate] [float] NULL,
[hedge_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[hedge_multi_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[recap_item_num] [int] NULL,
[hedge_pos_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[addl_cost_sum] [float] NULL,
[contr_mtm_pl] [float] NULL,
[max_accum_num] [smallint] NULL,
[formula_declar_date] [datetime] NULL,
[purchasing_group] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[excp_addns_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[internal_parent_trade_num] [int] NULL,
[internal_parent_order_num] [smallint] NULL,
[internal_parent_item_num] [smallint] NULL,
[trade_modified_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[item_confirm_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[finance_bank_num] [int] NULL,
[agreement_num] [int] NULL,
[active_status_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_value] [numeric] (20, 8) NULL,
[includes_excise_tax_ind] [bit] NOT NULL CONSTRAINT [DF__aud_trade__inclu__4B380934] DEFAULT ((0)),
[includes_fuel_tax_ind] [bit] NOT NULL CONSTRAINT [DF__aud_trade__inclu__4C2C2D6D] DEFAULT ((0)),
[total_committed_qty] [numeric] (20, 8) NULL,
[committed_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_cleared_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_service_num] [int] NULL,
[exch_brkr_num] [int] NULL,
[rin_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_lc_assigned] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_rc_assigned] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[b2b_trade_item] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_order_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_mkt_formula_for_pl] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_trade__use_m__6F8121F9] DEFAULT ('Y')
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_idx5] ON [dbo].[aud_trade_item] ([real_port_num], [item_type], [trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_idx] ON [dbo].[aud_trade_item] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_idx3] ON [dbo].[aud_trade_item] ([trade_num], [order_num], [parent_item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_trade_item] ON [dbo].[aud_trade_item] ([trading_prd], [risk_mkt_code], [cmdty_code], [item_num], [order_num], [trade_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_idx4] ON [dbo].[aud_trade_item] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_idx2] ON [dbo].[aud_trade_item] ([trans_id], [trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item', NULL, NULL
GO

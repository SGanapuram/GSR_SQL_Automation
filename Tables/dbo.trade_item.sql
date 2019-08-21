CREATE TABLE [dbo].[trade_item]
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
[internal_parent_trade_num] [int] NULL,
[internal_parent_order_num] [smallint] NULL,
[internal_parent_item_num] [smallint] NULL,
[trade_modified_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_item_trade_modified_ind] DEFAULT ('N'),
[item_confirm_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_item_item_confirm_ind] DEFAULT ('N'),
[finance_bank_num] [int] NULL,
[agreement_num] [int] NULL,
[active_status_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_item_active_status_ind] DEFAULT ('Y'),
[market_value] [numeric] (20, 8) NULL,
[includes_excise_tax_ind] [bit] NOT NULL CONSTRAINT [df_trade_item_includes_excise_tax_ind] DEFAULT ((0)),
[includes_fuel_tax_ind] [bit] NOT NULL CONSTRAINT [df_trade_item_includes_fuel_tax_ind] DEFAULT ((0)),
[total_committed_qty] [numeric] (20, 8) NULL,
[committed_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_cleared_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_service_num] [int] NULL,
[exch_brkr_num] [int] NULL,
[rin_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_lc_assigned] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_is_lc_assigned] DEFAULT ('N'),
[is_rc_assigned] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_is_rc_assigned] DEFAULT ('N'),
[b2b_trade_item] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_mkt_formula_for_pl] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_item_use_mkt_formula_for_pl] DEFAULT ('Y'),
[sap_order_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_quote_period_id] [int] NULL,
[quote_id] [int] NULL,
[leg_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flat_amt] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx92] ON [dbo].[trade_item] ([booking_comp_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx91] ON [dbo].[trade_item] ([brkr_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx90] ON [dbo].[trade_item] ([cmdty_code], [risk_mkt_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx94] ON [dbo].[trade_item] ([cmnt_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx201] ON [dbo].[trade_item] ([internal_parent_trade_num], [internal_parent_order_num], [internal_parent_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx6] ON [dbo].[trade_item] ([pooling_port_num], [real_port_num]) INCLUDE ([item_num], [order_num], [trade_num]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx5] ON [dbo].[trade_item] ([real_port_num], [formula_ind]) INCLUDE ([avg_price], [cmdty_code], [contr_qty], [hedge_curr_code], [hedge_multi_div_ind], [hedge_rate], [item_num], [item_status_code], [item_type], [market_value], [order_num], [p_s_ind], [price_curr_code], [price_uom_code], [sched_status], [total_priced_qty], [trade_modified_ind], [trade_num], [use_mkt_formula_for_pl]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx93] ON [dbo].[trade_item] ([risk_mkt_code], [cmdty_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_POSGRID_idx1] ON [dbo].[trade_item] ([trade_num], [order_num], [cmnt_num]) INCLUDE ([contr_qty], [contr_qty_uom_code], [idms_acct_alloc], [item_num], [p_s_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx4] ON [dbo].[trade_item] ([trade_num], [order_num], [item_num], [item_type], [real_port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx2] ON [dbo].[trade_item] ([trade_num], [order_num], [parent_item_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx1] ON [dbo].[trade_item] ([trade_num], [order_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx3] ON [dbo].[trade_item] ([trade_num], [trans_id]) INCLUDE ([item_num], [order_num]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk1] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk10] FOREIGN KEY ([origin_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk11] FOREIGN KEY ([excp_addns_code]) REFERENCES [dbo].[exceptions_additions] ([excp_addns_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk12] FOREIGN KEY ([gtc_code]) REFERENCES [dbo].[gtc] ([gtc_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk13] FOREIGN KEY ([fut_trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk14] FOREIGN KEY ([load_port_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk15] FOREIGN KEY ([disch_port_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk16] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk17] FOREIGN KEY ([title_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk2] FOREIGN KEY ([brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk22] FOREIGN KEY ([contr_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk23] FOREIGN KEY ([priced_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk24] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk25] FOREIGN KEY ([brkr_comm_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk26] FOREIGN KEY ([sch_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk3] FOREIGN KEY ([brkr_num], [brkr_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk30] FOREIGN KEY ([finance_bank_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk31] FOREIGN KEY ([agreement_num]) REFERENCES [dbo].[account_agreement] ([agreement_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk32] FOREIGN KEY ([committed_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk33] FOREIGN KEY ([clr_service_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk34] FOREIGN KEY ([exch_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk35] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk5] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk6] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk7] FOREIGN KEY ([brkr_comm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk8] FOREIGN KEY ([mtm_pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk9] FOREIGN KEY ([hedge_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[trade_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item] TO [next_usr]
GO

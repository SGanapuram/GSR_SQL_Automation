CREATE TABLE [dbo].[aud_trade_item_wet_phy]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[del_date_est_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pipeline_cycle_num] [int] NULL,
[timing_cycle_year] [smallint] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_imp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_exp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [float] NULL,
[tol_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_ship_qty] [float] NULL,
[min_ship_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[partial_deadline_date] [datetime] NULL,
[partial_res_inc_amt] [float] NULL,
[sch_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_ship_num] [smallint] NULL,
[parcel_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[taken_to_sch_pos_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_lifting_days] [smallint] NULL,
[proc_deal_delivery_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_event_spec] [smallint] NULL,
[item_petroex_num] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_transfer_doc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lease_num] [int] NULL,
[lease_ver_num] [int] NULL,
[dest_trade_num] [int] NULL,
[dest_order_num] [smallint] NULL,
[dest_item_num] [smallint] NULL,
[density_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[cost_adj_qty_1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_adj_qty_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pp_qty_adj_rule_num] [int] NULL,
[imp_rec_reason_oid] [int] NULL,
[prelim_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prelim_price] [numeric] (20, 8) NULL,
[prelim_qty_base] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prelim_percentage] [numeric] (20, 8) NULL,
[prelim_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prelim_due_date] [datetime] NULL,
[declar_date_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[declar_rel_days] [smallint] NULL,
[tax_qualification_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_num] [int] NULL,
[estimate_qty] [numeric] (20, 8) NULL,
[b2b_sale_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_approver_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_approval_date] [datetime] NULL,
[heat_adj_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[int_val] [int] NULL,
[float_val] [float] NULL,
[str_val] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_wet_phy] ON [dbo].[aud_trade_item_wet_phy] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_wet_phy_idx1] ON [dbo].[aud_trade_item_wet_phy] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_wet_phy] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_wet_phy] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_wet_phy] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_wet_phy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_wet_phy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_wet_phy', NULL, NULL
GO

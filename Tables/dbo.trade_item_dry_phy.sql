CREATE TABLE [dbo].[trade_item_dry_phy]
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
[wet_qty] [numeric] (20, 8) NULL,
[dry_qty] [numeric] (20, 8) NULL,
[franchise_charge] [numeric] (20, 8) NULL,
[heat_adj_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sublots_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[umpire_rule_num] [int] NULL,
[trans_id] [int] NOT NULL,
[int_val] [int] NULL,
[float_val] [float] NULL,
[str_val] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk1] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk10] FOREIGN KEY ([max_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk11] FOREIGN KEY ([tol_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk12] FOREIGN KEY ([min_ship_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk15] FOREIGN KEY ([prelim_pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk18] FOREIGN KEY ([tank_num]) REFERENCES [dbo].[location_tank_info] ([tank_num])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk19] FOREIGN KEY ([facility_code]) REFERENCES [dbo].[facility] ([facility_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk2] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk20] FOREIGN KEY ([credit_approver_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk21] FOREIGN KEY ([umpire_rule_num]) REFERENCES [dbo].[umpire_rule] ([rule_num])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk3] FOREIGN KEY ([sch_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk4] FOREIGN KEY ([del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk5] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk6] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk9] FOREIGN KEY ([min_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO

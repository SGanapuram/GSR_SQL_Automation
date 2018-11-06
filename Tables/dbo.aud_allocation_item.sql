CREATE TABLE [dbo].[aud_allocation_item]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[alloc_item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_item_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sub_alloc_num] [smallint] NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[acct_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sch_qty] [float] NULL,
[sch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_date_from] [datetime] NOT NULL,
[nomin_date_to] [datetime] NOT NULL,
[nomin_qty_min] [float] NULL,
[nomin_qty_min_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_qty_max] [float] NULL,
[nomin_qty_max_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_tran_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_tran_date] [datetime] NULL,
[origin_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dest_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [smallint] NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cr_clear_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_item_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[alloc_item_confirm] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_item_verify] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[auto_receipt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_gross_qty] [float] NULL,
[actual_gross_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fully_actualized] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ar_alloc_num] [int] NULL,
[ar_alloc_item_num] [smallint] NULL,
[inv_num] [int] NULL,
[insp_acct_num] [int] NULL,
[confirmation_date] [datetime] NULL,
[net_nom_num] [smallint] NULL,
[recap_item_num] [int] NULL,
[auto_receipt_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[final_dest_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_num] [int] NULL,
[reporting_date] [datetime] NULL,
[max_ai_est_actual_num] [smallint] NULL,
[inspection_date] [datetime] NULL,
[inspector_percent] [smallint] NULL,
[auto_sampling_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[auto_sampling_comp_num] [int] NULL,
[ship_agent_comp_num] [int] NULL,
[ship_broker_comp_num] [int] NULL,
[secondary_actual_qty] [float] NULL,
[load_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_actual_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[purchasing_group] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[vat_ind] [bit] NULL CONSTRAINT [DF__aud_alloc__vat_i__480696CE] DEFAULT ((0)),
[imp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imp_rec_reason_oid] [int] NULL,
[estimate_event_date] [datetime] NULL,
[finance_bank_num] [int] NULL,
[sap_delivery_num] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_delivery_line_item_num] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price] [numeric] (20, 8) NULL,
[transfer_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_currency_rate] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item] ON [dbo].[aud_allocation_item] ([alloc_num], [alloc_item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_idx1] ON [dbo].[aud_allocation_item] ([alloc_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_idx3] ON [dbo].[aud_allocation_item] ([inv_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_idx2] ON [dbo].[aud_allocation_item] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_idx4] ON [dbo].[aud_allocation_item] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_allocation_item] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_allocation_item] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_allocation_item] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_allocation_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_item', NULL, NULL
GO

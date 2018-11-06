CREATE TABLE [dbo].[aud_inventory]
(
[inv_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[sale_item_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pos_num] [int] NOT NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[storage_subloc_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_num] [int] NULL,
[inv_bal_from_date] [datetime] NOT NULL,
[inv_bal_to_date] [datetime] NOT NULL,
[inv_open_prd_proj_qty] [float] NULL,
[inv_open_prd_actual_qty] [float] NULL,
[inv_adj_qty] [float] NULL,
[inv_curr_proj_qty] [float] NULL,
[inv_curr_actual_qty] [float] NULL,
[inv_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_avg_cost] [float] NULL,
[inv_cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_cost_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[inv_rcpt_proj_qty] [float] NULL,
[inv_rcpt_actual_qty] [float] NULL,
[inv_dlvry_proj_qty] [float] NULL,
[inv_dlvry_actual_qty] [float] NULL,
[open_close_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_risk_mkt] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_risk_mkt] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[balance_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[line_fill_qty] [float] NULL,
[needs_repricing] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_loop_num] [int] NULL,
[inv_cnfrmd_qty] [float] NOT NULL,
[prev_inv_num] [int] NULL,
[next_inv_num] [int] NULL,
[inv_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[r_inv_avg_cost_amt] [float] NULL,
[unr_inv_avg_cost_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[inv_open_prd_proj_sec_qty] [float] NULL,
[inv_open_prd_actual_sec_qty] [float] NULL,
[inv_cnfrmd_sec_qty] [float] NULL,
[inv_adj_sec_qty] [float] NULL,
[inv_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_curr_proj_sec_qty] [float] NULL,
[inv_curr_actual_sec_qty] [float] NULL,
[inv_rcpt_proj_sec_qty] [float] NULL,
[inv_rcpt_actual_sec_qty] [float] NULL,
[inv_dlvry_proj_sec_qty] [float] NULL,
[inv_dlvry_actual_sec_qty] [float] NULL,
[inv_credit_exposure_oid] [int] NULL,
[inv_wacog_cost] [float] NULL,
[inv_bal_qty] [numeric] (20, 8) NULL,
[inv_bal_sec_qty] [numeric] (20, 8) NULL,
[inv_mac_cost] [numeric] (20, 8) NULL,
[mac_inv_amt] [numeric] (20, 8) NULL,
[inv_mac_insert_cost] [numeric] (20, 8) NULL,
[inv_fifo_cost] [numeric] (20, 8) NULL,
[roll_at_mkt_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_target_min_qty] [decimal] (20, 8) NULL,
[inv_target_max_qty] [decimal] (20, 8) NULL,
[inv_capacity] [decimal] (20, 8) NULL,
[inv_min_op_req_qty] [decimal] (20, 8) NULL,
[inv_safe_fill] [decimal] (20, 8) NULL,
[inv_heel] [decimal] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory] ON [dbo].[aud_inventory] ([inv_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory_idx1] ON [dbo].[aud_inventory] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_inventory] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_inventory] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_inventory] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_inventory] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inventory] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_inventory', NULL, NULL
GO

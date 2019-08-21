CREATE TABLE [dbo].[aud_inventory_build_draw]
(
[inv_num] [int] NOT NULL,
[inv_b_d_num] [int] NOT NULL,
[inv_b_d_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_b_d_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[adj_qty] [float] NULL,
[adj_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_b_d_date] [datetime] NULL,
[inv_b_d_qty] [float] NULL,
[inv_b_d_actual_qty] [float] NULL,
[inv_b_d_cost] [float] NULL,
[inv_b_d_cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_b_d_cost_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_draw_b_d_num] [smallint] NULL,
[inv_b_d_tax_status_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[pos_group_num] [int] NULL,
[r_inv_b_d_cost] [float] NULL,
[unr_inv_b_d_cost] [float] NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[adj_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_b_d_cost_wacog] [float] NULL,
[r_inv_b_d_cost_wacog] [float] NULL,
[unr_inv_b_d_cost_wacog] [float] NULL,
[inv_curr_actual_qty] [decimal] (20, 8) NULL,
[inv_curr_proj_qty] [decimal] (20, 8) NULL,
[associated_trade] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[associated_cpty] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory_build_draw] ON [dbo].[aud_inventory_build_draw] ([inv_num], [inv_b_d_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory_build_draw_idx1] ON [dbo].[aud_inventory_build_draw] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_inventory_build_draw] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inventory_build_draw] TO [next_usr]
GO

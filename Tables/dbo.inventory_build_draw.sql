CREATE TABLE [dbo].[inventory_build_draw]
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
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_pk] PRIMARY KEY CLUSTERED  ([inv_num], [inv_b_d_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_build_draw_idx2] ON [dbo].[inventory_build_draw] ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_build_draw_idx4] ON [dbo].[inventory_build_draw] ([inv_num], [alloc_num], [inv_b_d_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_build_draw_idx3] ON [dbo].[inventory_build_draw] ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk3] FOREIGN KEY ([inv_b_d_cost_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk6] FOREIGN KEY ([adj_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk7] FOREIGN KEY ([inv_b_d_cost_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk8] FOREIGN KEY ([voyage_code]) REFERENCES [dbo].[voyage] ([voyage_code])
GO
GRANT DELETE ON  [dbo].[inventory_build_draw] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory_build_draw] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory_build_draw] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory_build_draw] TO [next_usr]
GO

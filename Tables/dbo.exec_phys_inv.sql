CREATE TABLE [dbo].[exec_phys_inv]
(
[exec_inv_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[version_num] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_execution_oid] [int] NOT NULL,
[conc_del_item_oid] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[brand_id] [int] NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NOT NULL,
[pos_num] [int] NULL,
[inv_proj_qty] [float] NULL,
[inv_actual_qty] [float] NULL,
[inv_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_sec_proj_qty] [float] NULL,
[inv_sec_actual_qty] [float] NULL,
[inv_adj_qty] [float] NULL,
[inv_sec_adj_qty] [float] NULL,
[inv_unit_price] [float] NULL,
[inv_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[inv_matched_qty] [float] NULL,
[inv_matched_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_pk] PRIMARY KEY CLUSTERED  ([exec_inv_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk1] FOREIGN KEY ([trade_num], [order_num], [item_num]) REFERENCES [dbo].[trade_item] ([trade_num], [order_num], [item_num])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk2] FOREIGN KEY ([contract_execution_oid]) REFERENCES [dbo].[contract_execution] ([oid])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk3] FOREIGN KEY ([conc_del_item_oid]) REFERENCES [dbo].[conc_delivery_item] ([oid])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk4] FOREIGN KEY ([inv_matched_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[exec_phys_inv] ADD CONSTRAINT [exec_phys_inv_fk5] FOREIGN KEY ([inv_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[exec_phys_inv] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[exec_phys_inv] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[exec_phys_inv] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[exec_phys_inv] TO [next_usr]
GO

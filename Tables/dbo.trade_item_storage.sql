CREATE TABLE [dbo].[trade_item_storage]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[stored_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sublease_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_start_date] [datetime] NULL,
[storage_end_date] [datetime] NULL,
[storage_avail_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_prd] [int] NULL,
[storage_prd_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shrinkage_qty] [float] NULL,
[shrinkage_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loss_allowance_qty] [float] NULL,
[loss_allowance_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_operating_qty] [float] NULL,
[min_operating_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_subloc_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[pipeline_cycle_num] [int] NULL,
[timing_cycle_year] [smallint] NULL,
[tank_num] [int] NULL,
[target_min_qty] [decimal] (20, 8) NULL,
[target_max_qty] [decimal] (20, 8) NULL,
[capacity] [decimal] (20, 8) NULL,
[min_op_req_qty] [decimal] (20, 8) NULL,
[safe_fill] [decimal] (20, 8) NULL,
[heel] [decimal] (20, 8) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk1] FOREIGN KEY ([stored_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk10] FOREIGN KEY ([loss_allowance_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk11] FOREIGN KEY ([min_operating_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk12] FOREIGN KEY ([pipeline_cycle_num]) REFERENCES [dbo].[pipeline_cycle] ([pipeline_cycle_num])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk13] FOREIGN KEY ([tank_num]) REFERENCES [dbo].[location_tank_info] ([tank_num])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk2] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk3] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk4] FOREIGN KEY ([storage_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk5] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk6] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk8] FOREIGN KEY ([storage_prd_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_storage] ADD CONSTRAINT [trade_item_storage_fk9] FOREIGN KEY ([shrinkage_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_storage] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_storage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_storage] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_storage] TO [next_usr]
GO

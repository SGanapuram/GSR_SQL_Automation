CREATE TABLE [dbo].[conc_delivery_item]
(
[oid] [int] NOT NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_status_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_qty] [float] NULL,
[actual_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_execution_oid] [int] NULL,
[title_document_num] [int] NULL,
[cmnt_num] [int] NULL,
[total_exec_qty] [float] NULL,
[total_exec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_qty] [float] NULL,
[del_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[conc_delivery_schedule_oid] [int] NULL,
[prorated_flat_amt] [float] NULL,
[flat_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_delivery_lot_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk10] FOREIGN KEY ([total_exec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk11] FOREIGN KEY ([del_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk12] FOREIGN KEY ([conc_delivery_schedule_oid]) REFERENCES [dbo].[conc_delivery_schedule] ([oid])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk13] FOREIGN KEY ([flat_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk3] FOREIGN KEY ([trade_num], [order_num], [item_num]) REFERENCES [dbo].[trade_item] ([trade_num], [order_num], [item_num])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk4] FOREIGN KEY ([min_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk5] FOREIGN KEY ([max_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk6] FOREIGN KEY ([contract_execution_oid]) REFERENCES [dbo].[contract_execution] ([oid])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk7] FOREIGN KEY ([title_document_num]) REFERENCES [dbo].[conc_document] ([oid])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk8] FOREIGN KEY ([cmnt_num]) REFERENCES [dbo].[comment] ([cmnt_num])
GO
ALTER TABLE [dbo].[conc_delivery_item] ADD CONSTRAINT [conc_delivery_item_fk9] FOREIGN KEY ([actual_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[conc_delivery_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_delivery_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_delivery_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_delivery_item] TO [next_usr]
GO

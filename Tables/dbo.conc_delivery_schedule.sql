CREATE TABLE [dbo].[conc_delivery_schedule]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NULL,
[version_num] [int] NULL,
[conc_prior_ver_oid] [int] NULL,
[quantity] [float] NULL,
[quantity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[additional_qty] [float] NULL,
[additional_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tolerance_qty] [float] NULL,
[tolerance_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dry_wet_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[moisture_percent] [float] NULL,
[moisture_precision] [int] NULL,
[franchise_charge] [numeric] (13, 8) NULL,
[tol_option] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[num_of_deliveries] [int] NULL,
[delivery_start_date] [datetime] NULL,
[trade_num] [int] NULL,
[prorated_flat_amt] [float] NULL,
[flat_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[custom_delivery_schedule_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_delivery_schedule] ADD CONSTRAINT [conc_delivery_schedule_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_delivery_schedule] ADD CONSTRAINT [conc_delivery_schedule_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_delivery_schedule] ADD CONSTRAINT [conc_delivery_schedule_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_delivery_schedule] ADD CONSTRAINT [conc_delivery_schedule_fk3] FOREIGN KEY ([flat_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[conc_delivery_schedule] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_delivery_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_delivery_schedule] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_delivery_schedule] TO [next_usr]
GO

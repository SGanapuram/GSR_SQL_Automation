CREATE TABLE [dbo].[allocation_item_transport]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parcel_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[x_transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[barge_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fsc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lay_days_start_date] [datetime] NULL,
[lay_days_end_date] [datetime] NULL,
[eta_date] [datetime] NULL,
[bl_date] [datetime] NULL,
[nor_date] [datetime] NULL,
[load_cmnc_date] [datetime] NULL,
[load_compl_date] [datetime] NULL,
[disch_cmnc_date] [datetime] NULL,
[disch_compl_date] [datetime] NULL,
[bl_qty] [float] NULL,
[bl_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bl_qty_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_qty] [float] NULL,
[load_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_qty_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_qty] [float] NULL,
[disch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_qty_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pump_on_date] [datetime] NULL,
[pump_off_date] [datetime] NULL,
[bl_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bl_ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_disch_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_disch_ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_disch_date] [datetime] NULL,
[hoses_disconnected_date] [datetime] NULL,
[bl_sec_qty] [float] NULL,
[load_sec_qty] [float] NULL,
[disch_sec_qty] [float] NULL,
[bl_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_input_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_allocation_item_transport_manual_input_sec_ind] DEFAULT ('N'),
[load_net_qty] [float] NULL,
[disch_net_qty] [float] NULL,
[bl_net_qty] [float] NULL,
[load_sec_net_qty] [float] NULL,
[disch_sec_net_qty] [float] NULL,
[bl_sec_net_qty] [float] NULL,
[trans_id] [int] NOT NULL,
[customs_imp_exp_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[declaration_date] [datetime] NULL,
[tank_num] [int] NULL,
[transport_arrival_date] [datetime] NULL,
[transport_depart_date] [datetime] NULL,
[hoses_connected_date] [datetime] NULL,
[negotiated_date] [datetime] NULL,
[nor_accp_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk2] FOREIGN KEY ([origin_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk3] FOREIGN KEY ([bl_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk4] FOREIGN KEY ([load_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk5] FOREIGN KEY ([disch_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk6] FOREIGN KEY ([bl_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk7] FOREIGN KEY ([load_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk8] FOREIGN KEY ([disch_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk9] FOREIGN KEY ([tank_num]) REFERENCES [dbo].[location_tank_info] ([tank_num])
GO
GRANT DELETE ON  [dbo].[allocation_item_transport] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_item_transport] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_item_transport] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_item_transport] TO [next_usr]
GO

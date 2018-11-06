CREATE TABLE [dbo].[TI_demand_forecast]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tsw_location] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[customer_vendor_code] [int] NULL,
[finished_product] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material_number] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[class_of_trade] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_number] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[agreement_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[timebucket] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[volume] [numeric] (18, 3) NULL,
[uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[forecast_cycle] [char] (7) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_1] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_1_qty] [numeric] (18, 3) NULL,
[comp_material_2] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_2_qty] [numeric] (18, 3) NULL,
[comp_material_3] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_3_qty] [numeric] (18, 3) NULL,
[comp_material_4] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_4_qty] [numeric] (18, 3) NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_demand_forecast] ADD CONSTRAINT [TI_demand_forecast_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TI_demand_forecast] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_demand_forecast] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_demand_forecast] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_demand_forecast] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_demand_forecast', NULL, NULL
GO

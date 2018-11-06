CREATE TABLE [dbo].[TI_RS_refinery_plan]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[refinery] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[forecast_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_date] [datetime] NULL,
[version] [datetime] NULL,
[prod_forecast] [numeric] (18, 3) NULL,
[uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[end_date] [datetime] NULL,
[pw_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_RS_refinery_plan] ADD CONSTRAINT [TI_RS_refinery_plan_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_RS_refinery_plan] ADD CONSTRAINT [TI_RS_refinery_plan_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_RS_refinery_plan] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_RS_refinery_plan] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_RS_refinery_plan] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_RS_refinery_plan] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_RS_refinery_plan', NULL, NULL
GO

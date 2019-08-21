CREATE TABLE [dbo].[TI_refinery_actual]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[date] [datetime] NULL,
[rate] [numeric] (18, 3) NULL,
[pw_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_refinery_actual] ADD CONSTRAINT [TI_refinery_actual_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_refinery_actual] ADD CONSTRAINT [TI_refinery_actual_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_refinery_actual] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_refinery_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_refinery_actual] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_refinery_actual] TO [next_usr]
GO

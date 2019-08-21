CREATE TABLE [dbo].[TI_rate_table]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[quotation_number] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[base_location] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alternate_location] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quotation_date] [datetime] NULL,
[quotation_price] [numeric] (18, 3) NULL,
[price_quotation_curr] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_quotation_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quotation_price_unit] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[change_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_rate_table] ADD CONSTRAINT [TI_rate_tabl_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_rate_table] ADD CONSTRAINT [TI_rate_table_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_rate_table] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_rate_table] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_rate_table] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_rate_table] TO [next_usr]
GO

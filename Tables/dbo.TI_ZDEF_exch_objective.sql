CREATE TABLE [dbo].[TI_ZDEF_exch_objective]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[exchange_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_item] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[delivery_receipt_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[location] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exchange_objective] [numeric] (18, 3) NULL,
[uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_ZDEF_exch_objective] ADD CONSTRAINT [TI_ZDEF_exch_objective_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_ZDEF_exch_objective] ADD CONSTRAINT [TI_ZDEF_exch_objective_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_ZDEF_exch_objective] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_ZDEF_exch_objective] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_ZDEF_exch_objective] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_ZDEF_exch_objective] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_ZDEF_exch_objective', NULL, NULL
GO

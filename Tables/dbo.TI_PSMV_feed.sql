CREATE TABLE [dbo].[TI_PSMV_feed]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[material_doc_number] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material_doc_year] [int] NULL,
[material_doc_item] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[movement_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volume] [numeric] (18, 3) NULL,
[uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[issue_location] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[receive_location] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_key] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_key_item] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_item] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reversal_material_doc_number] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reversal_material_doc_year] [int] NULL,
[reversal_material_doc_item] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[delivery_date] [datetime] NULL,
[posting_date] [datetime] NULL,
[document_date] [datetime] NULL,
[create_date] [datetime] NULL,
[schedule_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reference_document_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[movement_volume_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_1] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_1_qty] [numeric] (18, 3) NULL,
[comp_material_2] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_2_qty] [numeric] (18, 3) NULL,
[comp_material_3] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_3_qty] [numeric] (18, 3) NULL,
[comp_material_4] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_4_qty] [numeric] (18, 3) NULL,
[pw_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_issue_location] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_receive_location] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[in_transit_plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_new_nomin_key] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_PSMV_feed] ADD CONSTRAINT [TI_PSMV_feed_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_PSMV_feed] ADD CONSTRAINT [TI_PSMV_feed_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_PSMV_feed] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_PSMV_feed] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_PSMV_feed] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_PSMV_feed] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_PSMV_feed', NULL, NULL
GO

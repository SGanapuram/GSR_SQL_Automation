CREATE TABLE [dbo].[TI_PSMVol_spot]
(
[oid] [int] NOT NULL,
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
[comp_material_5] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_5_qty] [numeric] (18, 3) NULL,
[comp_material_6] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_6_qty] [numeric] (18, 3) NULL,
[comp_material_7] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_7_qty] [numeric] (18, 3) NULL,
[comp_material_8] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_8_qty] [numeric] (18, 3) NULL,
[comp_material_9] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_9_qty] [numeric] (18, 3) NULL,
[comp_material_10] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_10_qty] [numeric] (18, 3) NULL,
[pw_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_issue_location] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_receive_location] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_PSMVol_spot] ADD CONSTRAINT [TI_PSMVol_spot_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TI_PSMVol_spot] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_PSMVol_spot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_PSMVol_spot] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_PSMVol_spot] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_PSMVol_spot', NULL, NULL
GO

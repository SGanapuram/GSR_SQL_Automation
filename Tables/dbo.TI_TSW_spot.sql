CREATE TABLE [dbo].[TI_TSW_spot]
(
[oid] [int] NOT NULL,
[nomination_key] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nomination_key_item] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nomination_item_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[in_transit_plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomination_ref_doc_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomination_ref_doc_item] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reference_document_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[schedule_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scheduled_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scheduled_quantity] [numeric] (18, 3) NULL,
[scheduled_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scheduled_date] [datetime] NULL,
[mot] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_location_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_TSW_spot] ADD CONSTRAINT [TI_TSW_spot_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TI_TSW_spot] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_TSW_spot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_TSW_spot] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_TSW_spot] TO [next_usr]
GO

CREATE TABLE [dbo].[TI_PSMVal_feed]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[material_doc_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material_doc_year] [int] NULL,
[material_doc_item] [int] NULL,
[document_date] [datetime] NULL,
[material_code] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[movement_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomination_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomination_key_item] [int] NULL,
[contract_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_line_item] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[profit_center] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_center] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_condition_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_condition_item] [int] NULL,
[condition_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calc_type_c_quantity] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[condition_value] [numeric] (18, 3) NULL,
[condition_rate] [numeric] (18, 3) NULL,
[condition_price_unit] [numeric] (18, 3) NULL,
[currency] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[delivery_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_PSMVal_feed] ADD CONSTRAINT [TI_PSMVal_feed_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_PSMVal_feed] ADD CONSTRAINT [TI_PSMVal_feed_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_PSMVal_feed] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_PSMVal_feed] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_PSMVal_feed] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_PSMVal_feed] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_PSMVal_feed', NULL, NULL
GO

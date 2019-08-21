CREATE TABLE [dbo].[TI_financial_results]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[fiscal_year] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[line_item] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[company_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_date] [datetime] NULL,
[posting_date] [datetime] NULL,
[posting_period] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[business_transaction] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[posting_key] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[account_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[account] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[currency] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_currency_amt] [numeric] (18, 3) NULL,
[company_currency_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[group_currency_amt] [numeric] (18, 3) NULL,
[quantity] [numeric] (18, 3) NULL,
[uom] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assignment_num] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material_num] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[controlling_area] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_center] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[profit_center] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[item_text] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[local_currency_amt] [numeric] (18, 3) NULL,
[group_currency_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[movement_document_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[movement_document_year] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_financial_results] ADD CONSTRAINT [TI_financial_results_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_financial_results] ADD CONSTRAINT [TI_financial_results_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_financial_results] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_financial_results] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_financial_results] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_financial_results] TO [next_usr]
GO

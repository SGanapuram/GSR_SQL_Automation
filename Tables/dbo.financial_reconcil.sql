CREATE TABLE [dbo].[financial_reconcil]
(
[oid] [int] NOT NULL,
[document_date] [datetime] NULL,
[material_doc_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material_doc_year] [int] NULL,
[material_doc_item] [int] NULL,
[material_code] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[condition_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[condition_value] [numeric] (18, 3) NULL,
[condition_rate] [numeric] (18, 3) NULL,
[currency] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SAP_agreement_num] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SAP_contract_num] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SAP_line_item_num] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[profit_center] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[movement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[reconcil_port_num] [int] NULL,
[reconcil_cost_num] [int] NULL,
[trans_id] [int] NOT NULL,
[etl_timestamp] [datetime] NULL,
[source_feed] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[financial_reconcil] ADD CONSTRAINT [chk_financial_reconcil_source_feed] CHECK (([source_feed]='F' OR [source_feed]='P'))
GO
ALTER TABLE [dbo].[financial_reconcil] ADD CONSTRAINT [financial_reconcil_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[financial_reconcil] ADD CONSTRAINT [financial_reconcil_fk1] FOREIGN KEY ([trade_num], [order_num], [item_num]) REFERENCES [dbo].[trade_item] ([trade_num], [order_num], [item_num])
GO
ALTER TABLE [dbo].[financial_reconcil] ADD CONSTRAINT [financial_reconcil_fk2] FOREIGN KEY ([reconcil_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[financial_reconcil] ADD CONSTRAINT [financial_reconcil_fk3] FOREIGN KEY ([reconcil_cost_num]) REFERENCES [dbo].[cost] ([cost_num])
GO
GRANT DELETE ON  [dbo].[financial_reconcil] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[financial_reconcil] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[financial_reconcil] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[financial_reconcil] TO [next_usr]
GO

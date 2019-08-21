CREATE TABLE [dbo].[qp_option]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[quote_index] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[quote_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quote_point] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_string] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qp_option] ADD CONSTRAINT [qp_option_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qp_option] ADD CONSTRAINT [qp_option_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[qp_option] ADD CONSTRAINT [qp_option_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
GRANT DELETE ON  [dbo].[qp_option] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qp_option] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qp_option] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qp_option] TO [next_usr]
GO

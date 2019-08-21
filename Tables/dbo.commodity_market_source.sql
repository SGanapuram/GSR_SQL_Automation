CREATE TABLE [dbo].[commodity_market_source]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dflt_alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tvm_use_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[option_eval_use_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[financial_borrow_use_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[financial_lend_use_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quote_price_precision] [tinyint] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_market_source] ADD CONSTRAINT [commodity_market_source_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [price_source_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_market_source] ADD CONSTRAINT [commodity_market_source_fk1] FOREIGN KEY ([dflt_alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
ALTER TABLE [dbo].[commodity_market_source] ADD CONSTRAINT [commodity_market_source_fk2] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
ALTER TABLE [dbo].[commodity_market_source] ADD CONSTRAINT [commodity_market_source_fk3] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[commodity_market_source] ADD CONSTRAINT [commodity_market_source_fk4] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
GRANT DELETE ON  [dbo].[commodity_market_source] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_market_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_market_source] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_market_source] TO [next_usr]
GO

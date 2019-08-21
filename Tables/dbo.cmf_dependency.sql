CREATE TABLE [dbo].[cmf_dependency]
(
[cmf_num] [int] NOT NULL,
[commkt_key] [int] NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_trade_date] [datetime] NULL,
[sub_cmf_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cmf_dependency] ADD CONSTRAINT [cmf_dependency_fk1] FOREIGN KEY ([cmf_num]) REFERENCES [dbo].[commodity_market_formula] ([cmf_num])
GO
GRANT DELETE ON  [dbo].[cmf_dependency] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cmf_dependency] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cmf_dependency] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cmf_dependency] TO [next_usr]
GO

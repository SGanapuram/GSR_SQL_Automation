CREATE TABLE [dbo].[cmf_for_price_update]
(
[cmf_num] [int] NOT NULL,
[upd_commkt_key] [int] NOT NULL,
[upd_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[upd_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[upd_price_quote_date] [datetime] NOT NULL,
[sub_cmf_num] [int] NULL,
[processing_status] [tinyint] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cmf_for_price_update] ADD CONSTRAINT [cmf_for_price_update_fk1] FOREIGN KEY ([cmf_num]) REFERENCES [dbo].[commodity_market_formula] ([cmf_num])
GO
GRANT DELETE ON  [dbo].[cmf_for_price_update] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cmf_for_price_update] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cmf_for_price_update] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cmf_for_price_update] TO [next_usr]
GO

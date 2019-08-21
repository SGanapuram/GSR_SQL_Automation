CREATE TABLE [dbo].[aud_commodity_market_source]
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
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_market_source] ON [dbo].[aud_commodity_market_source] ([commkt_key], [price_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_market_sou_idx1] ON [dbo].[aud_commodity_market_source] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commodity_market_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_market_source] TO [next_usr]
GO

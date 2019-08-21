CREATE TABLE [dbo].[aud_market_price_quote_dates]
(
[cmf_num] [int] NOT NULL,
[calendar_date] [datetime] NOT NULL,
[quote_date] [datetime] NOT NULL,
[priced_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[end_of_period_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fiscal_month] [smallint] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_markt_price_quo_dates_idx] ON [dbo].[aud_market_price_quote_dates] ([cmf_num], [calendar_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_market_price_quote_dates] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_price_quote_dates] TO [next_usr]
GO

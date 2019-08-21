CREATE TABLE [dbo].[aud_market_pricing_condition]
(
[cmf_num] [int] NOT NULL,
[mkt_pricing_cond_num] [smallint] NOT NULL,
[mkt_cond_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_cond_date] [datetime] NULL,
[mkt_cond_quote_range] [tinyint] NULL,
[mkt_cond_last_next_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_pricing_cond_idx] ON [dbo].[aud_market_pricing_condition] ([cmf_num], [mkt_pricing_cond_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_market_pricing_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_pricing_condition] TO [next_usr]
GO

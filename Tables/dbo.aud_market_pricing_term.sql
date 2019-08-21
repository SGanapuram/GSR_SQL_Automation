CREATE TABLE [dbo].[aud_market_pricing_term]
(
[mpt_num] [int] NOT NULL,
[mkt_pricing_term_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_pricing_term_period_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_pricing_method_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_pricing_term_idx] ON [dbo].[aud_market_pricing_term] ([mpt_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_market_pricing_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_pricing_term] TO [next_usr]
GO

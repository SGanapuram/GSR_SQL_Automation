CREATE TABLE [dbo].[market_pricing_condition]
(
[cmf_num] [int] NOT NULL,
[mkt_pricing_cond_num] [smallint] NOT NULL,
[mkt_cond_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_cond_date] [datetime] NULL,
[mkt_cond_quote_range] [tinyint] NULL,
[mkt_cond_last_next_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[market_pricing_condition] ADD CONSTRAINT [market_pricing_condition_pk] PRIMARY KEY CLUSTERED  ([cmf_num], [mkt_pricing_cond_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[market_pricing_condition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[market_pricing_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[market_pricing_condition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[market_pricing_condition] TO [next_usr]
GO

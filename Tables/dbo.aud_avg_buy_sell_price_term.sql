CREATE TABLE [dbo].[aud_avg_buy_sell_price_term]
(
[formula_num] [int] NOT NULL,
[roll_days] [smallint] NULL,
[exclusion_days] [smallint] NULL,
[determination_opt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[determination_mths_num] [tinyint] NULL,
[price_term_start_date] [datetime] NOT NULL,
[price_term_end_date] [datetime] NOT NULL,
[quote_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_seller_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[all_quotes_reqd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_avg_buy_sell_price_term] ON [dbo].[aud_avg_buy_sell_price_term] ([formula_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_avg_buy_sell_price_t_idx1] ON [dbo].[aud_avg_buy_sell_price_term] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_avg_buy_sell_price_term] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_avg_buy_sell_price_term] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_avg_buy_sell_price_term] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_avg_buy_sell_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_avg_buy_sell_price_term] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_avg_buy_sell_price_term', NULL, NULL
GO

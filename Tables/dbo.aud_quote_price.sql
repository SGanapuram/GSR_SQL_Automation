CREATE TABLE [dbo].[aud_quote_price]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[qpp_num] [smallint] NOT NULL,
[nominal_date] [datetime] NOT NULL,
[price_quote_date] [datetime] NOT NULL,
[final_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_used_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_override_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_quote_price] ON [dbo].[aud_quote_price] ([nominal_date], [qpp_num], [accum_num], [item_num], [order_num], [trade_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_price_idx] ON [dbo].[aud_quote_price] ([trade_num], [order_num], [item_num], [accum_num], [qpp_num], [nominal_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_price_idx1] ON [dbo].[aud_quote_price] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_quote_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quote_price] TO [next_usr]
GO

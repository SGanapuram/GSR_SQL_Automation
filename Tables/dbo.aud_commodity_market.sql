CREATE TABLE [dbo].[aud_commodity_market]
(
[commkt_key] [int] NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mtm_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[man_input_sec_qty_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_market] ON [dbo].[aud_commodity_market] ([commkt_key], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_market_idx1] ON [dbo].[aud_commodity_market] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commodity_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_market] TO [next_usr]
GO

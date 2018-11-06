CREATE TABLE [dbo].[aud_position_mark_to_market]
(
[pos_num] [int] NOT NULL,
[mtm_asof_date] [datetime] NOT NULL,
[mtm_mkt_price] [float] NULL,
[mtm_mkt_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_mkt_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_mkt_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility] [float] NULL,
[interest_rate] [float] NULL,
[delta] [float] NULL,
[gamma] [float] NULL,
[theta] [float] NULL,
[vega] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_mark_to_market] ON [dbo].[aud_position_mark_to_market] ([pos_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_mark_to_mar_idx1] ON [dbo].[aud_position_mark_to_market] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_position_mark_to_market] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_position_mark_to_market] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_position_mark_to_market] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_position_mark_to_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_position_mark_to_market] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_position_mark_to_market', NULL, NULL
GO

CREATE TABLE [dbo].[position_mark_to_market]
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
[trans_id] [bigint] NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_pk] PRIMARY KEY NONCLUSTERED  ([pos_num], [mtm_asof_date]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [position_mark_to_market_idx1] ON [dbo].[position_mark_to_market] ([mtm_asof_date]) WITH (FILLFACTOR=90, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk1] FOREIGN KEY ([mtm_mkt_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk2] FOREIGN KEY ([otc_opt_code]) REFERENCES [dbo].[otc_option] ([otc_opt_code])
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk4] FOREIGN KEY ([mtm_mkt_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[position_mark_to_market] ADD CONSTRAINT [position_mark_to_market_fk5] FOREIGN KEY ([mtm_mkt_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[position_mark_to_market] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[position_mark_to_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[position_mark_to_market] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[position_mark_to_market] TO [next_usr]
GO

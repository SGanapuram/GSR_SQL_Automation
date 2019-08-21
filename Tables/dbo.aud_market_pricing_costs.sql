CREATE TABLE [dbo].[aud_market_pricing_costs]
(
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_amt] [float] NULL,
[cost_date] [datetime] NOT NULL,
[cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_pricing_costs_idx] ON [dbo].[aud_market_pricing_costs] ([mkt_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_market_pricing_costs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_pricing_costs] TO [next_usr]
GO

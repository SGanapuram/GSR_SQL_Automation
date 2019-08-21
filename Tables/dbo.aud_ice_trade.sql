CREATE TABLE [dbo].[aud_ice_trade]
(
[external_trade_oid] [int] NOT NULL,
[begin_date] [datetime] NULL,
[buyer_company_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clearing_firm_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[consummate_date] [datetime] NOT NULL,
[deal_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[deal_lot_size] [int] NULL,
[end_date] [datetime] NULL,
[hub] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_id] [int] NOT NULL,
[market_lot_size] [int] NULL,
[mkt_bprod_currency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_bprod_unit_price] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_bprod_units] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[number_of_cycles] [int] NOT NULL,
[order_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price] [float] NULL,
[qty_multiplied_out] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_company_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buyer_user_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[seller_user_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ice_trade] ON [dbo].[aud_ice_trade] ([external_trade_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ice_trade_idx1] ON [dbo].[aud_ice_trade] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ice_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ice_trade] TO [next_usr]
GO

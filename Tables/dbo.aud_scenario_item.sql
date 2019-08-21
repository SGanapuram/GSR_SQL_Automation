CREATE TABLE [dbo].[aud_scenario_item]
(
[oid] [int] NOT NULL,
[scenario_id] [int] NOT NULL,
[buy_sell_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_percent] [numeric] (20, 8) NOT NULL,
[port_num] [int] NOT NULL,
[opp_port_num] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_period] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[quote] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[differential] [numeric] (20, 8) NULL,
[price_start_date] [datetime] NULL,
[price_end_date] [datetime] NULL,
[load_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_start_date] [datetime] NULL,
[del_end_date] [datetime] NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_trade_num] [int] NULL,
[ref_order_num] [smallint] NULL,
[ref_item_num] [smallint] NULL,
[ref_alloc_num] [int] NULL,
[ref_alloc_item_num] [smallint] NULL,
[ref_sub_alloc_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_scenario_item] ON [dbo].[aud_scenario_item] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_scenario_item_idx1] ON [dbo].[aud_scenario_item] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_scenario_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_scenario_item] TO [next_usr]
GO

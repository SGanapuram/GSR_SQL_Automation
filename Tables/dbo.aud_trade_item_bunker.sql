CREATE TABLE [dbo].[aud_trade_item_bunker]
(
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[item_num] [int] NOT NULL,
[port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_agent_num] [int] NULL,
[storage_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_agent_num] [int] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[delivery_mot] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[eta_date] [datetime] NULL,
[del_date] [datetime] NULL,
[pricing_exp_date] [datetime] NULL,
[exp_time_zone_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[curr_exch_date] [datetime] NULL,
[transp_price_amt] [float] NULL,
[transp_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transp_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[handling_type_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [numeric] (20, 8) NULL,
[tol_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_opt] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [numeric] (30, 8) NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [numeric] (20, 8) NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_bunker_idx1] ON [dbo].[aud_trade_item_bunker] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_bunker_idx2] ON [dbo].[aud_trade_item_bunker] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_bunker] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_bunker] TO [next_usr]
GO

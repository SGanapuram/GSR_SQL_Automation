CREATE TABLE [dbo].[POSGRID_snapshot_pos_detail]
(
[asof_date] [datetime] NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_date] [datetime] NULL,
[trade_num] [int] NULL,
[trade_key] [varchar] (123) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[counterparty] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inhouse_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_type_desc] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_entity] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_group_tag] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[profit_center] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NULL,
[dist_num] [int] NULL,
[pos_num] [int] NULL,
[cmdty_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_key] [int] NULL,
[trading_prd] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[position_p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[primary_pos_qty] [float] NULL,
[secondary_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[secondary_pos_qty] [float] NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_qty] [float] NULL,
[mtm_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_hedge_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[grid_position_month] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[grid_position_qtr] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[grid_position_year] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_issue_date] [datetime] NULL,
[last_trade_date] [datetime] NULL,
[trade_mod_date] [datetime] NULL,
[trade_creation_date] [datetime] NULL,
[trans_id] [int] NULL,
[trading_entity_num] [int] NULL,
[pricing_risk_date] [datetime] NULL,
[product] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_num] [int] NULL,
[item_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [POSGRID_snapshot_pos_detail_idx1] ON [dbo].[POSGRID_snapshot_pos_detail] ([pos_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[POSGRID_snapshot_pos_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[POSGRID_snapshot_pos_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[POSGRID_snapshot_pos_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[POSGRID_snapshot_pos_detail] TO [next_usr]
GO

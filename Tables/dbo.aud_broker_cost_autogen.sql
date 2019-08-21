CREATE TABLE [dbo].[aud_broker_cost_autogen]
(
[cost_autogen_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_num] [int] NULL,
[clr_brkr_num] [int] NULL,
[exec_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[unit_price] [numeric] (20, 8) NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_eff_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[validity_start_date] [datetime] NULL,
[validity_end_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[pay_to] [int] NULL,
[block_trade_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_cost_autogen] ON [dbo].[aud_broker_cost_autogen] ([cost_autogen_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_cost_autogen_idx1] ON [dbo].[aud_broker_cost_autogen] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_broker_cost_autogen] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_broker_cost_autogen] TO [next_usr]
GO

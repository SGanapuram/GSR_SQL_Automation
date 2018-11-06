CREATE TABLE [dbo].[aud_trade_item_otc_opt]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settlement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[premium] [float] NULL,
[premium_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[premium_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[premium_pay_date] [datetime] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price] [float] NULL,
[strike_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_date_from] [datetime] NULL,
[price_date_to] [datetime] NULL,
[apo_special_cond_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_date] [datetime] NULL,
[exp_zone_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lookback_cond_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lookback_last_date] [datetime] NULL,
[strike_excer_date] [datetime] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_otc_opt] ON [dbo].[aud_trade_item_otc_opt] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_otc_opt_idx1] ON [dbo].[aud_trade_item_otc_opt] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_otc_opt] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_otc_opt] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_otc_opt] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_otc_opt] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_otc_opt] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_otc_opt', NULL, NULL
GO

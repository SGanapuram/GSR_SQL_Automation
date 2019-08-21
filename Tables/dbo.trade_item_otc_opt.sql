CREATE TABLE [dbo].[trade_item_otc_opt]
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
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_fk1] FOREIGN KEY ([premium_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_fk2] FOREIGN KEY ([strike_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_fk3] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_fk4] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_fk5] FOREIGN KEY ([exp_zone_code]) REFERENCES [dbo].[time_zone] ([time_zone_code])
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_fk7] FOREIGN KEY ([premium_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_otc_opt] ADD CONSTRAINT [trade_item_otc_opt_fk8] FOREIGN KEY ([strike_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_otc_opt] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_otc_opt] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_otc_opt] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_otc_opt] TO [next_usr]
GO

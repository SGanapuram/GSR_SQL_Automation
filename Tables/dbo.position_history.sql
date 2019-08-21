CREATE TABLE [dbo].[position_history]
(
[pos_num] [int] NOT NULL,
[asof_date] [datetime] NOT NULL,
[last_frozen_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NOT NULL,
[pos_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_equiv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NULL,
[trading_prd] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_num] [int] NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[option_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settlement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price] [float] NULL,
[strike_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_exp_date] [datetime] NULL,
[opt_start_date] [datetime] NULL,
[opt_periodicity] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_hedge_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_qty] [float] NOT NULL,
[short_qty] [float] NOT NULL,
[discount_qty] [float] NULL,
[priced_qty] [float] NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_purch_price] [float] NULL,
[avg_sale_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_long_qty] [float] NULL,
[sec_short_qty] [float] NULL,
[sec_discount_qty] [float] NULL,
[sec_priced_qty] [float] NULL,
[sec_pos_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [bigint] NOT NULL,
[pos_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_opt_eval_method] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[desired_otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_mtm_price] [numeric] (20, 8) NULL,
[rolled_qty] [numeric] (20, 8) NULL,
[sec_rolled_qty] [numeric] (20, 8) NULL,
[is_cleared_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_num] [int] NULL,
[mkt_long_qty] [float] NULL,
[mkt_short_qty] [float] NULL,
[sec_mkt_long_qty] [float] NULL,
[sec_mkt_short_qty] [float] NULL,
[equiv_source_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_position_history_equiv_source_ind] DEFAULT ('N')
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [chk_position_history_last_frozen_ind] CHECK (([last_frozen_ind]='N' OR [last_frozen_ind]='Y'))
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_pk] PRIMARY KEY CLUSTERED  ([pos_num], [asof_date], [last_frozen_ind]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [position_history_idx1] ON [dbo].[position_history] ([real_port_num]) INCLUDE ([asof_date], [last_frozen_ind], [pos_num]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk10] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk11] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk12] FOREIGN KEY ([sec_pos_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk13] FOREIGN KEY ([desired_otc_opt_code]) REFERENCES [dbo].[otc_option] ([otc_opt_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk2] FOREIGN KEY ([strike_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk3] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk5] FOREIGN KEY ([mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk8] FOREIGN KEY ([opt_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[position_history] ADD CONSTRAINT [position_history_fk9] FOREIGN KEY ([strike_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[position_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[position_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[position_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[position_history] TO [next_usr]
GO

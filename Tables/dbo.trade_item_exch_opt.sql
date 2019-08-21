CREATE TABLE [dbo].[trade_item_exch_opt]
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
[strike_price] [float] NULL,
[strike_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exp_date] [datetime] NULL,
[exp_zone_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_fill_qty] [float] NULL,
[fill_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_fill_price] [float] NULL,
[strike_excer_date] [datetime] NULL,
[clr_brkr_num] [int] NULL,
[clr_brkr_cont_num] [int] NULL,
[clr_brkr_comm_amt] [float] NULL,
[clr_brkr_comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_brkr_comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[surrender_qty] [float] NULL,
[trans_id] [int] NOT NULL,
[use_in_fifo_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exec_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_date_from] [datetime] NULL,
[price_date_to] [datetime] NULL,
[exer_commkt_key] [int] NULL,
[auto_exercise] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_exch_opt_TS_idx90] ON [dbo].[trade_item_exch_opt] ([clr_brkr_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk1] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk10] FOREIGN KEY ([strike_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk11] FOREIGN KEY ([exec_type_code]) REFERENCES [dbo].[execution_type] ([exec_type_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk12] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk2] FOREIGN KEY ([clr_brkr_num], [clr_brkr_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk3] FOREIGN KEY ([premium_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk4] FOREIGN KEY ([strike_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk5] FOREIGN KEY ([clr_brkr_comm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk7] FOREIGN KEY ([premium_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk8] FOREIGN KEY ([fill_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_exch_opt] ADD CONSTRAINT [trade_item_exch_opt_fk9] FOREIGN KEY ([clr_brkr_comm_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_exch_opt] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_exch_opt] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_exch_opt] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_exch_opt] TO [next_usr]
GO

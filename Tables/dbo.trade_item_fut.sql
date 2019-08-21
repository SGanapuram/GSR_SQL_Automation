CREATE TABLE [dbo].[trade_item_fut]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[settlement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fut_price] [float] NULL,
[fut_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_fill_qty] [float] NULL,
[fill_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_fill_price] [float] NULL,
[clr_brkr_num] [int] NULL,
[clr_brkr_cont_num] [int] NULL,
[clr_brkr_comm_amt] [float] NULL,
[clr_brkr_comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_brkr_comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exercise_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[use_in_fifo_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exec_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[efp_trigger_num] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_fut_TS_idx90] ON [dbo].[trade_item_fut] ([clr_brkr_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk1] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk10] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk2] FOREIGN KEY ([clr_brkr_num], [clr_brkr_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk3] FOREIGN KEY ([fut_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk4] FOREIGN KEY ([clr_brkr_comm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk6] FOREIGN KEY ([fill_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk7] FOREIGN KEY ([clr_brkr_comm_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk9] FOREIGN KEY ([exec_type_code]) REFERENCES [dbo].[execution_type] ([exec_type_code])
GO
GRANT DELETE ON  [dbo].[trade_item_fut] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_fut] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_fut] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_fut] TO [next_usr]
GO

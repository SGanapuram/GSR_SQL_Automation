CREATE TABLE [dbo].[aud_trade_item_fut]
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
[resp_trans_id] [int] NOT NULL,
[use_in_fifo_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exec_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[efp_trigger_num] [smallint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_fut] ON [dbo].[aud_trade_item_fut] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_fut_idx1] ON [dbo].[aud_trade_item_fut] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_fut] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_fut] TO [next_usr]
GO

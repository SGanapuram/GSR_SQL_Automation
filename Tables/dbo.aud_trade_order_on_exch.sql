CREATE TABLE [dbo].[aud_trade_order_on_exch]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[order_price] [float] NULL,
[order_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_good_to_cancel_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_points] [float] NULL,
[order_instr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[order_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_on_exch] ON [dbo].[aud_trade_order_on_exch] ([trade_num], [order_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_on_exch_idx1] ON [dbo].[aud_trade_order_on_exch] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_order_on_exch] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_order_on_exch] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_order_on_exch] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_order_on_exch] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_order_on_exch] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_order_on_exch', NULL, NULL
GO

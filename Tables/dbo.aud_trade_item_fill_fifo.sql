CREATE TABLE [dbo].[aud_trade_item_fill_fifo]
(
[fifo_group_num] [int] NOT NULL,
[fifo_num] [int] NOT NULL,
[match_fifo_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[item_num] [int] NOT NULL,
[fill_num] [int] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fifo_asof_date] [datetime] NOT NULL,
[fifo_qty] [numeric] (20, 8) NOT NULL,
[match_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_fill_fifo] ON [dbo].[aud_trade_item_fill_fifo] ([fifo_group_num], [fifo_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_fill_fifo_idx1] ON [dbo].[aud_trade_item_fill_fifo] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_fill_fifo] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_fill_fifo] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_fill_fifo] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_fill_fifo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_fill_fifo] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_fill_fifo', NULL, NULL
GO

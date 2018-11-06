CREATE TABLE [dbo].[aud_exch_fifo_alloc_item]
(
[exch_fifo_alloc_num] [int] NOT NULL,
[exch_fifo_alloc_item_num] [smallint] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_qty] [numeric] (20, 8) NOT NULL,
[alloc_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fill_num] [smallint] NULL,
[ledger_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exch_fifo_alloc_item] ON [dbo].[aud_exch_fifo_alloc_item] ([exch_fifo_alloc_num], [exch_fifo_alloc_item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exch_fifo_alloc_item_idx1] ON [dbo].[aud_exch_fifo_alloc_item] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_exch_fifo_alloc_item] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_exch_fifo_alloc_item] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_exch_fifo_alloc_item] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_exch_fifo_alloc_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_exch_fifo_alloc_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_exch_fifo_alloc_item', NULL, NULL
GO

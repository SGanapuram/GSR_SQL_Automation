CREATE TABLE [dbo].[aud_hedge_physical]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[hedge_num] [smallint] NOT NULL,
[phys_trade_num] [int] NOT NULL,
[phys_order_num] [smallint] NOT NULL,
[phys_item_num] [smallint] NOT NULL,
[weight_pcnt] [float] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_hedge_physical] ON [dbo].[aud_hedge_physical] ([trade_num], [order_num], [item_num], [hedge_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_hedge_physical_idx1] ON [dbo].[aud_hedge_physical] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_hedge_physical] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_hedge_physical] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_hedge_physical] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_hedge_physical] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_hedge_physical] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_hedge_physical', NULL, NULL
GO

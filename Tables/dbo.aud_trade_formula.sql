CREATE TABLE [dbo].[aud_trade_formula]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[formula_num] [int] NOT NULL,
[fall_back_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fall_back_to_formula_num] [int] NULL,
[formula_qty_opt] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_formula_idx1] ON [dbo].[aud_trade_formula] ([formula_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_formula] ON [dbo].[aud_trade_formula] ([trade_num], [order_num], [item_num], [formula_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_formula_idx2] ON [dbo].[aud_trade_formula] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_formula] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_formula] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_formula] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_formula] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_formula', NULL, NULL
GO

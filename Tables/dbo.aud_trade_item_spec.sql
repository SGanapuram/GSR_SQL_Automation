CREATE TABLE [dbo].[aud_trade_item_spec]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_min_val] [float] NULL,
[spec_max_val] [float] NULL,
[spec_typical_val] [float] NULL,
[spec_test_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[cmnt_num] [int] NULL,
[spec_provisional_val] [float] NULL,
[splitting_limit] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_spec] ON [dbo].[aud_trade_item_spec] ([trade_num], [order_num], [item_num], [spec_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_spec_idx1] ON [dbo].[aud_trade_item_spec] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_spec] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_spec] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_spec] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_spec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_spec', NULL, NULL
GO

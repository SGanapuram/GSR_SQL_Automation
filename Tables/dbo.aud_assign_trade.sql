CREATE TABLE [dbo].[aud_assign_trade]
(
[assign_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[ct_doc_num] [int] NOT NULL,
[ct_doc_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[covered_amt] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[credit_exposure_oid] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_assign_trade] ON [dbo].[aud_assign_trade] ([assign_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_assign_trade_idx1] ON [dbo].[aud_assign_trade] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_assign_trade] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_assign_trade] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_assign_trade] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_assign_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_assign_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_assign_trade', NULL, NULL
GO

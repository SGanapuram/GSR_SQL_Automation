CREATE TABLE [dbo].[aud_cash_settle_date]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[cash_settle_num] [smallint] NOT NULL,
[cash_settle_date] [datetime] NULL,
[cash_settle_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cash_settle_date] ON [dbo].[aud_cash_settle_date] ([trade_num], [order_num], [cash_settle_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cash_settle_date_idx1] ON [dbo].[aud_cash_settle_date] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cash_settle_date] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cash_settle_date] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cash_settle_date] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cash_settle_date] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cash_settle_date] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cash_settle_date', NULL, NULL
GO

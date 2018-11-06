CREATE TABLE [dbo].[aud_cash_collateral]
(
[cash_coll_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[cash_coll_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cash_amt] [float] NOT NULL,
[cash_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rec_date] [datetime] NULL,
[doc_num] [int] NULL,
[cmnt_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cash_collateral_idx1] ON [dbo].[aud_cash_collateral] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cash_collateral] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cash_collateral] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cash_collateral] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cash_collateral] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cash_collateral] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cash_collateral', NULL, NULL
GO

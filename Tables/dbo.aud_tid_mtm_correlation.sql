CREATE TABLE [dbo].[aud_tid_mtm_correlation]
(
[dist_num1] [int] NOT NULL,
[dist_num2] [int] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[correlation] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tid_mtm_correlation_idx1] ON [dbo].[aud_tid_mtm_correlation] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_tid_mtm_correlation] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_tid_mtm_correlation] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_tid_mtm_correlation] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_tid_mtm_correlation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tid_mtm_correlation] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_tid_mtm_correlation', NULL, NULL
GO

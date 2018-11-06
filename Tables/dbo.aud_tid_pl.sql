CREATE TABLE [dbo].[aud_tid_pl]
(
[dist_num] [int] NOT NULL,
[open_pl] [float] NULL,
[closed_pl] [float] NULL,
[pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[addl_cost_sum] [float] NULL,
[pl_asof_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_tid_pl] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_tid_pl] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_tid_pl] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_tid_pl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tid_pl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_tid_pl', NULL, NULL
GO

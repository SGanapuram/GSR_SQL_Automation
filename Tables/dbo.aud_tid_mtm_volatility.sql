CREATE TABLE [dbo].[aud_tid_mtm_volatility]
(
[dist_num] [int] NOT NULL,
[mtm_pl_asof_date] [datetime] NOT NULL,
[vol_num] [int] NOT NULL,
[strike_price] [numeric] (20, 8) NULL,
[skew_price] [numeric] (20, 8) NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility] [numeric] (20, 8) NULL,
[use_option_skew] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tid_mtm_volatility] ON [dbo].[aud_tid_mtm_volatility] ([dist_num], [mtm_pl_asof_date], [vol_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tid_mtm_volatility_idx1] ON [dbo].[aud_tid_mtm_volatility] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_tid_mtm_volatility] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_tid_mtm_volatility] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_tid_mtm_volatility] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_tid_mtm_volatility] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tid_mtm_volatility] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_tid_mtm_volatility', NULL, NULL
GO

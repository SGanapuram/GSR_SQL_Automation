CREATE TABLE [dbo].[aud_riskmgr_win_pivot_def]
(
[owner_win_id] [int] NOT NULL,
[piv_def_id] [int] NOT NULL,
[tab_index] [int] NOT NULL,
[tab_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[num_of_decimals] [tinyint] NOT NULL,
[show_future_equiv] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pivot_layout] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[show_zero] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[asof_date] [date] NULL,
[primary_uom] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_riskm__prima__568B56FD] DEFAULT ('N'),
[quantity_divisor] [float] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_riskmgr_win_pivot_def] ON [dbo].[aud_riskmgr_win_pivot_def] ([piv_def_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_riskmgr_win_pivot_def_idx1] ON [dbo].[aud_riskmgr_win_pivot_def] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_riskmgr_win_pivot_def] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_riskmgr_win_pivot_def] TO [next_usr]
GO

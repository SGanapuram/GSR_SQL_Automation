CREATE TABLE [dbo].[aud_riskmgr_win_def]
(
[win_id] [int] NOT NULL,
[description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_public] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[window_title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[selected_index] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[show_history_pnl] [bit] NOT NULL CONSTRAINT [df_aud_riskmgr_win_def_show_history_pnl] DEFAULT ((0)),
[visible_portfolio_cols] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_riskmgr_win_def_idx1] ON [dbo].[aud_riskmgr_win_def] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_riskmgr_win_def] ON [dbo].[aud_riskmgr_win_def] ([win_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_riskmgr_win_def] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_riskmgr_win_def] TO [next_usr]
GO

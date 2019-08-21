CREATE TABLE [dbo].[aud_lc_status_history]
(
[lc_num] [int] NOT NULL,
[lc_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_status_date] [datetime] NOT NULL,
[lc_status_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_status_history] ON [dbo].[aud_lc_status_history] ([lc_num], [lc_status_code], [lc_status_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_status_history_idx1] ON [dbo].[aud_lc_status_history] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lc_status_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_status_history] TO [next_usr]
GO

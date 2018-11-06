CREATE TABLE [dbo].[aud_lc_usage]
(
[lc_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_usage_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_usage_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_usage] ON [dbo].[aud_lc_usage] ([lc_usage_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_usage_idx1] ON [dbo].[aud_lc_usage] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lc_usage] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lc_usage] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lc_usage] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lc_usage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_usage] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lc_usage', NULL, NULL
GO

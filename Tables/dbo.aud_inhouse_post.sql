CREATE TABLE [dbo].[aud_inhouse_post]
(
[trade_num] [int] NOT NULL,
[risc_location] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inhouse_post_idx] ON [dbo].[aud_inhouse_post] ([trade_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_inhouse_post] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_inhouse_post] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_inhouse_post] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_inhouse_post] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inhouse_post] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_inhouse_post', NULL, NULL
GO

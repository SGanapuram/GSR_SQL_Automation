CREATE TABLE [dbo].[aud_folder]
(
[folder_num] [int] NOT NULL,
[folder_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_folder] ON [dbo].[aud_folder] ([folder_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_folder_idx1] ON [dbo].[aud_folder] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_folder] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_folder] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_folder] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_folder] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_folder] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_folder', NULL, NULL
GO

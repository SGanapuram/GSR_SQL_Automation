CREATE TABLE [dbo].[aud_application]
(
[app_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_application] ON [dbo].[aud_application] ([app_name], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_application_idx1] ON [dbo].[aud_application] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_application] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_application] TO [next_usr]
GO

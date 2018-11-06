CREATE TABLE [dbo].[aud_icts_message]
(
[oid] [int] NOT NULL,
[msg_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[msg_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_message] ON [dbo].[aud_icts_message] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_message_idx1] ON [dbo].[aud_icts_message] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_icts_message] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_icts_message] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_icts_message] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_icts_message] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_icts_message] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_icts_message', NULL, NULL
GO

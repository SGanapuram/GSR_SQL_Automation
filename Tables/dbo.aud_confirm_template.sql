CREATE TABLE [dbo].[aud_confirm_template]
(
[oid] [int] NOT NULL,
[template_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_confirm_template] ON [dbo].[aud_confirm_template] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_confirm_template_idx1] ON [dbo].[aud_confirm_template] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_confirm_template] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_confirm_template] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_confirm_template] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_confirm_template] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_confirm_template] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_confirm_template', NULL, NULL
GO

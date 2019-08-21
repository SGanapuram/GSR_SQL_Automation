CREATE TABLE [dbo].[aud_uic_status]
(
[entity_id] [int] NOT NULL,
[status_selector] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_status] ON [dbo].[aud_uic_status] ([entity_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_status_idx1] ON [dbo].[aud_uic_status] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_uic_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uic_status] TO [next_usr]
GO

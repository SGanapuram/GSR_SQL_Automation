CREATE TABLE [dbo].[aud_assay_activity]
(
[activity_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_assay_activity] ON [dbo].[aud_assay_activity] ([activity_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_assay_activity_idx1] ON [dbo].[aud_assay_activity] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_assay_activity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_assay_activity] TO [next_usr]
GO

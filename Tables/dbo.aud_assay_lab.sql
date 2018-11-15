CREATE TABLE [dbo].[aud_assay_lab]
(
[assay_lab_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[assay_lab_full_name] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_assay_lab] ON [dbo].[aud_assay_lab] ([assay_lab_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_assay_lab_idx1] ON [dbo].[aud_assay_lab] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_assay_lab] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_assay_lab] TO [next_usr]
GO

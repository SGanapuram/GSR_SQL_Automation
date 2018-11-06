CREATE TABLE [dbo].[aud_fiscal_classification]
(
[fiscal_class_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fiscal_class_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fiscal_class_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fiscal_classification] ON [dbo].[aud_fiscal_classification] ([fiscal_class_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fiscal_classification_idx1] ON [dbo].[aud_fiscal_classification] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_fiscal_classification] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_fiscal_classification] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_fiscal_classification] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_fiscal_classification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fiscal_classification] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_fiscal_classification', NULL, NULL
GO

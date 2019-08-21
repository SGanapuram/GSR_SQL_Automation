CREATE TABLE [dbo].[aud_cmdty_nomenclature]
(
[cmdty_nomenclature_id] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nomenclature_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[nomenclature_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cmdty_nomenclature] ON [dbo].[aud_cmdty_nomenclature] ([cmdty_nomenclature_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cmdty_nomenclature_idx1] ON [dbo].[aud_cmdty_nomenclature] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cmdty_nomenclature] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cmdty_nomenclature] TO [next_usr]
GO

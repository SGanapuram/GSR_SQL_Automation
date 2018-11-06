CREATE TABLE [dbo].[aud_commodity_desc]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_desc_lang] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_desc_for] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_desc] ON [dbo].[aud_commodity_desc] ([cmdty_code], [cmdty_desc_lang], [cmdty_desc_for], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_desc_idx1] ON [dbo].[aud_commodity_desc] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_commodity_desc] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_commodity_desc] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_commodity_desc] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_commodity_desc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_desc] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_commodity_desc', NULL, NULL
GO

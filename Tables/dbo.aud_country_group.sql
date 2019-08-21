CREATE TABLE [dbo].[aud_country_group]
(
[code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_country_group_idx1] ON [dbo].[aud_country_group] ([code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_country_group_idx2] ON [dbo].[aud_country_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_country_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_country_group] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_delivery_term_alias]
(
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_term_alias_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_delivery_term_alias] ON [dbo].[aud_delivery_term_alias] ([del_term_code], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_delivery_term_alias_idx1] ON [dbo].[aud_delivery_term_alias] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_delivery_term_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_delivery_term_alias] TO [next_usr]
GO

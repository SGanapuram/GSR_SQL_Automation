CREATE TABLE [dbo].[aud_user_resources]
(
[oid] [int] NOT NULL,
[domain_id] [int] NOT NULL,
[desk_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[culture] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[res_type] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[res_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[res_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sub_fieldname_0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sub_fieldname_5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[view_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_aud_user_resources_is_default] DEFAULT ('N')
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_resources] ON [dbo].[aud_user_resources] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_resources_idx1] ON [dbo].[aud_user_resources] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_user_resources] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_user_resources] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_sys_resources]
(
[oid] [int] NOT NULL,
[domain_id] [int] NOT NULL,
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
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_sys_resources] ON [dbo].[aud_sys_resources] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_sys_resources_idx1] ON [dbo].[aud_sys_resources] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_sys_resources] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_sys_resources] TO [next_usr]
GO

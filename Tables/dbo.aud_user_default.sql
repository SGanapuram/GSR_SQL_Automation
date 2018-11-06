CREATE TABLE [dbo].[aud_user_default]
(
[oid] [int] NOT NULL,
[defaults_key] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[domain_id] [int] NOT NULL,
[may_not_override] [bit] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[defaults_value] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_default] ON [dbo].[aud_user_default] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_default_idx1] ON [dbo].[aud_user_default] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_user_default] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_user_default] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_user_default] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_user_default] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_user_default] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_user_default', NULL, NULL
GO

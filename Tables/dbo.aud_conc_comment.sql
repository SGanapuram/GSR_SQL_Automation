CREATE TABLE [dbo].[aud_conc_comment]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NULL,
[version_num] [int] NULL,
[conc_prior_ver_oid] [int] NULL,
[cmnt_num] [int] NULL,
[cmnt_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmnt_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_creation_date] [datetime] NOT NULL,
[cmnt_last_mod_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_comment] ON [dbo].[aud_conc_comment] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_comment_idx1] ON [dbo].[aud_conc_comment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_comment] TO [next_usr]
GO

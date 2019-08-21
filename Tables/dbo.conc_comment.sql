CREATE TABLE [dbo].[conc_comment]
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
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_comment] ADD CONSTRAINT [conc_comment_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_comment] ADD CONSTRAINT [conc_comment_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_comment] ADD CONSTRAINT [conc_comment_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_comment] ADD CONSTRAINT [conc_comment_fk3] FOREIGN KEY ([cmnt_num]) REFERENCES [dbo].[comment] ([cmnt_num])
GO
ALTER TABLE [dbo].[conc_comment] ADD CONSTRAINT [conc_comment_fk4] FOREIGN KEY ([cmnt_creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[conc_comment] ADD CONSTRAINT [conc_comment_fk5] FOREIGN KEY ([cmnt_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[conc_comment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_comment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_comment] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_parent_guar_subs_covered]
(
[pg_num] [int] NOT NULL,
[pg_subsidiary_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parent_guar_subs_covered] ON [dbo].[aud_parent_guar_subs_covered] ([pg_num], [pg_subsidiary_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parent_guar_subs_cov_idx1] ON [dbo].[aud_parent_guar_subs_covered] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_parent_guar_subs_covered] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parent_guar_subs_covered] TO [next_usr]
GO

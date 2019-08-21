CREATE TABLE [dbo].[aud_material_adv_chg_clause]
(
[macc_num] [int] NOT NULL,
[macc_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_material_adv_chg_clause] ON [dbo].[aud_material_adv_chg_clause] ([macc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_material_adv_chg_cla_idx1] ON [dbo].[aud_material_adv_chg_clause] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_material_adv_chg_clause] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_material_adv_chg_clause] TO [next_usr]
GO

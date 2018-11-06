CREATE TABLE [dbo].[aud_lc_special_condition]
(
[lc_num] [int] NOT NULL,
[special_cond_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_special_condition] ON [dbo].[aud_lc_special_condition] ([lc_num], [special_cond_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_special_condition_idx1] ON [dbo].[aud_lc_special_condition] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lc_special_condition] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lc_special_condition] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lc_special_condition] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lc_special_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_special_condition] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lc_special_condition', NULL, NULL
GO

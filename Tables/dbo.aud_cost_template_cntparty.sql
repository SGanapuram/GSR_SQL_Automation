CREATE TABLE [dbo].[aud_cost_template_cntparty]
(
[cost_template_oid] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_template_cntparty] ON [dbo].[aud_cost_template_cntparty] ([cost_template_oid], [acct_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_templ_cntparty_idx1] ON [dbo].[aud_cost_template_cntparty] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_template_cntparty] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_template_cntparty] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_template_cntparty] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_template_cntparty] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_template_cntparty] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_template_cntparty', NULL, NULL
GO

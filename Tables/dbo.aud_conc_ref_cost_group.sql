CREATE TABLE [dbo].[aud_conc_ref_cost_group]
(
[oid] [int] NOT NULL,
[cost_group_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_group_short_name] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_cost_group] ON [dbo].[aud_conc_ref_cost_group] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_cost_group_idx1] ON [dbo].[aud_conc_ref_cost_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_ref_cost_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_ref_cost_group] TO [next_usr]
GO

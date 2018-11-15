CREATE TABLE [dbo].[aud_conc_ref_cost_item]
(
[oid] [int] NOT NULL,
[cost_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_short_name] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_ref_cost_group_oid] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_cost_item] ON [dbo].[aud_conc_ref_cost_item] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_cost_item_idx1] ON [dbo].[aud_conc_ref_cost_item] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_ref_cost_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_ref_cost_item] TO [next_usr]
GO

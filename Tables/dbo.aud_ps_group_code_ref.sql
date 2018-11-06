CREATE TABLE [dbo].[aud_ps_group_code_ref]
(
[purchase_sale_group_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[purchase_sale_group_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ps_group_code_ref] ON [dbo].[aud_ps_group_code_ref] ([purchase_sale_group_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ps_group_code_ref_idx1] ON [dbo].[aud_ps_group_code_ref] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ps_group_code_ref] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ps_group_code_ref] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ps_group_code_ref] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ps_group_code_ref] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ps_group_code_ref] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ps_group_code_ref', NULL, NULL
GO

CREATE TABLE [dbo].[aud_collateral_type]
(
[collateral_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[collateral_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_collateral_type] ON [dbo].[aud_collateral_type] ([collateral_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_collateral_type_idx1] ON [dbo].[aud_collateral_type] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_collateral_type] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_collateral_type] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_collateral_type] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_collateral_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_collateral_type] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_collateral_type', NULL, NULL
GO

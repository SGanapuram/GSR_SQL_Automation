CREATE TABLE [dbo].[aud_position_group]
(
[pos_group_num] [int] NOT NULL,
[is_spread_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_group] ON [dbo].[aud_position_group] ([pos_group_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_group_idx1] ON [dbo].[aud_position_group] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_position_group] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_position_group] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_position_group] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_position_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_position_group] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_position_group', NULL, NULL
GO

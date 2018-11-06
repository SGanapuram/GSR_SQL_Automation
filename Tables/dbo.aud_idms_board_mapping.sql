CREATE TABLE [dbo].[aud_idms_board_mapping]
(
[next_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[idms_name] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_idms_board_mapping] ON [dbo].[aud_idms_board_mapping] ([next_name], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_idms_board_mapping_idx1] ON [dbo].[aud_idms_board_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_idms_board_mapping] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_idms_board_mapping] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_idms_board_mapping] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_idms_board_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_idms_board_mapping] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_idms_board_mapping', NULL, NULL
GO

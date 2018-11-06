CREATE TABLE [dbo].[aud_generic_data_name]
(
[gdn_num] [int] NOT NULL,
[data_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_generic_data_name] ON [dbo].[aud_generic_data_name] ([gdn_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_generic_data_name_idx1] ON [dbo].[aud_generic_data_name] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_generic_data_name] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_generic_data_name] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_generic_data_name] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_generic_data_name] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_generic_data_name] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_generic_data_name', NULL, NULL
GO

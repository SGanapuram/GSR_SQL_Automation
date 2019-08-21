CREATE TABLE [dbo].[aud_data_file]
(
[id] [int] NOT NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parser_id] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[track_successes] [bit] NOT NULL CONSTRAINT [df_aud_data_file_track_successes] DEFAULT ((0)),
[skip_unmapped_records] [bit] NULL,
[is_active] [bit] NOT NULL CONSTRAINT [df_aud_data_file_is_active] DEFAULT ((1))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_data_file] ON [dbo].[aud_data_file] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_data_file_idx1] ON [dbo].[aud_data_file] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_data_file] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_data_file] TO [next_usr]
GO

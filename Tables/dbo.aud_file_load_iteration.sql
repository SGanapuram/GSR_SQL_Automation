CREATE TABLE [dbo].[aud_file_load_iteration]
(
[id] [int] NOT NULL,
[load_start_time] [datetime] NULL,
[load_end_time] [datetime] NULL,
[file_load_id] [int] NOT NULL,
[processed_records] [int] NOT NULL CONSTRAINT [df_aud_file_load_iteration_processed_records] DEFAULT ((0)),
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[parser_version_id] [int] NULL,
[failed_records] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load_iteration] ON [dbo].[aud_file_load_iteration] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load_iteration_idx1] ON [dbo].[aud_file_load_iteration] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_file_load_iteration] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_file_load_iteration] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_file_load]
(
[id] [int] NOT NULL,
[data_file_id] [int] NOT NULL,
[failed_records] [int] NOT NULL,
[load_end_time] [datetime] NULL,
[load_start_time] [datetime] NOT NULL,
[preprocessed_records] [int] NOT NULL,
[total_records] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load] ON [dbo].[aud_file_load] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load_idx1] ON [dbo].[aud_file_load] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_file_load] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_file_load] TO [next_usr]
GO

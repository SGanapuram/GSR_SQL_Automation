CREATE TABLE [dbo].[aud_file_load_error]
(
[sequence] [int] NOT NULL,
[error_reason] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[file_load_id] [int] NOT NULL,
[source_data] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load_error] ON [dbo].[aud_file_load_error] ([sequence], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load_error_idx1] ON [dbo].[aud_file_load_error] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_file_load_error] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_file_load_error] TO [next_usr]
GO

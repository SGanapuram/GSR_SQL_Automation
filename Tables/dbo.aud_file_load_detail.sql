CREATE TABLE [dbo].[aud_file_load_detail]
(
[id] [int] NOT NULL,
[source_data] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[error_reason] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[file_load_id] [int] NULL,
[file_load_success_iteration_id] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[error_reason_extended] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load_detail] ON [dbo].[aud_file_load_detail] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_file_load_detail_idx1] ON [dbo].[aud_file_load_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_file_load_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_file_load_detail] TO [next_usr]
GO

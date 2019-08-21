CREATE TABLE [dbo].[aud_execution_type]
(
[exec_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exec_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fifo_priority] [smallint] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_execution_type] ON [dbo].[aud_execution_type] ([exec_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_execution_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_execution_type] TO [next_usr]
GO

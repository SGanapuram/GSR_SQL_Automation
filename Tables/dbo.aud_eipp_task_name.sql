CREATE TABLE [dbo].[aud_eipp_task_name]
(
[oid] [int] NOT NULL,
[task_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_eipp_task_name] ON [dbo].[aud_eipp_task_name] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_eipp_task_name_idx1] ON [dbo].[aud_eipp_task_name] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_eipp_task_name] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_eipp_task_name] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_eipp_task_name] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_eipp_task_name] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_eipp_task_name] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_eipp_task_name', NULL, NULL
GO

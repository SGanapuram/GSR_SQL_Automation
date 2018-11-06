CREATE TABLE [dbo].[aud_operation_type]
(
[oper_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[oper_type_desc] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_operation_type] ON [dbo].[aud_operation_type] ([oper_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_operation_type_idx1] ON [dbo].[aud_operation_type] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_operation_type] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_operation_type] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_operation_type] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_operation_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_operation_type] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_operation_type', NULL, NULL
GO

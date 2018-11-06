CREATE TABLE [dbo].[aud_interface_exec_params]
(
[exec_num] [int] NOT NULL,
[interface_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[param_1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[param_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[param_6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_interface_exec_params] ON [dbo].[aud_interface_exec_params] ([exec_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_interface_exec_params_idx1] ON [dbo].[aud_interface_exec_params] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_interface_exec_params] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_interface_exec_params] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_interface_exec_params] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_interface_exec_params] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_interface_exec_params] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_interface_exec_params', NULL, NULL
GO

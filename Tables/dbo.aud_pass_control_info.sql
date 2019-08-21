CREATE TABLE [dbo].[aud_pass_control_info]
(
[pass_control_id] [int] NOT NULL,
[pass_control_val_1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pass_control_val_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pass_control_val_3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pass_control_val_4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pass_control_val_5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pass_control_val_6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pass_control_info] ON [dbo].[aud_pass_control_info] ([pass_control_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pass_control_info_idx1] ON [dbo].[aud_pass_control_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pass_control_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pass_control_info] TO [next_usr]
GO

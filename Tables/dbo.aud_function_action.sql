CREATE TABLE [dbo].[aud_function_action]
(
[oid] [int] NOT NULL,
[function_num] [int] NOT NULL,
[action_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[action_type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_function_action] ON [dbo].[aud_function_action] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_function_action_idx1] ON [dbo].[aud_function_action] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_function_action] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_function_action] TO [next_usr]
GO

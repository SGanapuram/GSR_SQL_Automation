CREATE TABLE [dbo].[aud_icts_function]
(
[function_num] [int] NOT NULL,
[app_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[function_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_function] ON [dbo].[aud_icts_function] ([function_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_function_idx1] ON [dbo].[aud_icts_function] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_icts_function] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_icts_function] TO [next_usr]
GO

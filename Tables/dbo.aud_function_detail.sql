CREATE TABLE [dbo].[aud_function_detail]
(
[fd_id] [int] NOT NULL,
[function_num] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[attr_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operation] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_ind] [bit] NOT NULL CONSTRAINT [df_aud_function_detail_entity_ind] DEFAULT ((0)),
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_function_detail] ON [dbo].[aud_function_detail] ([fd_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_function_detail_idx1] ON [dbo].[aud_function_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_function_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_function_detail] TO [next_usr]
GO

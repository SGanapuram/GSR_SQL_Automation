CREATE TABLE [dbo].[aud_function_detail_value]
(
[fdv_id] [int] NOT NULL,
[fd_id] [int] NOT NULL,
[data_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_aud_function_detail_value_data_type] DEFAULT ('S'),
[attr_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aud_function_detail_value] ADD CONSTRAINT [chk_aud_function_detail_value_data_type] CHECK (([data_type]='S' OR [data_type]='F' OR [data_type]='D' OR [data_type]='I'))
GO
CREATE NONCLUSTERED INDEX [aud_function_detail_value] ON [dbo].[aud_function_detail_value] ([fdv_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_function_detail_value_idx1] ON [dbo].[aud_function_detail_value] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_function_detail_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_function_detail_value] TO [next_usr]
GO

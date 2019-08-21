CREATE TABLE [dbo].[aud_key_value_type]
(
[key_value_name] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key_value_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_key_value_type] ON [dbo].[aud_key_value_type] ([key_value_name], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_key_value_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_key_value_type] TO [next_usr]
GO

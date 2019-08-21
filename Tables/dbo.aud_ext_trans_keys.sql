CREATE TABLE [dbo].[aud_ext_trans_keys]
(
[oid] [int] NOT NULL,
[int_key_value] [int] NULL,
[str_key_value] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dt_key_value] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ext_trans_keys] ON [dbo].[aud_ext_trans_keys] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ext_trans_keys_idx1] ON [dbo].[aud_ext_trans_keys] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ext_trans_keys] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ext_trans_keys] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_key_value]
(
[oid] [int] NOT NULL,
[type] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[owner_id] [int] NOT NULL,
[keystring] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_key_value] ON [dbo].[aud_key_value] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_key_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_key_value] TO [next_usr]
GO

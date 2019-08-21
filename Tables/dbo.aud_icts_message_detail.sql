CREATE TABLE [dbo].[aud_icts_message_detail]
(
[oid] [int] NOT NULL,
[message_id] [int] NOT NULL,
[icts_entity_id] [int] NOT NULL,
[key1] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[op_trans_id] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_message_detail] ON [dbo].[aud_icts_message_detail] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_message_detail_idx1] ON [dbo].[aud_icts_message_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_icts_message_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_icts_message_detail] TO [next_usr]
GO

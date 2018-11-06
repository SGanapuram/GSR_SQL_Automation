CREATE TABLE [dbo].[aud_send_to_SAP]
(
[row_id] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [int] NULL,
[key2] [int] NULL,
[key3] [int] NULL,
[interface] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[operation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[op_trans_id] [int] NOT NULL,
[file_id] [int] NULL,
[ready_to_send] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_date] [datetime] NULL,
[purged_date] [datetime] NULL,
[hide_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[represented_cmdtys] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_send_to_SAP] ON [dbo].[aud_send_to_SAP] ([row_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_send_to_SAP] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_send_to_SAP] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_send_to_SAP] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_send_to_SAP] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_send_to_SAP] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_send_to_SAP', NULL, NULL
GO

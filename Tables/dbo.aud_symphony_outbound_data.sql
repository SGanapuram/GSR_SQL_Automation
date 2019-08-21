CREATE TABLE [dbo].[aud_symphony_outbound_data]
(
[row_id] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [int] NULL,
[key2] [int] NULL,
[key3] [int] NULL,
[interface] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[operation] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[op_trans_id] [int] NOT NULL,
[file_id] [int] NULL,
[ready_to_send] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[archived_date] [datetime] NULL,
[purged_date] [datetime] NULL,
[hide_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[represented_cmdtys] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[status] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_aud_symphony_outbound_data_status] DEFAULT ('PENDING'),
[duplicate_of] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aud_symphony_outbound_data] ADD CONSTRAINT [chk_aud_symphony_outbound_data_status] CHECK (([status]='ERROR' OR [status]='PROCESSED' OR [status]='DELETED' OR [status]='DUPLICATE' OR [status]='PENDING'))
GO
CREATE NONCLUSTERED INDEX [aud_symphony_outbound_data] ON [dbo].[aud_symphony_outbound_data] ([row_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_symphony_outbound_data_idx1] ON [dbo].[aud_symphony_outbound_data] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_symphony_outbound_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_symphony_outbound_data] TO [next_usr]
GO

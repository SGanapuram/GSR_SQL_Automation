CREATE TABLE [dbo].[aud_order_type]
(
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[order_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_order_type] ON [dbo].[aud_order_type] ([order_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_order_type_idx1] ON [dbo].[aud_order_type] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_order_type] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_order_type] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_order_type] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_order_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_order_type] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_order_type', NULL, NULL
GO

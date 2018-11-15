CREATE TABLE [dbo].[aud_product]
(
[id] [int] NOT NULL,
[base_product_id] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_product] ON [dbo].[aud_product] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_product_idx1] ON [dbo].[aud_product] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_product] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_product] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_product] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_product] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_product] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_product', NULL, NULL
GO

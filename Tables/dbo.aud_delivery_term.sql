CREATE TABLE [dbo].[aud_delivery_term]
(
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_term_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_delivery_term] ON [dbo].[aud_delivery_term] ([del_term_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_delivery_term_idx1] ON [dbo].[aud_delivery_term] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_delivery_term] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_delivery_term] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_delivery_term] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_delivery_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_delivery_term] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_delivery_term', NULL, NULL
GO

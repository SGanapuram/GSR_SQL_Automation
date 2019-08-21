CREATE TABLE [dbo].[aud_commodity_category]
(
[cmdty_category_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_category_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_category_idx] ON [dbo].[aud_commodity_category] ([cmdty_category_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commodity_category] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_category] TO [next_usr]
GO

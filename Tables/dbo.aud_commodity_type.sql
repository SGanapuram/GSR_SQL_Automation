CREATE TABLE [dbo].[aud_commodity_type]
(
[cmdty_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_type] ON [dbo].[aud_commodity_type] ([cmdty_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_type_idx1] ON [dbo].[aud_commodity_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commodity_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_type] TO [next_usr]
GO

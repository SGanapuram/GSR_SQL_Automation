CREATE TABLE [dbo].[aud_price_source]
(
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_price_source] ON [dbo].[aud_price_source] ([price_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_price_source_idx1] ON [dbo].[aud_price_source] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_price_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_price_source] TO [next_usr]
GO

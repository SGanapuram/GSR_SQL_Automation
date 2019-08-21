CREATE TABLE [dbo].[aud_product_usage]
(
[product_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[product_usage_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_product_usage] ON [dbo].[aud_product_usage] ([product_usage_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_product_usage_idx1] ON [dbo].[aud_product_usage] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_product_usage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_product_usage] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_marketdata_supplier]
(
[id] [int] NOT NULL,
[marketdata_file_id] [int] NULL,
[quote_mktdata_source_id] [int] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_marketdata_supplier] ON [dbo].[aud_marketdata_supplier] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_marketdata_supplier_idx1] ON [dbo].[aud_marketdata_supplier] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_marketdata_supplier] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_marketdata_supplier] TO [next_usr]
GO

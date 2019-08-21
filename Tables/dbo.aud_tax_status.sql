CREATE TABLE [dbo].[aud_tax_status]
(
[tax_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_status_desc] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_tax_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tax_status] TO [next_usr]
GO

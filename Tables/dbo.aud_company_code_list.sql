CREATE TABLE [dbo].[aud_company_code_list]
(
[company_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[company_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_company_code_list_idx1] ON [dbo].[aud_company_code_list] ([company_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_company_code_list_idx2] ON [dbo].[aud_company_code_list] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_company_code_list] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_company_code_list] TO [next_usr]
GO

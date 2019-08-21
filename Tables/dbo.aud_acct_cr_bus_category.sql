CREATE TABLE [dbo].[aud_acct_cr_bus_category]
(
[acct_num] [int] NOT NULL,
[cr_bus_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_cr_bus_category] ON [dbo].[aud_acct_cr_bus_category] ([acct_num], [cr_bus_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_cr_bus_category_idx1] ON [dbo].[aud_acct_cr_bus_category] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_cr_bus_category] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_cr_bus_category] TO [next_usr]
GO

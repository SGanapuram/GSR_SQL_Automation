CREATE TABLE [dbo].[aud_credit_bus_category]
(
[cr_bus_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cr_bus_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_bus_category] ON [dbo].[aud_credit_bus_category] ([cr_bus_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_bus_category_idx1] ON [dbo].[aud_credit_bus_category] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_credit_bus_category] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_credit_bus_category] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_credit_bus_category] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_credit_bus_category] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_bus_category] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_credit_bus_category', NULL, NULL
GO
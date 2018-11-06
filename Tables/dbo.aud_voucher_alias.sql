CREATE TABLE [dbo].[aud_voucher_alias]
(
[voucher_num] [int] NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[voucher_alias_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_alias_idx1] ON [dbo].[aud_voucher_alias] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_alias] ON [dbo].[aud_voucher_alias] ([voucher_num], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voucher_alias] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voucher_alias] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voucher_alias] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voucher_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_alias] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voucher_alias', NULL, NULL
GO

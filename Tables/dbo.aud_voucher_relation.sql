CREATE TABLE [dbo].[aud_voucher_relation]
(
[voucher_num] [int] NOT NULL,
[related_voucher_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_relation_idx1] ON [dbo].[aud_voucher_relation] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_relation] ON [dbo].[aud_voucher_relation] ([voucher_num], [related_voucher_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_voucher_relation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_relation] TO [next_usr]
GO

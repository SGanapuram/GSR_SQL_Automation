CREATE TABLE [dbo].[aud_lm_acctdata_mapping]
(
[oid] [int] NOT NULL,
[clr_broker_num] [int] NOT NULL,
[ext_account_id] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ext_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cust_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[seg_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_acctdata_mapping] ON [dbo].[aud_lm_acctdata_mapping] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_acctdata_mapping_idx1] ON [dbo].[aud_lm_acctdata_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lm_acctdata_mapping] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lm_acctdata_mapping] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lm_acctdata_mapping] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lm_acctdata_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lm_acctdata_mapping] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lm_acctdata_mapping', NULL, NULL
GO

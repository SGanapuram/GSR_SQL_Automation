CREATE TABLE [dbo].[aud_lc_bankfee_refdata]
(
[oid] [int] NOT NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_exp_imp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_lc_ba__lc_ex__1BBE003C] DEFAULT ('I'),
[book_comp_num] [int] NOT NULL,
[issuing_bank] [int] NOT NULL,
[lc_bankfee_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_lc_ba__lc_ba__1DA648AE] DEFAULT ('F'),
[lc_bankfee_amt] [decimal] (20, 8) NOT NULL,
[lc_bankfee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_bankfee_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_lc_ba__lc_ba__1F8E9120] DEFAULT ('A'),
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aud_lc_bankfee_refdata] ADD CONSTRAINT [CK__aud_lc_ba__lc_ba__2082B559] CHECK (([lc_bankfee_status]='I' OR [lc_bankfee_status]='A'))
GO
ALTER TABLE [dbo].[aud_lc_bankfee_refdata] ADD CONSTRAINT [CK__aud_lc_ba__lc_ba__1E9A6CE7] CHECK (([lc_bankfee_type]='R' OR [lc_bankfee_type]='F'))
GO
ALTER TABLE [dbo].[aud_lc_bankfee_refdata] ADD CONSTRAINT [CK__aud_lc_ba__lc_ex__1CB22475] CHECK (([lc_exp_imp_ind]='I' OR [lc_exp_imp_ind]='E'))
GO
CREATE NONCLUSTERED INDEX [aud_lc_bankfee_refdata] ON [dbo].[aud_lc_bankfee_refdata] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_bankfee_refdata_idx1] ON [dbo].[aud_lc_bankfee_refdata] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lc_bankfee_refdata] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lc_bankfee_refdata] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lc_bankfee_refdata] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lc_bankfee_refdata] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_bankfee_refdata] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lc_bankfee_refdata', NULL, NULL
GO

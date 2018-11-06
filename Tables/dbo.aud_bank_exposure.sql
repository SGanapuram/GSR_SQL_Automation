CREATE TABLE [dbo].[aud_bank_exposure]
(
[bank_exp_num] [int] NOT NULL,
[bank_exp_date] [datetime] NOT NULL,
[bank_exp_amt] [float] NULL,
[bank_exp_lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NOT NULL,
[book_comp_num] [int] NOT NULL,
[bank_exp_imp_exp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bank_exposure] ON [dbo].[aud_bank_exposure] ([bank_exp_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bank_exposure_idx1] ON [dbo].[aud_bank_exposure] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_bank_exposure] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_bank_exposure] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_bank_exposure] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_bank_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_bank_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_bank_exposure', NULL, NULL
GO

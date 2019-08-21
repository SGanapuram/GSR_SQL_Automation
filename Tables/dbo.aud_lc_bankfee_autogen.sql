CREATE TABLE [dbo].[aud_lc_bankfee_autogen]
(
[oid] [int] NOT NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_exp_imp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[book_comp_num] [int] NOT NULL,
[issuing_bank] [int] NOT NULL,
[lc_bankfee_amt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_bankfee_amt] [decimal] (20, 8) NOT NULL,
[lc_bankfee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_bankfee_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[fee_validity_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_bankfee_autogen] ON [dbo].[aud_lc_bankfee_autogen] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_bankfee_autogen_idx1] ON [dbo].[aud_lc_bankfee_autogen] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lc_bankfee_autogen] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_bankfee_autogen] TO [next_usr]
GO

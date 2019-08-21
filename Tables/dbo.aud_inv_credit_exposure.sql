CREATE TABLE [dbo].[aud_inv_credit_exposure]
(
[oid] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[booking_comp_num] [int] NOT NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_mtm_amt] [numeric] (20, 8) NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[qty] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_credit_exposure] ON [dbo].[aud_inv_credit_exposure] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_credit_exposure_idx1] ON [dbo].[aud_inv_credit_exposure] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_inv_credit_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inv_credit_exposure] TO [next_usr]
GO

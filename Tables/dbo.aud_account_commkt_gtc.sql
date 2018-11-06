CREATE TABLE [dbo].[aud_account_commkt_gtc]
(
[acct_num] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[booking_company_num] [int] NOT NULL,
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[netting_forwards_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_accou__netti__0FC23DAB] DEFAULT ('N'),
[netting_vouchers_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_accou__netti__11AA861D] DEFAULT ('N'),
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL CONSTRAINT [DF__aud_accou__creat__1392CE8F] DEFAULT (getdate()),
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aud_account_commkt_gtc] ADD CONSTRAINT [CK__aud_accou__netti__10B661E4] CHECK (([netting_forwards_ind]='N' OR [netting_forwards_ind]='Y'))
GO
ALTER TABLE [dbo].[aud_account_commkt_gtc] ADD CONSTRAINT [CK__aud_accou__netti__129EAA56] CHECK (([netting_vouchers_ind]='N' OR [netting_vouchers_ind]='Y'))
GO
CREATE NONCLUSTERED INDEX [aud_account_commkt_gtc] ON [dbo].[aud_account_commkt_gtc] ([acct_num], [commkt_key], [booking_company_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_commkt_gtc_idx1] ON [dbo].[aud_account_commkt_gtc] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_account_commkt_gtc] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_account_commkt_gtc] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_account_commkt_gtc] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_account_commkt_gtc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_commkt_gtc] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_account_commkt_gtc', NULL, NULL
GO

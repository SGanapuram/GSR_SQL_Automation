CREATE TABLE [dbo].[aud_acct_bookcomp_guarantee]
(
[acct_guarantee_num] [int] NOT NULL,
[acct_bookcomp_key] [int] NOT NULL,
[guarantee_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[guarantee_amt] [numeric] (20, 8) NOT NULL,
[guarantee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[guarantee_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[guarantor_acct_num] [int] NULL,
[eff_date] [datetime] NOT NULL,
[maturity_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_guarantee] ON [dbo].[aud_acct_bookcomp_guarantee] ([acct_guarantee_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_guarantee_idx1] ON [dbo].[aud_acct_bookcomp_guarantee] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_bookcomp_guarantee] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_bookcomp_guarantee] TO [next_usr]
GO

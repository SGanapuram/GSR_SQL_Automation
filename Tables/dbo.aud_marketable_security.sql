CREATE TABLE [dbo].[aud_marketable_security]
(
[mkt_security_num] [int] NOT NULL,
[mrk_sec_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NULL,
[doc_num] [int] NULL,
[description] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[issue_date] [datetime] NULL,
[expiry_date] [datetime] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[face_amount] [float] NOT NULL,
[face_amt_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[percent_amount] [float] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_marketable_security_idx1] ON [dbo].[aud_marketable_security] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_marketable_security] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_marketable_security] TO [next_usr]
GO

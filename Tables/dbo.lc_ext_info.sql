CREATE TABLE [dbo].[lc_ext_info]
(
[lc_num] [int] NULL,
[red_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[auto_escalation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[place_of_payment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[place_of_expiry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_ship_date] [datetime] NULL,
[lc_rate] [float] NULL,
[latest_present_term] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[latest_present_date] [datetime] NULL,
[discount_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[issuing_acct_bank_id] [int] NULL,
[advising_acct_bank_id] [int] NULL,
[confirming_acct_bank_id] [int] NULL,
[guarantee_acct_bank_id] [int] NULL,
[negotiating_acct_bank_id] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[lc_ext_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lc_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lc_ext_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lc_ext_info] TO [next_usr]
GO

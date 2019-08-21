CREATE TABLE [dbo].[aud_margin_call]
(
[margin_call_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[doc_num] [int] NULL,
[party_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[call_date] [datetime] NOT NULL,
[cost_num] [int] NULL,
[call_amount] [float] NOT NULL,
[call_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[total_mtm_exp] [float] NOT NULL,
[total_mtm_curr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[call_status] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[due_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_margin_call] ON [dbo].[aud_margin_call] ([mca_num], [call_date], [cost_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_margin_call_idx1] ON [dbo].[aud_margin_call] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_margin_call] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_margin_call] TO [next_usr]
GO

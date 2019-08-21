CREATE TABLE [dbo].[aud_posting_account]
(
[posting_account_num] [int] NOT NULL,
[cost_period_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_dr_code] [char] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gl_acct_cr_code] [char] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_comp_num] [int] NULL,
[profit_center] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[port_num] [int] NULL,
[pos_group_num] [int] NULL,
[cost_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_prim_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_est_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bus_cost_type_num] [int] NULL,
[vc_acct_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_posting_account] ON [dbo].[aud_posting_account] ([posting_account_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_posting_account_idx1] ON [dbo].[aud_posting_account] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_posting_account] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_posting_account] TO [next_usr]
GO

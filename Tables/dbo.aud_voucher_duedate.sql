CREATE TABLE [dbo].[aud_voucher_duedate]
(
[voucher_num] [int] NOT NULL,
[voudue_duedate] [datetime] NOT NULL,
[voudue_seq_num] [smallint] NOT NULL,
[voudue_amt] [float] NULL,
[voudue_pay_recv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_tot_paid_amt] [float] NULL,
[voudue_revised_due_date] [datetime] NULL,
[voudue_cancel_corr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_creation_date] [datetime] NULL,
[voudue_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voudue_mod_date] [datetime] NULL,
[voudue_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_duedate_idx1] ON [dbo].[aud_voucher_duedate] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_duedate] ON [dbo].[aud_voucher_duedate] ([voucher_num], [voudue_duedate], [voudue_seq_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voucher_duedate] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voucher_duedate] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voucher_duedate] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voucher_duedate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_duedate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voucher_duedate', NULL, NULL
GO

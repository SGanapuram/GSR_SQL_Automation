CREATE TABLE [dbo].[aud_payment_term]
(
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_term_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [smallint] NULL,
[pay_term_contr_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_event3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind1] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind2] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_ba_ind3] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_days1] [smallint] NULL,
[pay_term_days2] [smallint] NULL,
[pay_term_days3] [smallint] NULL,
[accounting_pay_term] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_trans_cat1] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accounting_trans_cat2] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[holiday_split] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weekend_split] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_payment_term] ON [dbo].[aud_payment_term] ([pay_term_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_payment_term_idx1] ON [dbo].[aud_payment_term] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_payment_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_payment_term] TO [next_usr]
GO

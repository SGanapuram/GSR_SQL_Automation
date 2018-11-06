CREATE TABLE [dbo].[aud_credit_alarm]
(
[credit_limit_num] [int] NOT NULL,
[alarm_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alarm_percent_amt] [float] NULL,
[alarm_notify_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[notify_email_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alarm_cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_alarm] ON [dbo].[aud_credit_alarm] ([credit_limit_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_alarm_idx1] ON [dbo].[aud_credit_alarm] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_credit_alarm] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_credit_alarm] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_credit_alarm] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_credit_alarm] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_alarm] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_credit_alarm', NULL, NULL
GO

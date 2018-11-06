CREATE TABLE [dbo].[aud_bank_credit_alarm_log]
(
[credit_alarm_log_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bank_credit_alarm_log] ON [dbo].[aud_bank_credit_alarm_log] ([credit_alarm_log_num], [acct_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bank_credit_alarm_lo_idx1] ON [dbo].[aud_bank_credit_alarm_log] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_bank_credit_alarm_log] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_bank_credit_alarm_log] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_bank_credit_alarm_log] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_bank_credit_alarm_log] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_bank_credit_alarm_log] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_bank_credit_alarm_log', NULL, NULL
GO

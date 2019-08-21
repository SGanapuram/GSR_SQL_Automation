CREATE TABLE [dbo].[aud_credit_alarm_log_comment]
(
[alarm_log_cmnt_num] [int] NOT NULL,
[cmnt_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_alarm_log_comment] ON [dbo].[aud_credit_alarm_log_comment] ([alarm_log_cmnt_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_alarm_log_com_idx1] ON [dbo].[aud_credit_alarm_log_comment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_credit_alarm_log_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_alarm_log_comment] TO [next_usr]
GO

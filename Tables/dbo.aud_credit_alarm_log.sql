CREATE TABLE [dbo].[aud_credit_alarm_log]
(
[credit_limit_num] [int] NOT NULL,
[credit_alarm_log_num] [int] NOT NULL,
[over_limit_amt] [float] NOT NULL,
[alarm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[time_of_log] [datetime] NOT NULL,
[alarm_log_cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_alarm_log] ON [dbo].[aud_credit_alarm_log] ([credit_limit_num], [credit_alarm_log_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_alarm_log_idx1] ON [dbo].[aud_credit_alarm_log] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_credit_alarm_log] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_alarm_log] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_country_credit_alarm_log]
(
[credit_alarm_log_num] [int] NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_country_credit_alarm_log] ON [dbo].[aud_country_credit_alarm_log] ([credit_alarm_log_num], [country_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_country_credit_alarm_idx1] ON [dbo].[aud_country_credit_alarm_log] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_country_credit_alarm_log] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_country_credit_alarm_log] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_lm_risk_exch_rate]
(
[exch_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_date] [datetime] NOT NULL,
[from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exch_rate] [decimal] (20, 8) NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_risk_exch_rate] ON [dbo].[aud_lm_risk_exch_rate] ([exch_code], [quote_date], [from_curr_code], [to_curr_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_risk_exch_rate_idx1] ON [dbo].[aud_lm_risk_exch_rate] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lm_risk_exch_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lm_risk_exch_rate] TO [next_usr]
GO

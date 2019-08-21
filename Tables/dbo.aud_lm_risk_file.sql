CREATE TABLE [dbo].[aud_lm_risk_file]
(
[oid] [int] NOT NULL,
[exch_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_file_date] [datetime] NOT NULL,
[risk_file_status] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_filename] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_risk_file] ON [dbo].[aud_lm_risk_file] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lm_risk_file_idx1] ON [dbo].[aud_lm_risk_file] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lm_risk_file] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lm_risk_file] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_risk_transfer_indicator]
(
[risk_transfer_ind_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_transfer_ind_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_risk_transfer_indicator] ON [dbo].[aud_risk_transfer_indicator] ([risk_transfer_ind_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_risk_transfer_ind_idx1] ON [dbo].[aud_risk_transfer_indicator] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_risk_transfer_indicator] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_risk_transfer_indicator] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_otc_option_value]
(
[otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[otc_opt_quote_date] [datetime] NOT NULL,
[otc_opt_price] [float] NULL,
[otc_opt_delta] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_otc_option_value] ON [dbo].[aud_otc_option_value] ([otc_opt_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_otc_option_value_idx1] ON [dbo].[aud_otc_option_value] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_otc_option_value] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_otc_option_value] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_otc_option_value] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_otc_option_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_otc_option_value] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_otc_option_value', NULL, NULL
GO

CREATE TABLE [dbo].[aud_quote_period_description]
(
[id] [int] NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_prd_duration_id] [int] NULL,
[start_date] [datetime] NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_period_description] ON [dbo].[aud_quote_period_description] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_period_description_idx1] ON [dbo].[aud_quote_period_description] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_quote_period_description] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quote_period_description] TO [next_usr]
GO

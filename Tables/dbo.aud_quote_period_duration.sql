CREATE TABLE [dbo].[aud_quote_period_duration]
(
[id] [int] NOT NULL,
[days] [int] NOT NULL,
[months] [int] NOT NULL,
[name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_period_duration] ON [dbo].[aud_quote_period_duration] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_period_duration_idx1] ON [dbo].[aud_quote_period_duration] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_quote_period_duration] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_quote_period_duration] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_quote_period_duration] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_quote_period_duration] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quote_period_duration] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_quote_period_duration', NULL, NULL
GO

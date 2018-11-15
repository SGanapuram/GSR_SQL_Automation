CREATE TABLE [dbo].[aud_valid_quote_duration]
(
[id] [int] NOT NULL,
[quote_id] [int] NOT NULL,
[quote_period_duration_id] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_valid_quote_duration] ON [dbo].[aud_valid_quote_duration] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_valid_quote_duration_idx1] ON [dbo].[aud_valid_quote_duration] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_valid_quote_duration] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_valid_quote_duration] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_valid_quote_duration] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_valid_quote_duration] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_valid_quote_duration] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_valid_quote_duration', NULL, NULL
GO

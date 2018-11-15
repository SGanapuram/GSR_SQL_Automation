CREATE TABLE [dbo].[aud_quote]
(
[id] [int] NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pl_qmds_id] [int] NULL,
[product_id] [int] NOT NULL,
[report_qmds_id] [int] NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[symbol] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_for_pl] [bit] NOT NULL,
[venue_id] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[symbol_regex] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote] ON [dbo].[aud_quote] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_idx1] ON [dbo].[aud_quote] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_quote] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_quote] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_quote] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_quote] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quote] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_quote', NULL, NULL
GO

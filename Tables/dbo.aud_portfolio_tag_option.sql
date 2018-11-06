CREATE TABLE [dbo].[aud_portfolio_tag_option]
(
[tag_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_option] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_option_desc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tag_option_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_tag_option] ON [dbo].[aud_portfolio_tag_option] ([tag_name], [tag_option], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_tag_option_idx1] ON [dbo].[aud_portfolio_tag_option] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_portfolio_tag_option] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_tag_option] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_portfolio_tag_option] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_tag_option] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_tag_option] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_portfolio_tag_option', NULL, NULL
GO

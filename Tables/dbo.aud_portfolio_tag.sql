CREATE TABLE [dbo].[aud_portfolio_tag]
(
[tag_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_num] [int] NOT NULL,
[tag_value] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_tag] ON [dbo].[aud_portfolio_tag] ([tag_name], [port_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_tag_idx1] ON [dbo].[aud_portfolio_tag] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_portfolio_tag] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_tag] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_portfolio_tag] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_tag] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_tag] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_portfolio_tag', NULL, NULL
GO

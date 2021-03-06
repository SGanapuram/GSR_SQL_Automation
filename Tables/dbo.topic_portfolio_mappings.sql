CREATE TABLE [dbo].[topic_portfolio_mappings]
(
[topicPortId] [int] NOT NULL IDENTITY(1, 1),
[exchangeName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[topic_portfolio_mappings] ADD CONSTRAINT [topic_portfolio_mappings_pk] PRIMARY KEY CLUSTERED  ([topicPortId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [topic_portfolio_mappings] ON [dbo].[topic_portfolio_mappings] ([exchangeName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[topic_portfolio_mappings] ADD CONSTRAINT [UQ_topic_portfolio_mappings_port_num] UNIQUE NONCLUSTERED  ([port_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[topic_portfolio_mappings] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[topic_portfolio_mappings] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[topic_portfolio_mappings] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[topic_portfolio_mappings] TO [next_usr]
GO

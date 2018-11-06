CREATE TABLE [dbo].[portfolio_group_eod]
(
[parent_port_num] [int] NOT NULL,
[port_num] [int] NOT NULL,
[is_link_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio_group_eod] ADD CONSTRAINT [portfolio_group_eod_pk] PRIMARY KEY CLUSTERED  ([parent_port_num], [port_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_group_eod] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_group_eod] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_group_eod] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_group_eod] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_group_eod', NULL, NULL
GO

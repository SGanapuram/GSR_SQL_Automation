CREATE TABLE [dbo].[external_trade]
(
[oid] [int] NOT NULL,
[entry_date] [datetime] NOT NULL,
[external_trade_system_oid] [int] NOT NULL,
[external_trade_status_oid] [int] NOT NULL,
[external_trade_source_oid] [int] NOT NULL,
[port_num] [int] NULL,
[trade_num] [int] NULL,
[trans_id] [int] NOT NULL,
[sequence] [numeric] (32, 0) NOT NULL IDENTITY(1, 1),
[external_comment_oid] [int] NULL,
[inhouse_port_num] [int] NULL,
[external_trade_state_oid] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[ext_pos_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_trade] ADD CONSTRAINT [external_trade_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [external_trade_idx2] ON [dbo].[external_trade] ([external_comment_oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [external_trade_idx4] ON [dbo].[external_trade] ([oid], [external_trade_status_oid], [external_trade_source_oid]) INCLUDE ([sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [external_trade_idx3] ON [dbo].[external_trade] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_trade] ADD CONSTRAINT [external_trade_fk1] FOREIGN KEY ([external_trade_system_oid]) REFERENCES [dbo].[external_trade_system] ([oid])
GO
ALTER TABLE [dbo].[external_trade] ADD CONSTRAINT [external_trade_fk2] FOREIGN KEY ([external_trade_status_oid]) REFERENCES [dbo].[external_trade_status] ([oid])
GO
ALTER TABLE [dbo].[external_trade] ADD CONSTRAINT [external_trade_fk3] FOREIGN KEY ([external_trade_source_oid]) REFERENCES [dbo].[external_trade_source] ([oid])
GO
ALTER TABLE [dbo].[external_trade] ADD CONSTRAINT [external_trade_fk5] FOREIGN KEY ([external_trade_state_oid]) REFERENCES [dbo].[external_trade_state] ([oid])
GO
ALTER TABLE [dbo].[external_trade] ADD CONSTRAINT [external_trade_fk6] FOREIGN KEY ([ext_pos_num]) REFERENCES [dbo].[external_position] ([ext_pos_num])
GO
GRANT DELETE ON  [dbo].[external_trade] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_trade] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_trade] TO [next_usr]
GO

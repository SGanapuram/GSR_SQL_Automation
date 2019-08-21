CREATE TABLE [dbo].[external_trade_archive]
(
[oid] [int] NOT NULL,
[entry_date] [datetime] NOT NULL,
[external_trade_system_oid] [int] NOT NULL,
[external_trade_status_oid] [int] NOT NULL,
[external_trade_source_oid] [int] NOT NULL,
[port_num] [int] NULL,
[trade_num] [int] NULL,
[trans_id] [int] NOT NULL,
[sequence] [numeric] (32, 0) NOT NULL,
[external_comment_oid] [int] NULL,
[inhouse_port_num] [int] NULL,
[external_trade_state_oid] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[ext_pos_num] [int] NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [df_external_trade_archive_archived_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_trade_archive] ADD CONSTRAINT [external_trade_archive_pk] PRIMARY KEY CLUSTERED  ([oid], [archived_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [external_trade_archive_idx1] ON [dbo].[external_trade_archive] ([external_comment_oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [external_trade_archive_idx2] ON [dbo].[external_trade_archive] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[external_trade_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_trade_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_trade_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_trade_archive] TO [next_usr]
GO

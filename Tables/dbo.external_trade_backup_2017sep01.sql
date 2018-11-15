CREATE TABLE [dbo].[external_trade_backup_2017sep01]
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
GRANT SELECT ON  [dbo].[external_trade_backup_2017sep01] TO [next_usr]
GO

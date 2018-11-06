CREATE TABLE [dbo].[aud_external_trade]
(
[oid] [int] NOT NULL,
[entry_date] [datetime] NOT NULL,
[external_trade_system_oid] [int] NOT NULL,
[external_trade_status_oid] [int] NOT NULL,
[external_trade_source_oid] [int] NOT NULL,
[port_num] [int] NULL,
[trade_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[sequence] [numeric] (32, 0) NOT NULL,
[external_comment_oid] [int] NULL,
[inhouse_port_num] [int] NULL,
[external_trade_state_oid] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[ext_pos_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade] ON [dbo].[aud_external_trade] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade_idx1] ON [dbo].[aud_external_trade] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_external_trade] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_external_trade] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_external_trade] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_external_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_external_trade', NULL, NULL
GO

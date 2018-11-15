CREATE TABLE [dbo].[aud_strategy_execution]
(
[oid] [int] NOT NULL,
[real_port_num] [int] NOT NULL,
[shipment_num] [int] NULL,
[alloc_num] [int] NULL,
[strategy_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_strategy_detail_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_strategy_execution] ON [dbo].[aud_strategy_execution] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_strategy_execution_idx1] ON [dbo].[aud_strategy_execution] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_strategy_execution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_strategy_execution] TO [next_usr]
GO

CREATE TABLE [dbo].[strategy_execution]
(
[oid] [int] NOT NULL,
[real_port_num] [int] NOT NULL,
[shipment_num] [int] NULL,
[alloc_num] [int] NULL,
[strategy_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_strategy_detail_num] [smallint] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[strategy_execution] ADD CONSTRAINT [strategy_execution_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[strategy_execution] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[strategy_execution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[strategy_execution] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[strategy_execution] TO [next_usr]
GO

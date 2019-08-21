CREATE TABLE [dbo].[contract_exec_detail]
(
[oid] [int] NOT NULL,
[object_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[obj_key1] [int] NOT NULL,
[obj_key2] [smallint] NULL,
[obj_key3] [smallint] NULL,
[contract_execution_oid] [int] NOT NULL,
[conc_del_item_oid] [int] NULL,
[trans_id] [int] NOT NULL,
[assay_group_num] [int] NULL,
[exec_qty] [float] NULL,
[exec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract_exec_detail] ADD CONSTRAINT [contract_exec_detail_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract_exec_detail] ADD CONSTRAINT [contract_exec_detail_fk1] FOREIGN KEY ([conc_del_item_oid]) REFERENCES [dbo].[conc_delivery_item] ([oid])
GO
ALTER TABLE [dbo].[contract_exec_detail] ADD CONSTRAINT [contract_exec_detail_fk2] FOREIGN KEY ([contract_execution_oid]) REFERENCES [dbo].[contract_execution] ([oid])
GO
ALTER TABLE [dbo].[contract_exec_detail] ADD CONSTRAINT [contract_exec_detail_fk3] FOREIGN KEY ([exec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[contract_exec_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[contract_exec_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[contract_exec_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[contract_exec_detail] TO [next_usr]
GO

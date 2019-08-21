CREATE TABLE [dbo].[aud_contract_exec_detail]
(
[oid] [int] NOT NULL,
[object_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[obj_key1] [int] NOT NULL,
[obj_key2] [smallint] NULL,
[obj_key3] [smallint] NULL,
[contract_execution_oid] [int] NOT NULL,
[conc_del_item_oid] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[assay_group_num] [int] NULL,
[exec_qty] [float] NULL,
[exec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_exec_detail] ON [dbo].[aud_contract_exec_detail] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_exec_detail_idx1] ON [dbo].[aud_contract_exec_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_contract_exec_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_contract_exec_detail] TO [next_usr]
GO

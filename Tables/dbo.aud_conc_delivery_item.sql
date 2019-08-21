CREATE TABLE [dbo].[aud_conc_delivery_item]
(
[oid] [int] NOT NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_status_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_qty] [float] NULL,
[actual_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_execution_oid] [int] NULL,
[title_document_num] [int] NULL,
[cmnt_num] [int] NULL,
[total_exec_qty] [float] NULL,
[total_exec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_qty] [float] NULL,
[del_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[conc_delivery_schedule_oid] [int] NULL,
[prorated_flat_amt] [float] NULL,
[flat_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_delivery_lot_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_delivery_item] ON [dbo].[aud_conc_delivery_item] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_delivery_item_idx1] ON [dbo].[aud_conc_delivery_item] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_delivery_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_delivery_item] TO [next_usr]
GO

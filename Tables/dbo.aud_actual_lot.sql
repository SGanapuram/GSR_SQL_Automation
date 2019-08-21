CREATE TABLE [dbo].[aud_actual_lot]
(
[actual_lot_num] [int] NOT NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[source_alloc_num] [int] NOT NULL,
[source_alloc_item_num] [smallint] NOT NULL,
[source_ai_est_actual_num] [smallint] NOT NULL,
[gross_qty] [numeric] (20, 8) NULL,
[net_qty] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[secondary_gross_qty] [numeric] (20, 8) NULL,
[secondary_net_qty] [numeric] (20, 8) NULL,
[secondary_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_num] [int] NULL,
[tax_qualification_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lot_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[source_actual_lot_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_actual_lot_idx1] ON [dbo].[aud_actual_lot] ([actual_lot_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_actual_lot_idx2] ON [dbo].[aud_actual_lot] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_actual_lot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_actual_lot] TO [next_usr]
GO

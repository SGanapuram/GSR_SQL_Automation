CREATE TABLE [dbo].[aud_allocation_transfer]
(
[source_inv_num] [int] NULL,
[source_invbd_num] [int] NULL,
[target_inv_num] [int] NULL,
[target_invbd_num] [int] NULL,
[transfer_qty] [float] NOT NULL,
[transfer_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[transfer_price] [float] NULL,
[transfer_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[source_alloc_num] [int] NOT NULL,
[source_alloc_item_num] [smallint] NOT NULL,
[target_alloc_num] [int] NOT NULL,
[target_alloc_item_num] [smallint] NOT NULL,
[transfer_price_curr_code_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_currency_rate] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_transfer] ON [dbo].[aud_allocation_transfer] ([source_alloc_num], [source_alloc_item_num], [target_alloc_num], [target_alloc_item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_transfer_idx1] ON [dbo].[aud_allocation_transfer] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_allocation_transfer] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_transfer] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_transfer', NULL, NULL
GO

CREATE TABLE [dbo].[aud_inv_actual_fifo]
(
[oid] [int] NOT NULL,
[draw_inv_actual_num] [int] NOT NULL,
[build_inv_actual_num] [int] NOT NULL,
[fifo_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_actual_fifo] ON [dbo].[aud_inv_actual_fifo] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_actual_fifo_idx1] ON [dbo].[aud_inv_actual_fifo] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_inv_actual_fifo] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_inv_actual_fifo] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_inv_actual_fifo] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_inv_actual_fifo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inv_actual_fifo] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_inv_actual_fifo', NULL, NULL
GO

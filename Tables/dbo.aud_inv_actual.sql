CREATE TABLE [dbo].[aud_inv_actual]
(
[oid] [int] NOT NULL,
[inv_fifo_num] [int] NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NULL,
[inv_num] [int] NULL,
[inv_b_d_num] [int] NULL,
[build_draw_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[actual_date] [datetime] NOT NULL,
[actual_qty] [float] NOT NULL,
[fifoed_qty] [float] NOT NULL,
[open_qty] [float] NOT NULL,
[adjustment_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sec_actual_qty] [float] NOT NULL,
[sec_fifoed_qty] [float] NOT NULL,
[sec_open_qty] [float] NOT NULL,
[sec_adjustment_qty] [float] NOT NULL,
[sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[avg_price] [float] NULL,
[real_avg_price] [float] NULL,
[unreal_avg_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field1] [int] NULL,
[field2] [float] NULL,
[field3] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field4] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[pos_adj_qty] [numeric] (20, 8) NULL,
[neg_adj_qty] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_actual] ON [dbo].[aud_inv_actual] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_actual_idx1] ON [dbo].[aud_inv_actual] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_inv_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inv_actual] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_ai_est_actual_detail]
(
[detail_num] [int] NOT NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[creation_date] [datetime] NULL,
[actual_date] [datetime] NOT NULL,
[actual_gross_qty] [float] NULL,
[actual_gross_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_net_qty] [float] NULL,
[actual_net_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_actual_gross_qty] [float] NULL,
[sec_actual_gross_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_actual_net_qty] [float] NULL,
[sec_actual_net_qty_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[unit_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_actual_detail] ON [dbo].[aud_ai_est_actual_detail] ([detail_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_actual_detail_idx1] ON [dbo].[aud_ai_est_actual_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ai_est_actual_detail] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual_detail] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ai_est_actual_detail] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ai_est_actual_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ai_est_actual_detail', NULL, NULL
GO

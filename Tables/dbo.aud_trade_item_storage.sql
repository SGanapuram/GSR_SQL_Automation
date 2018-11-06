CREATE TABLE [dbo].[aud_trade_item_storage]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[stored_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sublease_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_start_date] [datetime] NULL,
[storage_end_date] [datetime] NULL,
[storage_avail_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_prd] [int] NULL,
[storage_prd_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shrinkage_qty] [float] NULL,
[shrinkage_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loss_allowance_qty] [float] NULL,
[loss_allowance_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_operating_qty] [float] NULL,
[min_operating_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[storage_subloc_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[pipeline_cycle_num] [int] NULL,
[timing_cycle_year] [smallint] NULL,
[tank_num] [int] NULL,
[target_min_qty] [decimal] (20, 8) NULL,
[target_max_qty] [decimal] (20, 8) NULL,
[capacity] [decimal] (20, 8) NULL,
[min_op_req_qty] [decimal] (20, 8) NULL,
[safe_fill] [decimal] (20, 8) NULL,
[heel] [decimal] (20, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_storage] ON [dbo].[aud_trade_item_storage] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_storage_idx1] ON [dbo].[aud_trade_item_storage] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_storage] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_storage] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_storage] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_storage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_storage] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_storage', NULL, NULL
GO

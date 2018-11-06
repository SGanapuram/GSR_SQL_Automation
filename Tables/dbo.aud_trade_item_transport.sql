CREATE TABLE [dbo].[aud_trade_item_transport]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[transport_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_date_from] [datetime] NULL,
[load_date_to] [datetime] NULL,
[disch_date_from] [datetime] NULL,
[disch_date_to] [datetime] NULL,
[load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [float] NULL,
[tol_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_ship_qty] [float] NULL,
[min_ship_qty_uom_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[overrun_price] [float] NULL,
[overrun_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[overrun_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shrinkage_qty] [float] NULL,
[shrinkage_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loss_allowance_qty] [float] NULL,
[loss_allowance_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[demurrage_price] [float] NULL,
[demurrage_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[demurrage_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dispatch_price] [float] NULL,
[dispatch_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dispatch_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[free_time] [smallint] NULL,
[free_time_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pump_rate_qty] [float] NULL,
[pump_rate_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pump_rate_time_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[container_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[number_of_trucks] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[pipeline_cycle_num] [int] NULL,
[timing_cycle_year] [smallint] NULL,
[target_min_qty] [decimal] (20, 8) NULL,
[target_max_qty] [decimal] (20, 8) NULL,
[capacity] [decimal] (20, 8) NULL,
[min_op_req_qty] [decimal] (20, 8) NULL,
[safe_fill] [decimal] (20, 8) NULL,
[heel] [decimal] (20, 8) NULL,
[tank_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_transport] ON [dbo].[aud_trade_item_transport] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_transport_idx1] ON [dbo].[aud_trade_item_transport] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_trade_item_transport] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_transport] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_trade_item_transport] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_transport] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_transport] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_trade_item_transport', NULL, NULL
GO

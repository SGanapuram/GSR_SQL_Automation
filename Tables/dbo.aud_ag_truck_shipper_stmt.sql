CREATE TABLE [dbo].[aud_ag_truck_shipper_stmt]
(
[fdd_id] [int] NOT NULL,
[lease_num] [int] NULL,
[lease_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[purchaser] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_per_mile] [numeric] (20, 8) NULL,
[destination] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volume] [numeric] (20, 8) NULL,
[miles] [numeric] (20, 8) NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rate] [numeric] (20, 8) NULL,
[fuel_rate] [numeric] (20, 8) NULL,
[total_rate] [numeric] (20, 8) NULL,
[barrels_charge] [numeric] (20, 8) NULL,
[split_rate] [numeric] (20, 8) NULL,
[reject_rate] [numeric] (20, 8) NULL,
[bob_tail_qty] [numeric] (20, 8) NULL,
[bob_tail] [numeric] (20, 8) NULL,
[chain_up_qty] [numeric] (20, 8) NULL,
[chain_up] [numeric] (20, 8) NULL,
[demurrage_hours] [numeric] (20, 8) NULL,
[demurrage] [numeric] (20, 8) NULL,
[divert] [numeric] (20, 8) NULL,
[total_charge] [numeric] (20, 8) NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_num] [smallint] NULL,
[actual_cost] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col7] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col8] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col9] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col10] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_truck_shipper_stmt] ON [dbo].[aud_ag_truck_shipper_stmt] ([fdd_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_truck_shipper_stmt_idx1] ON [dbo].[aud_ag_truck_shipper_stmt] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ag_truck_shipper_stmt] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ag_truck_shipper_stmt] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ag_truck_shipper_stmt] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ag_truck_shipper_stmt] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_truck_shipper_stmt] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ag_truck_shipper_stmt', NULL, NULL
GO

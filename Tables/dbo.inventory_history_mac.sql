CREATE TABLE [dbo].[inventory_history_mac]
(
[inv_history_mac_num] [numeric] (32, 0) NOT NULL IDENTITY(1, 1),
[asof_date] [datetime] NOT NULL,
[inv_num] [int] NOT NULL,
[real_port_num] [int] NOT NULL,
[draw_alloc_num] [int] NOT NULL,
[draw_alloc_item_num] [smallint] NOT NULL,
[draw_ai_est_actual_num] [smallint] NOT NULL,
[amt_owner_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[amt_owner_num] [int] NOT NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_date] [datetime] NULL,
[cost_amt_ratio] [numeric] (20, 8) NULL,
[r_cost_amt] [numeric] (20, 8) NULL,
[dlvry_alloc_num] [int] NULL,
[dlvry_alloc_item_num] [smallint] NULL,
[dlvry_ai_est_actual_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[unr_cost_amt] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory_history_mac] ADD CONSTRAINT [inventory_history_mac_pk] PRIMARY KEY CLUSTERED  ([inv_history_mac_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_history_mac_idx] ON [dbo].[inventory_history_mac] ([asof_date], [inv_num], [real_port_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inventory_history_mac] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory_history_mac] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory_history_mac] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory_history_mac] TO [next_usr]
GO

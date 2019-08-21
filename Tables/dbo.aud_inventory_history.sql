CREATE TABLE [dbo].[aud_inventory_history]
(
[asof_date] [datetime] NOT NULL,
[real_port_num] [int] NOT NULL,
[inv_num] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[cost_due_date] [datetime] NOT NULL,
[inv_balance_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_trade_num] [int] NOT NULL,
[cost_order_num] [int] NOT NULL,
[cost_item_num] [int] NOT NULL,
[rcpt_alloc_num] [int] NOT NULL,
[rcpt_alloc_item_num] [int] NOT NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_acct_num] [int] NOT NULL,
[r_cost_amt] [float] NULL,
[unr_cost_amt] [float] NULL,
[cost_amt_ratio] [float] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory_history] ON [dbo].[aud_inventory_history] ([asof_date], [real_port_num], [inv_num], [cost_num], [rcpt_alloc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory_history_idx1] ON [dbo].[aud_inventory_history] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_inventory_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inventory_history] TO [next_usr]
GO

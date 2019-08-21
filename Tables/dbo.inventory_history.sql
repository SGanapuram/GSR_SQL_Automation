CREATE TABLE [dbo].[inventory_history]
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
[trans_id] [bigint] NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[inventory_history] ADD CONSTRAINT [inventory_history_pk] PRIMARY KEY CLUSTERED  ([asof_date], [real_port_num], [inv_num], [cost_num], [rcpt_alloc_num]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_history_idx1] ON [dbo].[inventory_history] ([real_port_num], [asof_date]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inventory_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory_history] TO [next_usr]
GO

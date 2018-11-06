CREATE TABLE [dbo].[aud_allocation_pl]
(
[alloc_num] [int] NOT NULL,
[pos_group_num] [int] NULL,
[alloc_pl_sales_amt] [float] NULL,
[alloc_pl_purchase_amt] [float] NULL,
[alloc_pl_sec_costs_amt] [float] NULL,
[alloc_pl_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_pl] ON [dbo].[aud_allocation_pl] ([alloc_num], [pos_group_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_pl_idx1] ON [dbo].[aud_allocation_pl] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_allocation_pl] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_allocation_pl] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_allocation_pl] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_allocation_pl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_pl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_pl', NULL, NULL
GO

CREATE TABLE [dbo].[aud_bus_cost_order_group]
(
[bc_type_num] [smallint] NOT NULL,
[order_type_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_order_group] ON [dbo].[aud_bus_cost_order_group] ([bc_type_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_order_group_idx1] ON [dbo].[aud_bus_cost_order_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_bus_cost_order_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_bus_cost_order_group] TO [next_usr]
GO

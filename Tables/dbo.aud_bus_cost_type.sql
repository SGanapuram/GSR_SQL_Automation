CREATE TABLE [dbo].[aud_bus_cost_type]
(
[bc_type_num] [smallint] NOT NULL,
[bc_type_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_type_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_type_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_children_type_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_num_children_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_child_gen_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_parent_type_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_init_fate_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_owner_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_sub_owner_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_init_leaf_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_matriarch_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_type] ON [dbo].[aud_bus_cost_type] ([bc_type_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_type_idx1] ON [dbo].[aud_bus_cost_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_bus_cost_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_bus_cost_type] TO [next_usr]
GO

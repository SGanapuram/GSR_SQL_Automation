CREATE TABLE [dbo].[aud_bus_cost_state]
(
[bc_state_num] [smallint] NOT NULL,
[bc_state_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_state_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_state_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_state] ON [dbo].[aud_bus_cost_state] ([bc_state_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_state_idx1] ON [dbo].[aud_bus_cost_state] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_bus_cost_state] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_bus_cost_state] TO [next_usr]
GO

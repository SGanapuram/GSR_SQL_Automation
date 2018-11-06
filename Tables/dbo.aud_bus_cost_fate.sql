CREATE TABLE [dbo].[aud_bus_cost_fate]
(
[bc_fate_num] [smallint] NOT NULL,
[bc_fate_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_fate_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_fate_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_date_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_group_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_man_auto_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bc_fate_pay_days] [smallint] NULL,
[bc_fate_proc_spec] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_fate] ON [dbo].[aud_bus_cost_fate] ([bc_fate_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bus_cost_fate_idx1] ON [dbo].[aud_bus_cost_fate] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_bus_cost_fate] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_bus_cost_fate] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_bus_cost_fate] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_bus_cost_fate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_bus_cost_fate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_bus_cost_fate', NULL, NULL
GO

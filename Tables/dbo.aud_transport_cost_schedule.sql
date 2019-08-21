CREATE TABLE [dbo].[aud_transport_cost_schedule]
(
[oid] [int] NOT NULL,
[mot_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[storage_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[global_qty_min] [float] NULL,
[global_qty_max] [float] NULL,
[global_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gq_min_incl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gq_max_incl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_amt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_amt] [float] NOT NULL,
[cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_transport_cost_sched_idx1] ON [dbo].[aud_transport_cost_schedule] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_transport_cost_sched_idx2] ON [dbo].[aud_transport_cost_schedule] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_transport_cost_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_transport_cost_schedule] TO [next_usr]
GO

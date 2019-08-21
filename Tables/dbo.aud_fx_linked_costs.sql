CREATE TABLE [dbo].[aud_fx_linked_costs]
(
[fx_link_oid] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[curr_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_linked_costs] ON [dbo].[aud_fx_linked_costs] ([fx_link_oid], [cost_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_linked_costs_idx1] ON [dbo].[aud_fx_linked_costs] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fx_linked_costs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_linked_costs] TO [next_usr]
GO

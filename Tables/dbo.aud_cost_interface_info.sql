CREATE TABLE [dbo].[aud_cost_interface_info]
(
[cost_num] [int] NOT NULL,
[aot_status] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[aot_status_mod_date] [datetime] NULL,
[aot_status_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[sent_on_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_interface_info_idx] ON [dbo].[aud_cost_interface_info] ([cost_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_interface_info_idx1] ON [dbo].[aud_cost_interface_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_interface_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_interface_info] TO [next_usr]
GO

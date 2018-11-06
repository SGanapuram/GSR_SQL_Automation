CREATE TABLE [dbo].[aud_allocation_world_scale]
(
[alloc_num] [int] NOT NULL,
[origin_load_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[origin_del_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[origin_scale_rate] [float] NOT NULL,
[origin_scale_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[new_load_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[new_del_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[new_scale_rate] [float] NOT NULL,
[new_scale_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[charter_party_rate] [float] NOT NULL,
[charter_party_min] [float] NULL,
[actual_qty] [float] NOT NULL,
[due_date] [datetime] NULL,
[acct_num] [int] NOT NULL,
[book_comp_num] [int] NULL,
[pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_world_scale] ON [dbo].[aud_allocation_world_scale] ([alloc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_alloc_world_scale_idx1] ON [dbo].[aud_allocation_world_scale] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_allocation_world_scale] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_allocation_world_scale] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_allocation_world_scale] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_allocation_world_scale] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_world_scale] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_world_scale', NULL, NULL
GO

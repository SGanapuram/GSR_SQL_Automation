CREATE TABLE [dbo].[aud_allocation_type]
(
[alloc_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_type_desc] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[own_movement_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_type] ON [dbo].[aud_allocation_type] ([alloc_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_type_idx1] ON [dbo].[aud_allocation_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_allocation_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_type] TO [next_usr]
GO

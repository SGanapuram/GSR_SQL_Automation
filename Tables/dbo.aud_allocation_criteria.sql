CREATE TABLE [dbo].[aud_allocation_criteria]
(
[alloc_criteria_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[default_alloc_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[auto_alloc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_match_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_alloc_criteria_idx1] ON [dbo].[aud_allocation_criteria] ([cmdty_code], [loc_code], [mot_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_criteria_idx2] ON [dbo].[aud_allocation_criteria] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_allocation_criteria] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_criteria] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_allocation_item_insp]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[insp_comp_num] [int] NOT NULL,
[insp_comp_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[insp_fee_split_count] [tinyint] NOT NULL,
[insp_fee_amt] [float] NOT NULL,
[insp_fee_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[insp_fee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ai_insp_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_insp] ON [dbo].[aud_allocation_item_insp] ([alloc_num], [alloc_item_num], [insp_comp_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_item_insp_idx1] ON [dbo].[aud_allocation_item_insp] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_allocation_item_insp] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_allocation_item_insp] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_allocation_item_insp] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_allocation_item_insp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_item_insp] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_item_insp', NULL, NULL
GO

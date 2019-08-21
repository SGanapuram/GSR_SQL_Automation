CREATE TABLE [dbo].[aud_paper_allocation_item]
(
[paper_alloc_num] [int] NOT NULL,
[paper_alloc_item_num] [smallint] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_qty] [float] NOT NULL,
[alloc_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[fill_num] [smallint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_paper_allocation_item] ON [dbo].[aud_paper_allocation_item] ([paper_alloc_num], [paper_alloc_item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_paper_allocation_ite_idx1] ON [dbo].[aud_paper_allocation_item] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_paper_allocation_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_paper_allocation_item] TO [next_usr]
GO

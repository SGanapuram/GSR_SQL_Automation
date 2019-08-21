CREATE TABLE [dbo].[aud_paper_allocation]
(
[paper_alloc_num] [int] NOT NULL,
[pos_num] [int] NOT NULL,
[alloc_date] [datetime] NOT NULL,
[alloc_pl] [float] NULL,
[alloc_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_pl_calc_date] [datetime] NULL,
[alloc_pl_asof_date] [datetime] NULL,
[alloc_brokerage_cost] [float] NULL,
[paper_alloc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_paper_allocation] ON [dbo].[aud_paper_allocation] ([paper_alloc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_paper_allocation_idx1] ON [dbo].[aud_paper_allocation] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_paper_allocation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_paper_allocation] TO [next_usr]
GO

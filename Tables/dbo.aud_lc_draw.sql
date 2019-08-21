CREATE TABLE [dbo].[aud_lc_draw]
(
[lc_num] [int] NOT NULL,
[lc_alloc_num] [tinyint] NOT NULL,
[lc_draw_num] [tinyint] NOT NULL,
[lc_draw_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[trade_num] [int] NULL,
[trade_order_num] [smallint] NULL,
[trade_item_num] [smallint] NULL,
[lc_draw_down_amt] [float] NULL,
[lc_draw_down_qty] [float] NULL,
[lc_draw_down_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_presented_acct_num] [int] NULL,
[lc_presented_date] [datetime] NULL,
[lc_loi_presented_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_draw_up_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_draw] ON [dbo].[aud_lc_draw] ([lc_num], [lc_alloc_num], [lc_draw_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_draw_idx1] ON [dbo].[aud_lc_draw] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lc_draw] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_draw] TO [next_usr]
GO

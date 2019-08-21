CREATE TABLE [dbo].[pdfx_detail]
(
[pdfx_oid] [numeric] (32, 0) NOT NULL,
[pdfx_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_num] [int] NULL,
[order_num] [int] NULL,
[item_num] [int] NULL,
[cost_num] [int] NULL,
[port_num] [int] NULL,
[acct_num] [int] NULL,
[curr_status] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[paid_amt] [float] NULL,
[total_amt] [float] NULL,
[exch_rate] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[due_date] [datetime] NULL,
[paid_date] [datetime] NULL,
[cost_pl_contribution_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL,
[pdfx_cost_num] [int] NULL,
[pdfx_trade_num] [int] NULL,
[pdfx_order_num] [int] NULL,
[pdfx_item_num] [int] NULL,
[cost_code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_curr_code] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[processed_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pdfx_detail_idx1] ON [dbo].[pdfx_detail] ([cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pdfx_detail_idx3] ON [dbo].[pdfx_detail] ([cost_num]) INCLUDE ([paid_amt]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pdfx_detail_idx2] ON [dbo].[pdfx_detail] ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO

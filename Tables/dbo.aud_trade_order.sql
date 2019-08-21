CREATE TABLE [dbo].[aud_trade_order]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_order_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_order_num] [smallint] NULL,
[order_strategy_num] [smallint] NULL,
[order_strategy_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_strip_num] [smallint] NULL,
[strip_summary_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strip_detail_order_count] [smallint] NULL,
[strip_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strip_order_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[term_evergreen_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bal_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[margin_amt] [float] NULL,
[margin_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[efp_last_post_date] [datetime] NULL,
[cash_settle_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_saturdays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_sundays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_holidays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_prd_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_settle_prd_start_date] [datetime] NULL,
[commitment_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_item_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[internal_parent_trade_num] [int] NULL,
[internal_parent_order_num] [smallint] NULL,
[storage_identifier] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order] ON [dbo].[aud_trade_order] ([trade_num], [order_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_order_idx1] ON [dbo].[aud_trade_order] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_order] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_order] TO [next_usr]
GO

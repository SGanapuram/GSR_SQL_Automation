CREATE TABLE [dbo].[aud_accumulation]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[accum_start_date] [datetime] NOT NULL,
[accum_end_date] [datetime] NOT NULL,
[nominal_start_date] [datetime] NULL,
[nominal_end_date] [datetime] NULL,
[quote_start_date] [datetime] NULL,
[quote_end_date] [datetime] NULL,
[accum_qty] [float] NOT NULL,
[accum_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[total_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_pricing_run_date] [datetime] NULL,
[last_pricing_as_of_date] [datetime] NULL,
[accum_creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_precision] [tinyint] NULL,
[cmnt_num] [int] NULL,
[formula_num] [int] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[cost_num] [int] NULL,
[idms_trig_bb_ref_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exercised_by_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qpp_num] [smallint] NULL,
[trans_id] [bigint] NOT NULL,
[resp_trans_id] [bigint] NOT NULL,
[ai_est_actual_num] [int] NULL,
[flat_amt] [float] NULL,
[exec_inv_num] [int] NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
CREATE CLUSTERED INDEX [aud_accumulation] ON [dbo].[aud_accumulation] ([accum_num], [item_num], [order_num], [trade_num]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_accumulation_idx] ON [dbo].[aud_accumulation] ([trade_num], [order_num], [item_num], [accum_num], [trans_id], [resp_trans_id]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_accumulation_idx1] ON [dbo].[aud_accumulation] ([trans_id]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_accumulation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_accumulation] TO [next_usr]
GO

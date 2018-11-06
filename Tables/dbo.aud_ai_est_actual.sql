CREATE TABLE [dbo].[aud_ai_est_actual]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[ai_est_actual_date] [datetime] NOT NULL,
[ai_est_actual_gross_qty] [float] NULL,
[ai_gross_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_net_qty] [float] NULL,
[ai_net_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lease_num] [int] NULL,
[dest_trade_num] [int] NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scac_carrier_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transporter_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bol_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accum_num] [int] NULL,
[secondary_actual_gross_qty] [float] NULL,
[secondary_actual_net_qty] [float] NULL,
[secondary_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_input_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[fixed_swing_qty_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[insert_sequence] [int] NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tertiary_gross_qty] [numeric] (20, 8) NULL,
[tertiary_net_qty] [numeric] (20, 8) NULL,
[tertiary_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_tax_mt_qty] [numeric] (20, 8) NULL,
[actual_tax_m315_qty] [numeric] (20, 8) NULL,
[start_load_date] [datetime] NULL,
[stop_load_date] [datetime] NULL,
[sap_position_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_actual_idx1] ON [dbo].[aud_ai_est_actual] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ai_est_actual] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ai_est_actual] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ai_est_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ai_est_actual', NULL, NULL
GO

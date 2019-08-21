CREATE TABLE [dbo].[aud_exec_phys_inv]
(
[exec_inv_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[version_num] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_execution_oid] [int] NOT NULL,
[conc_del_item_oid] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[brand_id] [int] NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NOT NULL,
[pos_num] [int] NULL,
[inv_proj_qty] [float] NULL,
[inv_actual_qty] [float] NULL,
[inv_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_sec_proj_qty] [float] NULL,
[inv_sec_actual_qty] [float] NULL,
[inv_adj_qty] [float] NULL,
[inv_sec_adj_qty] [float] NULL,
[inv_unit_price] [float] NULL,
[inv_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[inv_matched_qty] [float] NULL,
[inv_matched_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exec_phys_inv] ON [dbo].[aud_exec_phys_inv] ([exec_inv_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exec_phys_inv_idx1] ON [dbo].[aud_exec_phys_inv] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_exec_phys_inv] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_exec_phys_inv] TO [next_usr]
GO

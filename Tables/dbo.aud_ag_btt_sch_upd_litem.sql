CREATE TABLE [dbo].[aud_ag_btt_sch_upd_litem]
(
[fdd_oid] [int] NOT NULL,
[fd_oid] [int] NOT NULL,
[line_item_num] [int] NOT NULL,
[parcel_num] [int] NULL,
[event_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[party_type] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[party_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[party_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[excise_lic_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ship_comp_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ship_reg] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imo_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inspector] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_port] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[destination] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[warehouse_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[receiving_terminal] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[terminal_add] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gn_taric_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tariff_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_status] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[excise_status] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty] [numeric] (20, 8) NOT NULL,
[uom_code] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_min] [numeric] (20, 8) NULL,
[qty_max] [numeric] (20, 8) NULL,
[schld_from_dt] [datetime] NULL,
[schld_to_dt] [datetime] NULL,
[loading_dt] [datetime] NULL,
[est_dt_of_arrival] [datetime] NULL,
[dt_of_transfer] [datetime] NULL,
[delivery_term] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[ext_char_col1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col3] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_int_col1] [int] NULL,
[ext_int_col2] [int] NULL,
[ext_int_col3] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_sch_upd_litem] ON [dbo].[aud_ag_btt_sch_upd_litem] ([fdd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_sch_upd_litem_idx1] ON [dbo].[aud_ag_btt_sch_upd_litem] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ag_btt_sch_upd_litem] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ag_btt_sch_upd_litem] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ag_btt_sch_upd_litem] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ag_btt_sch_upd_litem] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_btt_sch_upd_litem] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ag_btt_sch_upd_litem', NULL, NULL
GO

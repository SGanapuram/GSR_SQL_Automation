CREATE TABLE [dbo].[aud_ag_btt_ticket_litem]
(
[fdd_oid] [int] NOT NULL,
[fd_oid] [int] NOT NULL,
[line_item_num] [int] NOT NULL,
[parcel_num] [int] NULL,
[event_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[party_type] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[party_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[party_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ship_comp_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_port] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[destination] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[terminal_add] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty] [numeric] (20, 8) NOT NULL,
[uom_code] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_liters] [numeric] (20, 8) NULL,
[net_liters_15C] [numeric] (20, 8) NULL,
[nor] [datetime] NULL,
[hose_on] [datetime] NULL,
[hose_off] [datetime] NULL,
[bl_dt] [datetime] NULL,
[vessel_departed] [bit] NULL,
[schld_from_dt] [datetime] NULL,
[schld_to_dt] [datetime] NULL,
[loading_dt] [datetime] NULL,
[est_dt_of_arrival] [datetime] NULL,
[dt_of_transfer] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[ext_char_col1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col3] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col4] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col5] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_int_col1] [int] NULL,
[ext_int_col2] [int] NULL,
[ext_int_col3] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_ticket_litem] ON [dbo].[aud_ag_btt_ticket_litem] ([fdd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_ticket_litem_idx1] ON [dbo].[aud_ag_btt_ticket_litem] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ag_btt_ticket_litem] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ag_btt_ticket_litem] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ag_btt_ticket_litem] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ag_btt_ticket_litem] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_btt_ticket_litem] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ag_btt_ticket_litem', NULL, NULL
GO

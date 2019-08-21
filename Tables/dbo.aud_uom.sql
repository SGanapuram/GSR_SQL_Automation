CREATE TABLE [dbo].[aud_uom]
(
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[uom_convert_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conv_factor] [numeric] (20, 8) NULL,
[spec_code_adj1] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj1_mult_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_code_adj2] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj2_mult_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uom_idx1] ON [dbo].[aud_uom] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uom] ON [dbo].[aud_uom] ([uom_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_uom] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uom] TO [next_usr]
GO

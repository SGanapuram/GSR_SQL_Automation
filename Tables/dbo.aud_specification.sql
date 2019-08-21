CREATE TABLE [dbo].[aud_specification]
(
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sort_ordering_value] [smallint] NULL,
[spec_group_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[spec_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_val_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_ti_val_only] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_val_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_ratio_factor] [numeric] (28, 8) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_specification] ON [dbo].[aud_specification] ([spec_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_specification_idx1] ON [dbo].[aud_specification] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_specification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_specification] TO [next_usr]
GO

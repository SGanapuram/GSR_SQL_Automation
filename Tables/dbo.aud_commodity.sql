CREATE TABLE [dbo].[aud_commodity]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_tradeable_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_loc_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_curr_conv_rate] [float] NULL,
[prim_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_category_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[grade] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity] ON [dbo].[aud_commodity] ([cmdty_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_idx1] ON [dbo].[aud_commodity] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_commodity] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_commodity] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_commodity] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_commodity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_commodity', NULL, NULL
GO

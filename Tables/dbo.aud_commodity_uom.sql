CREATE TABLE [dbo].[aud_commodity_uom]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_uom_for] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_uom] ON [dbo].[aud_commodity_uom] ([cmdty_code], [cmdty_uom_for], [uom_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_uom_idx1] ON [dbo].[aud_commodity_uom] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commodity_uom] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_uom] TO [next_usr]
GO

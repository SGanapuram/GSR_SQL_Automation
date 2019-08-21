CREATE TABLE [dbo].[aud_uom_conversion]
(
[uom_conv_num] [int] NOT NULL,
[uom_code_conv_from] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_api_val] [float] NULL,
[uom_gravity_val] [float] NULL,
[uom_conv_rate] [float] NOT NULL,
[uom_conv_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uom_conversion_idx1] ON [dbo].[aud_uom_conversion] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uom_conversion] ON [dbo].[aud_uom_conversion] ([uom_conv_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_uom_conversion] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uom_conversion] TO [next_usr]
GO

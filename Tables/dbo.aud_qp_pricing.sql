CREATE TABLE [dbo].[aud_qp_pricing]
(
[oid] [int] NOT NULL,
[qp_option_oid] [int] NULL,
[pricing_option_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qp_pricing] ON [dbo].[aud_qp_pricing] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qp_pricing_idx1] ON [dbo].[aud_qp_pricing] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_qp_pricing] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_qp_pricing] TO [next_usr]
GO

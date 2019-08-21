CREATE TABLE [dbo].[aud_purchase_sale_group]
(
[oid] [int] NOT NULL,
[purchase_sale_group_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[booking_comp_num] [int] NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_group_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_purchase_sale_group] ON [dbo].[aud_purchase_sale_group] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_purchase_sale_group_idx1] ON [dbo].[aud_purchase_sale_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_purchase_sale_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_purchase_sale_group] TO [next_usr]
GO

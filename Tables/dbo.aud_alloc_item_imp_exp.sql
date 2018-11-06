CREATE TABLE [dbo].[aud_alloc_item_imp_exp]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[imp_exp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[license_num] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[consignee] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imp_exp_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_designation] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imp_exp_qty] [decimal] (20, 8) NULL,
[imp_exp_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price] [decimal] (20, 8) NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[freight_cost] [decimal] (20, 8) NULL,
[freight_cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_county] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[preparer_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[preparer_contact_info] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_alloc_item_imp_exp] ON [dbo].[aud_alloc_item_imp_exp] ([alloc_num], [alloc_item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_alloc_item_imp_exp_idx1] ON [dbo].[aud_alloc_item_imp_exp] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_alloc_item_imp_exp] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_alloc_item_imp_exp] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_alloc_item_imp_exp] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_alloc_item_imp_exp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_alloc_item_imp_exp] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_alloc_item_imp_exp', NULL, NULL
GO

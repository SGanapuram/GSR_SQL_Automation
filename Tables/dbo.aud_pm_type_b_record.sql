CREATE TABLE [dbo].[aud_pm_type_b_record]
(
[fdd_id] [int] NOT NULL,
[company_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[splc_code] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[terminal_ctrl_num] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bol_number] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exch_sale_party] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[auth_num] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[comp_prod_code] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fin_prod_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_qty] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_qty_temp_gravity] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[blnd_or_alt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[measurement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[temp_net_qty_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[unit_price] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[currency] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[billed_qty] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[billed_credit_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parcel_oid] [int] NULL,
[shipment_oid] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[type_a_record_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pm_type_b_record] ON [dbo].[aud_pm_type_b_record] ([fdd_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pm_type_b_record_idx1] ON [dbo].[aud_pm_type_b_record] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pm_type_b_record] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pm_type_b_record] TO [next_usr]
GO

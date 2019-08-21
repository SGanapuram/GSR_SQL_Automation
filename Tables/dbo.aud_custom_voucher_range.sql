CREATE TABLE [dbo].[aud_custom_voucher_range]
(
[oid] [int] NOT NULL,
[booking_comp_num] [int] NULL,
[initial_pay_receive_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[year] [smallint] NULL,
[ps_group_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prefix_string] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_num] [int] NOT NULL,
[max_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[vat_country_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reset_date] [datetime] NULL,
[reset_to_year] [smallint] NULL,
[reset_to_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_custom_voucher_range] ON [dbo].[aud_custom_voucher_range] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_custom_voucher_range_idx1] ON [dbo].[aud_custom_voucher_range] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_custom_voucher_range] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_custom_voucher_range] TO [next_usr]
GO

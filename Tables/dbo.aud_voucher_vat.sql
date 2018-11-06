CREATE TABLE [dbo].[aud_voucher_vat]
(
[voucher_num] [int] NOT NULL,
[tax_point] [datetime] NULL,
[belgian_inv_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[primary_invoice_ref_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_invoice_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[duty] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_invoice_amt] [numeric] (20, 6) NULL,
[equiv_invoice_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exch_rate] [numeric] (12, 6) NULL,
[exch_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exposition_of_vat_calc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_vat_idx1] ON [dbo].[aud_voucher_vat] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_vat] ON [dbo].[aud_voucher_vat] ([voucher_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voucher_vat] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voucher_vat] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voucher_vat] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voucher_vat] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_vat] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voucher_vat', NULL, NULL
GO

CREATE TABLE [dbo].[aud_voucher_cost]
(
[voucher_num] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[prov_price] [float] NULL,
[prov_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prov_qty] [float] NULL,
[prov_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prov_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[line_num] [int] NOT NULL,
[voucher_cost_status] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_cost_idx1] ON [dbo].[aud_voucher_cost] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_cost] ON [dbo].[aud_voucher_cost] ([voucher_num], [cost_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voucher_cost] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voucher_cost] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voucher_cost] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voucher_cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_cost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voucher_cost', NULL, NULL
GO

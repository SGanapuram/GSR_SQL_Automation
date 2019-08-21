CREATE TABLE [dbo].[voucher_cost]
(
[voucher_num] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[prov_price] [float] NULL,
[prov_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prov_qty] [float] NULL,
[prov_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prov_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[line_num] [int] NOT NULL,
[voucher_cost_status] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher_cost] ADD CONSTRAINT [voucher_cost_pk] PRIMARY KEY CLUSTERED  ([voucher_num], [cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [voucher_cost_idx1] ON [dbo].[voucher_cost] ([cost_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher_cost] ADD CONSTRAINT [voucher_cost_fk1] FOREIGN KEY ([prov_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher_cost] ADD CONSTRAINT [voucher_cost_fk3] FOREIGN KEY ([prov_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[voucher_cost] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher_cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher_cost] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher_cost] TO [next_usr]
GO

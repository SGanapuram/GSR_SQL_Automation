CREATE TABLE [dbo].[booked_inv_reconcil]
(
[oid] [int] NOT NULL,
[material_code] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_loc_code] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booked_qty] [numeric] (18, 3) NULL,
[booked_qty_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[physical_qty] [numeric] (18, 3) NULL,
[physical_qty_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[from_date] [datetime] NULL,
[to_date] [datetime] NULL,
[balance_type] [char] (22) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exchange_agreement_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[booked_inv_reconcil] ADD CONSTRAINT [booked_inv_reconcil_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[booked_inv_reconcil] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[booked_inv_reconcil] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[booked_inv_reconcil] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[booked_inv_reconcil] TO [next_usr]
GO

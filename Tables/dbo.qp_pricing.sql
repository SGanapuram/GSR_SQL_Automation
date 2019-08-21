CREATE TABLE [dbo].[qp_pricing]
(
[oid] [int] NOT NULL,
[qp_option_oid] [int] NULL,
[pricing_option_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qp_pricing] ADD CONSTRAINT [qp_pricing_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qp_pricing] ADD CONSTRAINT [qp_pricing_fk1] FOREIGN KEY ([qp_option_oid]) REFERENCES [dbo].[qp_option] ([oid])
GO
GRANT DELETE ON  [dbo].[qp_pricing] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qp_pricing] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qp_pricing] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qp_pricing] TO [next_usr]
GO

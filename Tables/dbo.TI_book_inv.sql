CREATE TABLE [dbo].[TI_book_inv]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material] [char] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[from_date] [datetime] NULL,
[end_date] [datetime] NULL,
[book_inventory] [numeric] (18, 3) NULL,
[book_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[physical_inventory] [numeric] (18, 3) NULL,
[physical_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_book_inv] ADD CONSTRAINT [TI_book_inv_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_book_inv] ADD CONSTRAINT [TI_book_inv_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_book_inv] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_book_inv] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_book_inv] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_book_inv] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_book_inv', NULL, NULL
GO

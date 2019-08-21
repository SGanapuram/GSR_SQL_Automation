CREATE TABLE [dbo].[balmo_product]
(
[primary_product_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[day_of_month] [int] NULL,
[product_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[update_date] [datetime] NULL,
[exchange_source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[balmo_product] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[balmo_product] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[balmo_product] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[balmo_product] TO [next_usr]
GO

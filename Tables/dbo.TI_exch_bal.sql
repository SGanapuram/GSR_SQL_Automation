CREATE TABLE [dbo].[TI_exch_bal]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[month_year] [datetime] NULL,
[exchange_agreement_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[material] [char] (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[system_calc_bal] [numeric] (18, 3) NULL,
[manual_opening_bal] [numeric] (18, 3) NULL,
[calc_closing_bal] [numeric] (18, 3) NULL,
[uom] [char] (22) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_exch_bal] ADD CONSTRAINT [TI_exch_bal_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_exch_bal] ADD CONSTRAINT [TI_exch_bal_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_exch_bal] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_exch_bal] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_exch_bal] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_exch_bal] TO [next_usr]
GO

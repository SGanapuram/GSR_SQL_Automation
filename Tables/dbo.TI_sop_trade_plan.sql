CREATE TABLE [dbo].[TI_sop_trade_plan]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[plan_id] [int] NULL,
[plan_start_date] [datetime] NULL,
[plan_end_date] [datetime] NULL,
[distributive_area] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_date] [datetime] NULL,
[material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deal_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buy_sell] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quantity] [numeric] (18, 3) NULL,
[uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_sop_trade_plan] ADD CONSTRAINT [TI_sop_trade_plan_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_sop_trade_plan] ADD CONSTRAINT [TI_sop_trade_plan_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_sop_trade_plan] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_sop_trade_plan] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_sop_trade_plan] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_sop_trade_plan] TO [next_usr]
GO

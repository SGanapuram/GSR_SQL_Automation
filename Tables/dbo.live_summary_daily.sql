CREATE TABLE [dbo].[live_summary_daily]
(
[ticket_num] [int] NOT NULL,
[trade_date] [datetime] NOT NULL,
[ticket_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commodity] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buy_sell_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty] [float] NULL,
[uom_per] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_end] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[broker] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[expire] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settlement] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gtc] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[resolution_date] [datetime] NULL,
[tolerance] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[live_summary_daily] ADD CONSTRAINT [live_summary_daily_pk] PRIMARY KEY CLUSTERED  ([ticket_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[live_summary_daily] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[live_summary_daily] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[live_summary_daily] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[live_summary_daily] TO [next_usr]
GO

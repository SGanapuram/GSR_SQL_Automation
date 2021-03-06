CREATE TABLE [dbo].[live_detail_daily]
(
[ticket_num] [int] NOT NULL,
[detail_num] [smallint] NOT NULL,
[location] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[buy_sell_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty] [float] NULL,
[uom_per] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[option_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opt_premium] [float] NULL,
[start_end] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[receives] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pays] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[settlement] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fut_desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[strike] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[underlying] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[broker] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[expire] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[live_detail_daily] ADD CONSTRAINT [live_detail_daily_pk] PRIMARY KEY CLUSTERED  ([ticket_num], [detail_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[live_detail_daily] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[live_detail_daily] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[live_detail_daily] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[live_detail_daily] TO [next_usr]
GO

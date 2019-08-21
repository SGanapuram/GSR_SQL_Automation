CREATE TABLE [dbo].[historical_volatility]
(
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vol_compute_date] [datetime] NOT NULL,
[volatility] [float] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[historical_volatility_updtrg]
on [dbo].[historical_volatility]
for update
as

declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

GO
GRANT DELETE ON  [dbo].[historical_volatility] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[historical_volatility] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[historical_volatility] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[historical_volatility] TO [next_usr]
GO

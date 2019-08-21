CREATE TABLE [dbo].[correlation]
(
[commkt_keya] [int] NOT NULL,
[commkt_keyb] [int] NOT NULL,
[trading_prda] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prdb] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[corr_compute_date] [datetime] NOT NULL,
[correlation] [float] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[correlation_updtrg]
on [dbo].[correlation]
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
ALTER TABLE [dbo].[correlation] ADD CONSTRAINT [correlation_pk] PRIMARY KEY CLUSTERED  ([commkt_keya], [commkt_keyb], [trading_prda], [trading_prdb], [corr_compute_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[correlation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[correlation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[correlation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[correlation] TO [next_usr]
GO

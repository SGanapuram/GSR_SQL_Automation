CREATE TABLE [dbo].[aud_var_pnl_distribution]
(
[oid] [int] NOT NULL,
[var_run_id] [int] NOT NULL,
[bucket_type] [int] NOT NULL,
[bucket_tag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mean] [numeric] (20, 8) NULL,
[stdev] [numeric] (20, 8) NULL,
[max] [numeric] (20, 8) NULL,
[min] [numeric] (20, 8) NULL,
[skew] [numeric] (20, 8) NULL,
[kurtosis] [numeric] (20, 8) NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_var_pnl_distribution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_var_pnl_distribution] TO [next_usr]
GO

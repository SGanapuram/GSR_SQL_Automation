CREATE TABLE [dbo].[ets_run_archive]
(
[et_trans_id] [numeric] (32, 0) NOT NULL,
[external_trade_oid] [int] NOT NULL,
[instance_num] [smallint] NULL,
[start_time] [datetime] NULL,
[end_time] [datetime] NULL,
[archived_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ets_run_archive_idx1] ON [dbo].[ets_run_archive] ([archived_date]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ets_run_archive] TO [next_usr]
GO

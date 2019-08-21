CREATE TABLE [dbo].[ets_run]
(
[et_trans_id] [numeric] (32, 0) NOT NULL,
[external_trade_oid] [int] NOT NULL,
[instance_num] [smallint] NULL,
[start_time] [datetime] NULL,
[end_time] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ets_run] ADD CONSTRAINT [ets_run_pk] PRIMARY KEY CLUSTERED  ([et_trans_id], [external_trade_oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ets_run_idx1] ON [dbo].[ets_run] ([external_trade_oid], [instance_num], [start_time]) INCLUDE ([end_time]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ets_run] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ets_run] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ets_run] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ets_run] TO [next_usr]
GO

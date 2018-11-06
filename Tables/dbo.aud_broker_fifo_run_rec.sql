CREATE TABLE [dbo].[aud_broker_fifo_run_rec]
(
[broker_num] [int] NOT NULL,
[world_port_num] [int] NOT NULL,
[futures_last_fifo_date] [datetime] NULL,
[options_last_fifo_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_fifo_run_rec] ON [dbo].[aud_broker_fifo_run_rec] ([broker_num], [world_port_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_broker_fifo_run_rec] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_broker_fifo_run_rec] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_broker_fifo_run_rec] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_broker_fifo_run_rec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_broker_fifo_run_rec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_broker_fifo_run_rec', NULL, NULL
GO

CREATE TABLE [dbo].[aud_broker_info]
(
[acct_num] [int] NOT NULL,
[dflt_comm_amt] [float] NULL,
[dflt_comm_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_comm_uom_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_info_idx1] ON [dbo].[aud_broker_info] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_broker_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_broker_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_broker_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_broker_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_broker_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_broker_info', NULL, NULL
GO

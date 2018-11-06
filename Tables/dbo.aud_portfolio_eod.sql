CREATE TABLE [dbo].[aud_portfolio_eod]
(
[port_num] [int] NOT NULL,
[port_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[desired_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[snapshot_asof_date] [datetime] NOT NULL,
[port_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_short_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_full_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_class] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_ref_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[num_history_days] [int] NULL,
[trading_entity_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_eod] ON [dbo].[aud_portfolio_eod] ([port_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_eod_idx1] ON [dbo].[aud_portfolio_eod] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_portfolio_eod] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_eod] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_portfolio_eod] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_eod] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_eod] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_portfolio_eod', NULL, NULL
GO

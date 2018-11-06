CREATE TABLE [dbo].[portfolio_eod]
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
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio_eod] ADD CONSTRAINT [portfolio_eod_pk] PRIMARY KEY CLUSTERED  ([port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_eod_idx3] ON [dbo].[portfolio_eod] ([port_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_eod_idx1] ON [dbo].[portfolio_eod] ([port_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_eod_idx2] ON [dbo].[portfolio_eod] ([snapshot_asof_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio_eod] ADD CONSTRAINT [portfolio_eod_fk1] FOREIGN KEY ([trading_entity_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[portfolio_eod] ADD CONSTRAINT [portfolio_eod_fk3] FOREIGN KEY ([desired_pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[portfolio_eod] ADD CONSTRAINT [portfolio_eod_fk4] FOREIGN KEY ([owner_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[portfolio_eod] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_eod] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_eod] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_eod] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_eod', NULL, NULL
GO

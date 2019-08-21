CREATE TABLE [dbo].[aud_portfolio_pos_limit]
(
[port_num] [int] NOT NULL,
[pos_limit_id] [int] NOT NULL,
[long_limit_qty] [decimal] (20, 8) NULL,
[short_limit_qty] [decimal] (20, 8) NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tolerance_pct] [decimal] (18, 3) NULL,
[pos_qty] [decimal] (20, 8) NULL,
[pos_asof_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_pos_limit] ON [dbo].[aud_portfolio_pos_limit] ([port_num], [pos_limit_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_pos_limit_idx1] ON [dbo].[aud_portfolio_pos_limit] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_pos_limit] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_pos_limit] TO [next_usr]
GO

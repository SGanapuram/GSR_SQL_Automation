CREATE TABLE [dbo].[aud_portfolio_jv]
(
[port_num] [int] NOT NULL,
[due_date] [datetime] NOT NULL,
[acct_num] [int] NOT NULL,
[book_comp_num] [int] NOT NULL,
[pl_percentage] [float] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_jv] ON [dbo].[aud_portfolio_jv] ([port_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_jv_idx1] ON [dbo].[aud_portfolio_jv] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_jv] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_jv] TO [next_usr]
GO

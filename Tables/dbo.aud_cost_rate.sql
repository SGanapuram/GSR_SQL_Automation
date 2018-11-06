CREATE TABLE [dbo].[aud_cost_rate]
(
[oid] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[rate] [decimal] (20, 8) NOT NULL,
[rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[effective_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[formula_num] [int] NULL,
[formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[factor] [decimal] (20, 8) NULL,
[is_fully_priced] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_cost_num] [int] NULL,
[librarary_formula_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_rate] ON [dbo].[aud_cost_rate] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_rate_idx1] ON [dbo].[aud_cost_rate] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_rate] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_rate] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_rate] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_rate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_rate', NULL, NULL
GO

CREATE TABLE [dbo].[aud_rc_flat_benchmark]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[flat_amt] [float] NULL,
[flat_percentage] [float] NULL,
[app_to_flat] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[benchmark_detail_oid] [int] NULL,
[benchmark_value] [float] NULL,
[benchmark_percentage] [float] NULL,
[app_to_benchmark] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rc_value] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[from_value] [float] NULL,
[to_value] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_flat_benchmark] ON [dbo].[aud_rc_flat_benchmark] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_flat_benchmark_idx1] ON [dbo].[aud_rc_flat_benchmark] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_rc_flat_benchmark] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_rc_flat_benchmark] TO [next_usr]
GO

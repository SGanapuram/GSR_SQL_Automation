CREATE TABLE [dbo].[aud_benchmark_detail]
(
[oid] [int] NOT NULL,
[benchmark_oid] [int] NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_year] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tc_amt] [float] NULL,
[tc_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rc_amt] [float] NULL,
[rc_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[tc_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rc_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_benchmark_detail] ON [dbo].[aud_benchmark_detail] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_benchmark_detail_idx1] ON [dbo].[aud_benchmark_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_benchmark_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_benchmark_detail] TO [next_usr]
GO

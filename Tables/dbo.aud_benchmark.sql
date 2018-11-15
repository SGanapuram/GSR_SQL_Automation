CREATE TABLE [dbo].[aud_benchmark]
(
[oid] [int] NOT NULL,
[bm_short_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bm_full_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_benchmark] ON [dbo].[aud_benchmark] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_benchmark_idx1] ON [dbo].[aud_benchmark] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_benchmark] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_benchmark] TO [next_usr]
GO

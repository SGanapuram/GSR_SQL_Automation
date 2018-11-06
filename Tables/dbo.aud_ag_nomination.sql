CREATE TABLE [dbo].[aud_ag_nomination]
(
[fd_oid] [int] NOT NULL,
[transaction_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[batch_number] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_datetime] [datetime] NOT NULL,
[pipeline_cycle] [int] NULL,
[pipeline_cycle_year] [int] NULL,
[pipeline_sequence] [int] NULL,
[pipeline_scd] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[last_update_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[doc_id] [int] NOT NULL,
[shipper_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_place] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_nomination] ON [dbo].[aud_ag_nomination] ([fd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_nomination_idx1] ON [dbo].[aud_ag_nomination] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ag_nomination] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ag_nomination] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ag_nomination] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ag_nomination] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_nomination] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ag_nomination', NULL, NULL
GO

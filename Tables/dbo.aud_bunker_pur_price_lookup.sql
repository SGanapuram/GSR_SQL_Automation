CREATE TABLE [dbo].[aud_bunker_pur_price_lookup]
(
[oid] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_date_from] [datetime] NOT NULL,
[del_date_to] [datetime] NOT NULL,
[storage_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_amt] [float] NULL,
[price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bunker_pur_price_lookup] ON [dbo].[aud_bunker_pur_price_lookup] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_bunker_pur_pr_lookup_idx1] ON [dbo].[aud_bunker_pur_price_lookup] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_bunker_pur_price_lookup] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_bunker_pur_price_lookup] TO [next_usr]
GO

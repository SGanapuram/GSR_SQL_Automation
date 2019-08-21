CREATE TABLE [dbo].[aud_scenario]
(
[oid] [int] NOT NULL,
[scenario_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[scenario_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[storage_acct_num] [int] NULL,
[title_del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_scenario] ON [dbo].[aud_scenario] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_scenario_idx1] ON [dbo].[aud_scenario] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_scenario] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_scenario] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_facility]
(
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[facility_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[facility_short_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_long_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[stock_location_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[facility_owner_acct_num] [int] NULL,
[facility_owner_addr_num] [smallint] NULL,
[facility_owner_cont_num] [int] NULL,
[facility_oper_instr_num] [smallint] NULL,
[tax_jurisdiction_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[capacity] [decimal] (20, 8) NULL,
[capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility] ON [dbo].[aud_facility] ([facility_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_idx1] ON [dbo].[aud_facility] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_facility] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_facility] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_facility] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_facility] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_facility] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_facility', NULL, NULL
GO

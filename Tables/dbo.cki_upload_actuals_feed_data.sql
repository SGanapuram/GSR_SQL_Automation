CREATE TABLE [dbo].[cki_upload_actuals_feed_data]
(
[guid] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[record_id] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[actual_date] [datetime] NOT NULL,
[creation_date] [datetime] NOT NULL,
[cp_short_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[internal_del_parcel_id] [int] NULL,
[internal_rpt_parcel_id] [int] NULL,
[external_del_parcel_id] [int] NULL,
[external_rpt_parcel_id] [int] NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[error] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[record_type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cki_upload_actuals_feed_data] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cki_upload_actuals_feed_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cki_upload_actuals_feed_data] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cki_upload_actuals_feed_data] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cki_upload_actuals_feed_data', NULL, NULL
GO

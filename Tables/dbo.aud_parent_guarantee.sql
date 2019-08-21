CREATE TABLE [dbo].[aud_parent_guarantee]
(
[pg_num] [int] NOT NULL,
[pg_in_out_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pg_guarantor] [int] NOT NULL,
[pg_counter_ref_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_beneficiary] [int] NOT NULL,
[pg_bus_covered_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pg_subs_covered_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pg_amount_covered] [float] NOT NULL,
[pg_amt_covered_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_volume_limit] [float] NULL,
[pg_volume_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_trade_num] [int] NULL,
[pg_notify_user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_notify_days] [datetime] NOT NULL,
[pg_issue_date] [datetime] NOT NULL,
[pg_expiration_date] [datetime] NOT NULL,
[pg_office_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pg_cr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parent_guarantee] ON [dbo].[aud_parent_guarantee] ([pg_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parent_guarantee_idx1] ON [dbo].[aud_parent_guarantee] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_parent_guarantee] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parent_guarantee] TO [next_usr]
GO

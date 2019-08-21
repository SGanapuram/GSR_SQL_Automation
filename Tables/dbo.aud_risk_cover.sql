CREATE TABLE [dbo].[aud_risk_cover]
(
[risk_cover_num] [int] NOT NULL,
[instr_type_code] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rc_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[guarantee_acct_num] [int] NULL,
[covered_percent] [decimal] (20, 8) NULL,
[max_covered_amt] [decimal] (20, 8) NULL,
[guarantee_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[guarantee_start_date] [datetime] NULL,
[guarantee_end_date] [datetime] NULL,
[min_num_of_days] [int] NULL,
[analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[office_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[disc_date] [datetime] NULL,
[disc_rec_amt] [decimal] (20, 8) NULL,
[disc_rec_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_risk_cover] ON [dbo].[aud_risk_cover] ([risk_cover_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_risk_cover_idx1] ON [dbo].[aud_risk_cover] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_risk_cover] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_risk_cover] TO [next_usr]
GO

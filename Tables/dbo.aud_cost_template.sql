CREATE TABLE [dbo].[aud_cost_template]
(
[oid] [int] NOT NULL,
[template_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[template_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[segment_oid] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_num] [int] NULL,
[trade_item_p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_template] ON [dbo].[aud_cost_template] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_template_idx1] ON [dbo].[aud_cost_template] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_template] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_template] TO [next_usr]
GO

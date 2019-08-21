CREATE TABLE [dbo].[aud_commkt_source_roll_date]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[roll_date_rule_num] [tinyint] NOT NULL,
[roll_date_days] [tinyint] NULL,
[roll_date_bus_cal_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[roll_date_on_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[roll_date_event] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_source_roll_date] ON [dbo].[aud_commkt_source_roll_date] ([commkt_key], [price_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_source_roll_d_idx1] ON [dbo].[aud_commkt_source_roll_date] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commkt_source_roll_date] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commkt_source_roll_date] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_fb_event_price_term]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_pricing_prds] [smallint] NULL,
[event_pricing_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_start_prds] [smallint] NULL,
[event_start_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deemed_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[deemed_event_date] [datetime] NULL,
[event_date_saturdays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_sundays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_holidays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj_pricing_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[add_trigger_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_start_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trig_start_prds] [int] NULL,
[trig_start_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trig_event_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trig_event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj_trig_start_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field1] [int] NULL,
[field2] [float] NULL,
[field3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field4] [datetime] NULL,
[adj_days] [smallint] NULL,
[adj_pricing_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_fb_event_price_term_idx] ON [dbo].[aud_fb_event_price_term] ([formula_num], [formula_body_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fb_event_price_term_idx1] ON [dbo].[aud_fb_event_price_term] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fb_event_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fb_event_price_term] TO [next_usr]
GO

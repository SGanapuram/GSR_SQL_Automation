CREATE TABLE [dbo].[aud_event_price_term]
(
[formula_num] [int] NOT NULL,
[price_term_num] [smallint] NOT NULL,
[event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_pricing_days] [smallint] NULL,
[event_start_end_days] [smallint] NULL,
[quote_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_include_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_dflt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[event_trig_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_price_term_num] [smallint] NULL,
[deemed_event_date] [datetime] NULL,
[event_date_saturdays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_sundays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_date_holidays] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj_pricing_date_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[date_deemed] [datetime] NULL,
[adj_days] [smallint] NULL,
[adj_pricing_prd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_event_price_term] ON [dbo].[aud_event_price_term] ([formula_num], [price_term_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_event_price_term_idx1] ON [dbo].[aud_event_price_term] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_event_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_event_price_term] TO [next_usr]
GO

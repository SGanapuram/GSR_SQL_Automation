CREATE TABLE [dbo].[aud_quote_price_term]
(
[qpt_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qpt_term_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dept_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_pricing_days] [smallint] NULL,
[qpt_price_cal_days_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_start_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_relative_days] [smallint] NULL,
[qpt_rel_price_cal_days_ind] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_roll_accum_prd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_price_term] ON [dbo].[aud_quote_price_term] ([qpt_term_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_price_term_idx1] ON [dbo].[aud_quote_price_term] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_quote_price_term] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_quote_price_term] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_quote_price_term] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_quote_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quote_price_term] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_quote_price_term', NULL, NULL
GO

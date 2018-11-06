CREATE TABLE [dbo].[aud_grade_commodity_market]
(
[commkt_key] [int] NOT NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_grade_commodity_market] ON [dbo].[aud_grade_commodity_market] ([commkt_key], [curr_code], [uom_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_grade_cmdty_market_idx1] ON [dbo].[aud_grade_commodity_market] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_grade_commodity_market] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_grade_commodity_market] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_grade_commodity_market] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_grade_commodity_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_grade_commodity_market] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_grade_commodity_market', NULL, NULL
GO

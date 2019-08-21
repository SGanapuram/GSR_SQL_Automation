CREATE TABLE [dbo].[aud_pm_trade_match_criteria]
(
[oid] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp] [int] NULL,
[carrier_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pm_trade_match_criteria] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pm_trade_match_criteria] TO [next_usr]
GO

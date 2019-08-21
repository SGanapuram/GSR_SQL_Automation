CREATE TABLE [dbo].[aud_exposure_detail]
(
[cost_num] [int] NOT NULL,
[exposure_num] [int] NOT NULL,
[cash_exp_amt] [float] NULL,
[mtm_pl] [float] NULL,
[mtm_from_date] [datetime] NULL,
[mtm_end_date] [datetime] NULL,
[cash_from_date] [datetime] NULL,
[cash_to_date] [datetime] NULL,
[shift_exposure_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[credit_exposure_oid] [int] NULL,
[cost_amt] [numeric] (20, 8) NULL,
[cost_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exposure_detail] ON [dbo].[aud_exposure_detail] ([cost_num], [exposure_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exposure_detail_idx1] ON [dbo].[aud_exposure_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_exposure_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_exposure_detail] TO [next_usr]
GO

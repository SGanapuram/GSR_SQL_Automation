CREATE TABLE [dbo].[aud_cost_credit_exposure]
(
[oid] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[booking_comp_num] [int] NOT NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exposure_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[asset_cost_amount] [numeric] (20, 8) NOT NULL,
[lib_cost_amount] [numeric] (20, 8) NOT NULL,
[lc_ils_amount] [numeric] (20, 8) NOT NULL,
[lc_ild_amount] [numeric] (20, 8) NOT NULL,
[lc_ilb_amount] [numeric] (20, 8) NOT NULL,
[lc_ilo_amount] [numeric] (20, 8) NOT NULL,
[lc_els_amount] [numeric] (20, 8) NOT NULL,
[lc_eld_amount] [numeric] (20, 8) NOT NULL,
[lc_elb_amount] [numeric] (20, 8) NOT NULL,
[lc_elo_amount] [numeric] (20, 8) NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_credit_exposure] ON [dbo].[aud_cost_credit_exposure] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_credit_exposure_idx1] ON [dbo].[aud_cost_credit_exposure] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_credit_exposure] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_credit_exposure] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_credit_exposure] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_credit_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_credit_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_credit_exposure', NULL, NULL
GO

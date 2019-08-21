CREATE TABLE [dbo].[aud_fx_exposure_currency]
(
[oid] [int] NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure_currency] ON [dbo].[aud_fx_exposure_currency] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure_currency_idx1] ON [dbo].[aud_fx_exposure_currency] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fx_exposure_currency] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_exposure_currency] TO [next_usr]
GO

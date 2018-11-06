CREATE TABLE [dbo].[aud_fx_exposure]
(
[oid] [int] NOT NULL,
[fx_exp_curr_oid] [int] NOT NULL,
[fx_trading_prd] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fx_exposure_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NULL,
[open_rate_amt] [numeric] (20, 8) NULL,
[fixed_rate_amt] [numeric] (20, 8) NULL,
[linked_rate_amt] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[fx_exp_sub_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure] ON [dbo].[aud_fx_exposure] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure_idx1] ON [dbo].[aud_fx_exposure] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_fx_exposure] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_fx_exposure] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_fx_exposure] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_fx_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_fx_exposure', NULL, NULL
GO

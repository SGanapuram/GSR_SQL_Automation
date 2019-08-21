CREATE TABLE [dbo].[aud_credit_reserve]
(
[oid] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reserved_amt] [numeric] (20, 8) NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[value_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_reserve] ON [dbo].[aud_credit_reserve] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_reserve_idx1] ON [dbo].[aud_credit_reserve] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_credit_reserve] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_reserve] TO [next_usr]
GO

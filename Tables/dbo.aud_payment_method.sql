CREATE TABLE [dbo].[aud_payment_method]
(
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_method_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[accounting_pay_method] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_payment_method] ON [dbo].[aud_payment_method] ([pay_method_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_payment_method_idx1] ON [dbo].[aud_payment_method] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_payment_method] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_payment_method] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_trade_item_ext_info]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[custom_field1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field7] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field8] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_ext_info] ON [dbo].[aud_trade_item_ext_info] ([trade_num], [order_num], [item_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_trade_item_ext_info_idx1] ON [dbo].[aud_trade_item_ext_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_trade_item_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_trade_item_ext_info] TO [next_usr]
GO

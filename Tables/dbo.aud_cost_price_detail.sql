CREATE TABLE [dbo].[aud_cost_price_detail]
(
[cost_num] [int] NOT NULL,
[formula_body_num] [int] NOT NULL,
[formula_num] [int] NOT NULL,
[unit_price] [float] NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field1] [int] NULL,
[fb_value] [float] NULL,
[field3] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field4] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[qty_uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_uom_conv_rate] [numeric] (20, 8) NULL,
[price_pcnt_val] [float] NULL,
[price_pcnt_string] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_quote_string] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flat_amt] [float] NULL,
[prorated_flat_amt] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_price_detail_idx1] ON [dbo].[aud_cost_price_detail] ([cost_num], [formula_body_num], [formula_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_price_detail_idx2] ON [dbo].[aud_cost_price_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_price_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_price_detail] TO [next_usr]
GO

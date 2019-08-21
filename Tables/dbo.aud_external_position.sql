CREATE TABLE [dbo].[aud_external_position]
(
[ext_pos_num] [int] NOT NULL,
[clr_brkr_num] [int] NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strike_price] [decimal] (20, 8) NULL,
[quantity] [decimal] (20, 8) NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_position] ON [dbo].[aud_external_position] ([ext_pos_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_position_idx1] ON [dbo].[aud_external_position] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_external_position] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_position] TO [next_usr]
GO

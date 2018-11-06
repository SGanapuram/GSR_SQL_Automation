CREATE TABLE [dbo].[aud_pl_offset_transfer]
(
[oid] [int] NOT NULL,
[owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_key1] [int] NULL,
[owner_key2] [int] NULL,
[owner_key3] [int] NULL,
[port_num] [int] NULL,
[base_port_num] [int] NULL,
[transfer_qty] [numeric] (20, 8) NULL,
[transfer_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_amt] [numeric] (20, 8) NULL,
[transfer_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[source_owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[source_owner_key1] [int] NULL,
[source_owner_key2] [int] NULL,
[source_owner_key3] [int] NULL,
[source_price] [float] NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pl_offset_transfer] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pl_offset_transfer] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_pl_offset_transfer', NULL, NULL
GO

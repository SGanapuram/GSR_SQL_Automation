CREATE TABLE [dbo].[aud_var_ext_position]
(
[rowid] [int] NOT NULL,
[as_of_date] [datetime] NOT NULL,
[real_port_num] [int] NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[position] [float] NOT NULL,
[position_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[what_if_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_key] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_var_ext_position] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_var_ext_position] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_var_ext_position] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_var_ext_position] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_var_ext_position] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_var_ext_position', NULL, NULL
GO

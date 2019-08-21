CREATE TABLE [dbo].[aud_commkt_src_alias_info]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calc_avg_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_load_start] [int] NULL,
[price_load_freq] [int] NULL,
[price_load_duration] [int] NULL,
[commkt_generate_spot_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_coded_as_spot_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_src_alias_info] ON [dbo].[aud_commkt_src_alias_info] ([commkt_key], [price_source_code], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_src_alias_inf_idx1] ON [dbo].[aud_commkt_src_alias_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commkt_src_alias_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commkt_src_alias_info] TO [next_usr]
GO

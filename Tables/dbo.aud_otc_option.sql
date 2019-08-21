CREATE TABLE [dbo].[aud_otc_option]
(
[otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[otc_opt_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[otc_opt_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[otc_opt_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_otc_option] ON [dbo].[aud_otc_option] ([otc_opt_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_otc_option_idx1] ON [dbo].[aud_otc_option] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_otc_option] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_otc_option] TO [next_usr]
GO

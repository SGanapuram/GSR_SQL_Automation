CREATE TABLE [dbo].[aud_fx_linking]
(
[oid] [int] NOT NULL,
[fx_link_rate] [numeric] (20, 8) NULL,
[fx_rate_m_d_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[need_rate_computation] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_linking] ON [dbo].[aud_fx_linking] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_linking_idx1] ON [dbo].[aud_fx_linking] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fx_linking] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_linking] TO [next_usr]
GO

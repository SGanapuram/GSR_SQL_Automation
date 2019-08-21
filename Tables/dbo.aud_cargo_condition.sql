CREATE TABLE [dbo].[aud_cargo_condition]
(
[cargo_cond_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cargo_cond_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cargo_cond_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[active_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cargo_condition] ON [dbo].[aud_cargo_condition] ([cargo_cond_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cargo_condition_idx1] ON [dbo].[aud_cargo_condition] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cargo_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cargo_condition] TO [next_usr]
GO

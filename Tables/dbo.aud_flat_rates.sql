CREATE TABLE [dbo].[aud_flat_rates]
(
[flat_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[from_date] [datetime] NOT NULL,
[to_date] [datetime] NOT NULL,
[flat_value] [float] NULL,
[flat_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flat_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_flat_rates] ON [dbo].[aud_flat_rates] ([flat_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_flat_rates] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_flat_rates] TO [next_usr]
GO

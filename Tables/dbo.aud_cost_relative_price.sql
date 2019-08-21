CREATE TABLE [dbo].[aud_cost_relative_price]
(
[cost_num] [int] NOT NULL,
[seq_num] [smallint] NOT NULL,
[relative_cost_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[percent_rate_value] [float] NOT NULL,
[reference] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_relative_price] ON [dbo].[aud_cost_relative_price] ([cost_num], [seq_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_relative_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_relative_price] TO [next_usr]
GO

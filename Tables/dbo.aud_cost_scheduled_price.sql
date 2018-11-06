CREATE TABLE [dbo].[aud_cost_scheduled_price]
(
[cost_num] [int] NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[volume_scale] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[volume_usg_from] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mini_usg_test_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mini_usg] [float] NULL,
[mini_usg_fee] [float] NULL,
[mini_use_incl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reference] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_scheduled_price] ON [dbo].[aud_cost_scheduled_price] ([cost_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_scheduled_price] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_scheduled_price] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_scheduled_price] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_scheduled_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_scheduled_price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_scheduled_price', NULL, NULL
GO

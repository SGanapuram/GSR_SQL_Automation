CREATE TABLE [dbo].[aud_cost_center]
(
[cost_center_code] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_center_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[company_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_send_id] [smallint] NULL,
[cost_center_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[profit_center] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[order_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_center_idx1] ON [dbo].[aud_cost_center] ([cost_center_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_center_idx2] ON [dbo].[aud_cost_center] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_center] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_center] TO [next_usr]
GO

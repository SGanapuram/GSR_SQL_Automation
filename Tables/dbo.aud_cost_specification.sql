CREATE TABLE [dbo].[aud_cost_specification]
(
[cost_num] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_val] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_specification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_specification] TO [next_usr]
GO

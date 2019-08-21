CREATE TABLE [dbo].[aud_broker_cost_step_price]
(
[cost_autogen_num] [int] NOT NULL,
[step_price_num] [int] NOT NULL,
[unit_price] [numeric] (20, 8) NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_upto] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_cost_step_price] ON [dbo].[aud_broker_cost_step_price] ([cost_autogen_num], [step_price_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_broker_cost_step_pr_idx1] ON [dbo].[aud_broker_cost_step_price] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_broker_cost_step_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_broker_cost_step_price] TO [next_usr]
GO

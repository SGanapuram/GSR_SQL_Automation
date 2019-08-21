CREATE TABLE [dbo].[aud_cost_equalization_rate]
(
[cost_num] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[effective_date] [datetime] NOT NULL,
[min_spec_value] [decimal] (20, 8) NOT NULL,
[max_spec_value] [decimal] (20, 8) NOT NULL,
[rate_for_low_end] [decimal] (20, 8) NOT NULL,
[rate_for_high_end] [decimal] (20, 8) NOT NULL,
[cost_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calc_factor] [decimal] (8, 3) NULL,
[calc_factor_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_equalization_rate] ON [dbo].[aud_cost_equalization_rate] ([cost_num], [spec_code], [effective_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_equalization_rate_idx1] ON [dbo].[aud_cost_equalization_rate] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_equalization_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_equalization_rate] TO [next_usr]
GO

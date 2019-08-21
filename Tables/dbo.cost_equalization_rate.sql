CREATE TABLE [dbo].[cost_equalization_rate]
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
[calc_factor_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_cost_equalization_rate_calc_factor_oper] DEFAULT ('M'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_equalization_rate] ADD CONSTRAINT [chk_cost_equalization_rate_calc_factor_oper] CHECK (([calc_factor_oper]='D' OR [calc_factor_oper]='M'))
GO
ALTER TABLE [dbo].[cost_equalization_rate] ADD CONSTRAINT [cost_equalization_rate_pk] PRIMARY KEY CLUSTERED  ([cost_num], [spec_code], [effective_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cost_equalization_rate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_equalization_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_equalization_rate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_equalization_rate] TO [next_usr]
GO

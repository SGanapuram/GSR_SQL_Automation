CREATE TABLE [dbo].[uic_rpt_criteria_values]
(
[report_mod_id] [int] NOT NULL,
[report_criteria_id] [int] NOT NULL,
[criteria_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[uic_rpt_criteria_values] ADD CONSTRAINT [uic_rpt_criteria_values_pk] PRIMARY KEY CLUSTERED  ([report_mod_id], [report_criteria_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uic_rpt_criteria_values_idx1] ON [dbo].[uic_rpt_criteria_values] ([criteria_value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[uic_rpt_criteria_values] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[uic_rpt_criteria_values] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[uic_rpt_criteria_values] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[uic_rpt_criteria_values] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'uic_rpt_criteria_values', NULL, NULL
GO

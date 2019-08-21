SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pipeline_year_cycle]
(
   year_num,
   pipeline_cycle_num,
   mot_code,
   trans_id
)
as
select 
   gdv.int_value, 
   pc.pipeline_cycle_num, 
   pc.mot_code, 
   pc.trans_id
from dbo.generic_data_values gdv, 
     dbo.generic_data_definition gdd, 
     dbo.generic_data_name gdn, 
     dbo.pipeline_cycle pc
where gdn.data_name = 'pipeline cycle year' and
      gdd.gdn_num = gdn.gdn_num and
      gdv.gdd_num = gdd.gdd_num and 
      gdv.int_value = DATEPART(year, pc.cycle_start_date)
GO
GRANT SELECT ON  [dbo].[v_pipeline_year_cycle] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_pipeline_year_cycle] TO [next_usr]
GO

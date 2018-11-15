SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_contract_execution_rev]                              
(                                                        
   oid,
   exec_purch_sale_ind,
   parent_exec_id,
   pcnt_factor,
   exec_status,
   real_port_num,
   custom_exec_num,	
   conc_contract_oid,
   prorated_flat_amt,
   flat_amt_curr_code,	
   trans_id,
   asof_trans_id,
   resp_trans_id
)                                                        
as                                                       
select                                                   
   oid,
   exec_purch_sale_ind,
   parent_exec_id,
   pcnt_factor,
   exec_status,
   real_port_num,
   custom_exec_num,	
   conc_contract_oid,
   prorated_flat_amt,
   flat_amt_curr_code,	
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_contract_execution                                 
GO
GRANT SELECT ON  [dbo].[v_contract_execution_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_contract_execution_rev] TO [next_usr]
GO

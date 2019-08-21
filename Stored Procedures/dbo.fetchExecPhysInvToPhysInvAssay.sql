SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchExecPhysInvToPhysInvAssay]                                      
(
   @asof_trans_id      bigint,
   @exec_inv_num       int
)
as
set nocount on
declare @trans_id   bigint
   select asof_trans_id = @asof_trans_id,
          assay_date,
          assay_group_num,
          exec_inv_num,
          owner_assay,
          owner_assay_oid,
          resp_trans_id = NULL,
          spec_actual_value,
          spec_actual_value_text,
          spec_code,
          spec_opt_val,
          spec_provisiional_opt_val,
          spec_provisional_text,
          spec_provisional_val,
          trans_id,
          use_in_cost_ind,
          use_in_formula_ind,
          use_in_pl_ind
   from dbo.phys_inv_assay
   where exec_inv_num = @exec_inv_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          assay_date,
          assay_group_num,
          exec_inv_num,
          owner_assay,
          owner_assay_oid,
          resp_trans_id,
          spec_actual_value,
          spec_actual_value_text,
          spec_code,
          spec_opt_val,
          spec_provisiional_opt_val,
          spec_provisional_text,
          spec_provisional_val,
          trans_id,
          use_in_cost_ind,
          use_in_formula_ind,
          use_in_pl_ind
   from dbo.aud_phys_inv_assay
   where exec_inv_num = @exec_inv_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchExecPhysInvToPhysInvAssay] TO [next_usr]
GO

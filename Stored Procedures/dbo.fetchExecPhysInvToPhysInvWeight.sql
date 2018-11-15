SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchExecPhysInvToPhysInvWeight]
(
   @asof_trans_id      int,
   @exec_inv_num       int
)
as
set nocount on
declare @trans_id   int
 
   select asof_trans_id = @asof_trans_id,
          exec_inv_num,
          loc_code,
          measure_date,
          prim_qty,
          prim_qty_uom_code,
          resp_trans_id = NULL,
          sec_qty,
          sec_qty_uom_code,
          short_comment,
          trans_id,
          use_in_pl_ind,
          weight_detail_num,
          weight_type
   from dbo.phys_inv_weight
   where exec_inv_num = @exec_inv_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          exec_inv_num,
          loc_code,
          measure_date,
          prim_qty,
          prim_qty_uom_code,
          resp_trans_id,
          sec_qty,
          sec_qty_uom_code,
          short_comment,
          trans_id,
          use_in_pl_ind,
          weight_detail_num,
          weight_type
   from dbo.aud_phys_inv_weight
   where exec_inv_num = @exec_inv_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchExecPhysInvToPhysInvWeight] TO [next_usr]
GO

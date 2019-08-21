SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[fetchFormulaBodyToFormulaBodyTrigger]
   @asof_trans_id       bigint,
   @formula_body_num    tinyint,
   @formula_num         int,
   @trigger_num			tinyint
as
declare @trans_id bigint

   select
		asof_trans_id=@asof_trans_id,
		formula_body_num,
		formula_num,
		input_lock_ind,
		input_qty,
		input_qty_uom_code,
		parcel_num,
		resp_trans_id=NULL,
		trans_id,
		trigger_date,
		trigger_num,
		trigger_price,
		trigger_price_curr_code,
		trigger_price_uom_code,
		trigger_qty,
		trigger_qty_uom_code
   from dbo.formula_body_trigger
   where formula_num = @formula_num and 
         formula_body_num = @formula_body_num and 
		 trigger_num = @trigger_num and
         trans_id <= @asof_trans_id
   union
   select
		asof_trans_id=@asof_trans_id,                   
		formula_body_num,
		formula_num,
		input_lock_ind,
		input_qty,
		input_qty_uom_code,
		parcel_num,
		resp_trans_id,
		trans_id,
		trigger_date,
		trigger_num,
		trigger_price,
		trigger_price_curr_code,
		trigger_price_uom_code,
		trigger_qty,
		trigger_qty_uom_code  
   from dbo.aud_formula_body_trigger
   where formula_num = @formula_num and 
         formula_body_num = @formula_body_num and 
		 trigger_num = @trigger_num and
         (trans_id <= @asof_trans_id and 
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaBodyToFormulaBodyTrigger] TO [next_usr]
GO

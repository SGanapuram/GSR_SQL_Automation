SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchAiEstActualSpecRevPK]
(
   @ai_est_actual_num   smallint,
   @alloc_item_num      smallint,
   @alloc_num           int,
   @asof_trans_id       bigint,
   @spec_code           char(8)
)
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.ai_est_actual_spec
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num and
         spec_code = @spec_code

if @trans_id <= @asof_trans_id
begin
   select 
	   ai_est_actual_num,
       alloc_item_num,
       alloc_num,
       asof_trans_id = @asof_trans_id,
       resp_trans_id = null,
       spec_actual_value,
       spec_actual_value_text,
       spec_code,
       spec_provisional_val,
       trans_id,
	   use_in_cost_ind,
	   use_in_formula_ind
   from dbo.ai_est_actual_spec
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num and
         spec_code = @spec_code
end
else
begin
   set rowcount 1
   select 
 	   ai_est_actual_num,
       alloc_item_num,
       alloc_num,
       asof_trans_id = @asof_trans_id,
       resp_trans_id,
       spec_actual_value,
       spec_actual_value_text,
       spec_code,
       spec_provisional_val,
       trans_id,
	   use_in_cost_ind,
	   use_in_formula_ind
   from dbo.aud_ai_est_actual_spec
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num and
         spec_code = @spec_code and
         trans_id <= @asof_trans_id and
	     resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAiEstActualSpecRevPK] TO [next_usr]
GO

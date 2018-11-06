SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchActualToActualSpec]
(
   @ai_est_actual_num      smallint,
   @alloc_item_num         smallint,
   @alloc_num              int,
   @asof_trans_id          int
)
as
set nocount on
 
   select ai_est_actual_num,
          alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,
          resp_trans_id = NULL,
          spec_actual_value,
          spec_actual_value_text,
          spec_code,
          spec_provisional_val,
          trans_id
   from dbo.ai_est_actual_spec
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num and
         trans_id <= @asof_trans_id
   union
   select ai_est_actual_num,
          alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,
          resp_trans_id,
          spec_actual_value,
          spec_actual_value_text,
          spec_code,
          spec_provisional_val,
          trans_id
   from dbo.aud_ai_est_actual_spec
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         ai_est_actual_num = @ai_est_actual_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchActualToActualSpec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchActualToActualSpec', NULL, NULL
GO

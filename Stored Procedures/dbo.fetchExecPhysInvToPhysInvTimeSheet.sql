SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchExecPhysInvToPhysInvTimeSheet]                                      
(
   @asof_trans_id      bigint,
   @exec_inv_num       int
)
as
set nocount on
declare @trans_id   bigint
   select asof_trans_id = @asof_trans_id,
          cmnt_num,
          document_id,
          event_from_date,
          event_to_date,
          exec_inv_num,
          from_date_actual_ind,
          loc_code,
          logistic_event,
          logistic_event_order_num,
          mot_code,
          oid,
          resp_trans_id = NULL,
          short_comment,
          spec_code,
          to_date_actual_ind,
          trans_id
   from dbo.phys_inv_time_sheet
   where exec_inv_num = @exec_inv_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          cmnt_num,
          document_id,
          event_from_date,
          event_to_date,
          exec_inv_num,
          from_date_actual_ind,
          loc_code,
          logistic_event,
          logistic_event_order_num,
          mot_code,
          oid,
          resp_trans_id,
          short_comment,
          spec_code,
          to_date_actual_ind,
          trans_id
   from dbo.aud_phys_inv_time_sheet
   where exec_inv_num = @exec_inv_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchExecPhysInvToPhysInvTimeSheet] TO [next_usr]
GO

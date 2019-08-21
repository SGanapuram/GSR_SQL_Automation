SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[CheckALSrunForQuiesced]
as
set nocount on

   /*
      als_run_status_id als_run_status_desc
      ----------------- --------------------
                      0 PENDING
                      1 WORKING
                      2 COMPLETED
                      3 FAILED
                      4 DBSAVEFAILED
                      5 UNNEEDED
                      6 MISSINGDATA
                      7 CRASHED
   */

   if exists (select 1
              from dbo.als_run a,
                   dbo.server_config b with (nolock)
              where a.als_module_group_id = b.als_module_group_id and
                    b.als_module_group_desc in ('MainALS', 
                                                'CriticalALSUpdatePosQtyForInv', 
                                                'CriticalALSUpdatePosQtyForTid', 
                                                'ForexCriticalALS', 
                                                'ExtendedALS') and
                    a.als_run_status_id between 0 and 1)
      select 0 as 'trans_id'   
   else
      /* select 1 as 'status' */
      select isnull(max(trans_id), 0) as 'trans_id'
      from dbo.icts_transaction
GO
GRANT EXECUTE ON  [dbo].[CheckALSrunForQuiesced] TO [next_usr]
GO

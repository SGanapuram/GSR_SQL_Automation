SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchDeletedAllocItemsForAlloc] 
(       
   @alloc_num       int 
) 
as     
set nocount on     
declare @errcode       int,
        @smsg          varchar(max) 
                         
   set @errcode = 0                    
/*
   create table #deleted_ai  
   ( 
      alloc_num        int, 
      alloc_item_num   smallint,  
      resp_trans_id    bigint,
        PRIMARY KEY (alloc_num, alloc_item_num, resp_trans_id)
   ) 
 
   insert into #deleted_ai 
     select alloc_num,
            alloc_item_num,
            max(resp_trans_id) 
     from dbo.aud_allocation_item aud  
     where alloc_num = @alloc_num and 
           not exists (select 1 
                       from dbo.allocation_item a 
                       where aud.alloc_num = a.alloc_num and 
                             aud.alloc_item_num = a.alloc_item_num)  
     group by alloc_num, alloc_item_num 
   select @errcode = @@error
   if @errcode > 0
   begin
      print '=> Failed to copy records into the #deleted_ai table!'
      goto endofsp
   end
*/   
   begin try
   select 
      aud.acct_num,
      aud.acct_ref_num,
      aud.actual_gross_qty,
      aud.actual_gross_uom_code,
      aud.alloc_item_confirm,
      aud.alloc_item_num,
      aud.alloc_item_short_cmnt,
      aud.alloc_item_status,
      aud.alloc_item_type,
      aud.alloc_item_verify,
      aud.alloc_num,
      aud.ar_alloc_item_num,
      aud.ar_alloc_num,
      aud.trans_id as asof_trans_id,
      aud.auto_receipt_actual_ind,
      aud.auto_receipt_ind,
      aud.auto_sampling_comp_num,
      aud.auto_sampling_ind,
      aud.cmdty_code,
      aud.cmnt_num,
      aud.confirmation_date,
      aud.cr_anly_init,
      aud.cr_clear_ind,
      aud.credit_term_code,
      aud.del_term_code,
      aud.dest_loc_code,
      aud.estimate_event_date,
      aud.final_dest_loc_code,
	  aud.finance_bank_num,
      aud.fully_actualized,
      aud.imp_rec_ind,
      aud.imp_rec_reason_oid,
      aud.insp_acct_num,
      aud.inspection_date,
      aud.inspector_percent,
      aud.inv_num,
      aud.item_num,
      aud.lc_num,
      aud.load_port_loc_code,
      aud.max_ai_est_actual_num,
      aud.net_nom_num,
      aud.nomin_date_from,
      aud.nomin_date_to,
      aud.nomin_qty_max,
      aud.nomin_qty_max_uom_code,
      aud.nomin_qty_min,
      aud.nomin_qty_min_uom_code,
      aud.order_num,
      aud.origin_loc_code,
      aud.pay_days,
      aud.pay_term_code,
      aud.purchasing_group,
      aud.recap_item_num,
      aud.reporting_date,
      aud.resp_trans_id,
	  aud.sap_delivery_line_item_num,
      aud.sap_delivery_num,
      aud.sch_qty,
      aud.sch_qty_periodicity,
      aud.sch_qty_uom_code,
      aud.sec_actual_uom_code,
      aud.secondary_actual_qty,
      aud.ship_agent_comp_num,
      aud.ship_broker_comp_num,
      aud.sub_alloc_num,
      aud.title_tran_date,
      aud.title_tran_loc_code,
      aud.trade_num,
      aud.trans_id,
      aud.transfer_price,
      aud.transfer_price_curr_code,
      aud.transfer_price_curr_code_to,
      aud.transfer_price_currency_rate,
      aud.transfer_price_uom_code,
      aud.vat_ind      
   from dbo.aud_allocation_item aud,
        (select alloc_num,
                alloc_item_num,
                max(resp_trans_id) as resp_trans_id
         from dbo.aud_allocation_item aud  
         where alloc_num = @alloc_num and 
               not exists (select 1 
                           from dbo.allocation_item a 
                           where aud.alloc_num = a.alloc_num and 
                                 aud.alloc_item_num = a.alloc_item_num)  
         group by alloc_num, alloc_item_num) d 
   where aud.alloc_num = d.alloc_num and 
         aud.alloc_item_num = d.alloc_item_num and 
         aud.resp_trans_id = d.resp_trans_id 
   end try
   begin catch
     set @errcode = ERROR_NUMBER()
     set @smsg = ERROR_MESSAGE()
     RAISERROR('=> Failed to fetch and return aud_allocation_item records due to the error below:', 0, 1) with nowait
     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
     goto endofsp
   end catch

endofsp: 
if @errcode > 0
   return 1
return 0
GO
GRANT EXECUTE ON  [dbo].[fetchDeletedAllocItemsForAlloc] TO [next_usr]
GO

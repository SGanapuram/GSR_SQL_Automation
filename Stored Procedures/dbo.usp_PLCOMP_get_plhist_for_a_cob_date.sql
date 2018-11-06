SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[usp_PLCOMP_get_plhist_for_a_cob_date]  
(  
   @cob_date      datetime,  
   @debugon       bit = 0  
)  
as  
set nocount on  
declare @status            int,  
        @smsg              varchar(800),  
        @rows_affected     int,  
        @time_started      varchar(20),  
        @time_finished     varchar(20)  
          
   set @status = 0  
   set @time_started = (select convert(varchar, getdate(), 109))  
  
   begin try  
     select                              
        pl_record_key,                              
        pl_owner_code,                              
        pl_asof_date,                              
        real_port_num,                              
        pl_owner_sub_code,                              
        pl_record_owner_key,                              
        pl_primary_owner_key1,                              
        pl_primary_owner_key2,                              
        pl_primary_owner_key3,                              
        pl_primary_owner_key4,                              
        pl_secondary_owner_key1,                              
        pl_secondary_owner_key2,                              
        pl_secondary_owner_key3,                              
        pl_type,                              
        pl_category_type,                              
        pl_realization_date,                              
        pl_cost_status_code,                              
        pl_cost_prin_addl_ind,                              
        pl_mkt_price,                              
        pl_amt,                              
        trans_id,                              
        currency_fx_rate,                              
        pl_record_qty,                              
        pl_record_qty_uom_code,                              
        pos_num,  
        case when pl_owner_sub_code is null then null   
             when pl_owner_code in ('I', 'P') then null   
             else pl_record_key   
        end,   /* cost_num */                                                          
        case when pl_owner_code = 'C' then 'Cost'                                                           
             when pl_owner_code in ('I', 'P') then 'Inventory Position'                                                           
             when pl_owner_code = 'T' then 'Trade Value/MTM'   
             else pl_owner_code   
        end,   /* pl_owner */                                                          
        case when pl_owner_sub_code = 'ADDLP' then convert (varchar, pl_record_key)                             
             else convert(varchar, pl_secondary_owner_key1) + '/' +   
                     convert(varchar, pl_secondary_owner_key2)+ '/' +   
                       convert(varchar, pl_secondary_owner_key3)   
        end,   /* trade_key */                                                          
        case when pl_owner_sub_code in ('WPP', 'W', 'F', 'PR', 'PO', 'SWAP', 'F', 'CPP', 'CPR', 'DPP')   
                then 'TRADING'                                                           
             when pl_owner_sub_code in ('WS', 'ADDLP', 'WS', 'ADDLAI', 'ADDLA', 'ADDLTI', 'SPP')   
                then 'ADDITIONAL COSTS'                                               
             when pl_owner_sub_code is null   
                then 'INVENTORY'                                                           
             when pl_owner_sub_code = 'D' and pl_owner_code = 'T'
                then 'TRADING'
			 when pl_owner_sub_code in ('Inventory Position', 'I', 'D')   
                then 'INVENTORY'                                                        
        end,      /* trade_cost_type */                               
        case when pl_owner_sub_code in ('CPP', 'CPR')   
                then 'CURRENCY'                                       
             when pl_owner_sub_code is null   
                then 'INVENTORY_POSITION'                                                            
             when pl_owner_sub_code = 'D' and pl_owner_code = 'T'
                then 'TRADE_VALUE'
			 when pl_owner_sub_code = 'D'   
                then 'INVENTORY_DRAWS'                                                           
             when pl_owner_sub_code = 'B'   
                then 'INVENTORY_BUILD'                   
             when pl_owner_sub_code = 'W'   
                then 'MARKET_VALUE'                                       
             when pl_owner_sub_code = 'SWAP'   
                then 'MTMVALUE'                                                           
             when pl_owner_sub_code = 'PO'   
                then 'PROVISIONAL OFFSET'                                                          
             when pl_owner_sub_code = 'PR'   
                then 'PROVISIONAL'                                                
             when pl_owner_sub_code in ('F', 'X') and   
                  pl_type = 'U'   
                then 'MARKET_VALUE'                                        
             when pl_owner_sub_code in ('F', 'X') and   
                  pl_type = 'R'   
                then 'TRADE_VALUE'                                            
             when pl_owner_sub_code in ('F', 'X') and   
                  pl_type = 'C'   
                then 'TRADE_COST'                                              
             when pl_owner_sub_code = 'NO'   
                then 'NETOUT'                                         
             when pl_owner_sub_code in ('ADDLA', 'ADDLAA', 'ADDLAI',   
                                        'ADDLP', 'ADDLSWAP', 'ADDLTI',   
                                        'BC', 'FBC', 'JV', 'MEMO','OBC',  
                                        'PS', 'PTS', 'SAC', 'SPP',     
                                        'STC', 'SWBC', 'TAC', 'TPP',    
                                        'WAP', 'WO', 'WS')   
                then 'SERVICES'                                
             when pl_owner_sub_code in ('BO', 'BOAI', 'BPP', 'E', 'O', 'OPP', 'OTC', 'WPP', 'DPP')   
                then 'TRADE_VALUE'                                              
             when pl_owner_sub_code in ('C','NO')   
                then 'TRADE_COST'                                      
             when pl_owner_sub_code in ('Inventory Position', 'I')   
                then 'INVENTORY'                                      
             else   
                pl_owner_sub_code   
        end    /* pl_type_desc */                                                                                    
     from dbo.pl_history as plhist with (NOLOCK)                            
     where pl_asof_date = @cob_date and   
           pl_type not in ('W', 'I') and  
           exists (select 1  
                   from #children c  
                   where plhist.real_port_num = c.port_num)  
     set @rows_affected = @@rowcount  
   end try  
   begin catch  
     set @smsg = '=> Failed to retrieve pl_history records for the COB date ''' + convert(varchar, @cob_date, 101) + ''' due to the error:'  
     RAISERROR (@smsg, 0, 1) WITH NOWAIT  
     set @smsg = '==> ERROR: ' + ERROR_MESSAGE()  
     RAISERROR (@smsg, 0, 1) WITH NOWAIT  
     goto endofsp        
   end catch  
   if @debugon = 1  
   begin  
     RAISERROR ('**********************', 0, 1) WITH NOWAIT      
     set @smsg = '=> ' + cast(@rows_affected as varchar) + ' pl_history records were retrieved for the COB DATE ''' + convert(varchar, @cob_date, 101) + ''''  
     RAISERROR (@smsg, 0, 1) WITH NOWAIT  
     set @time_finished = (select convert(varchar, getdate(), 109))  
     set @smsg = '==> Started : ' + @time_started  
     RAISERROR (@smsg, 0, 1) WITH NOWAIT  
     set @smsg = '==> Finished: ' + @time_finished  
     RAISERROR (@smsg, 0, 1) WITH NOWAIT       
   end  
     
endofsp:  
return @status  
GO
GRANT EXECUTE ON  [dbo].[usp_PLCOMP_get_plhist_for_a_cob_date] TO [next_usr]
GO

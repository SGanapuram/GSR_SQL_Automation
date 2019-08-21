SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_add_shipment_4_storage_trade]  
(  
   @alloc_num                int,  
   @trans_id                 bigint,  
   @debugon                  bit = 0  
)  
as  
set nocount on  
set xact_abort on  
  
declare @errmsg                     varchar(max)  
declare @rows_affected              int  
declare @errcode                    int  
declare @alloc_type_code            char(1)   
declare @mot_type_code              char(1)   
declare @shipment_oid               int  
declare @parcel_oid                 int  
declare @sch_init                   char(3)  
declare @update_by_init             char(3)  
declare @creation_date              datetime  
declare @sch_qty_uom_code           char(4)  
declare @origin_loc_code            char(8)  
declare @sch_from_date              datetime  
declare @parent_cmdty_code          char(8)  
declare @cmdty_code                 char(8)  
declare @dest_loc_code              char(8)  
declare @sch_to_date                datetime  
declare @nomin_qty_max_R            float  
declare @nomin_qty_max_C            float  
declare @alloc_item_num             smallint  
declare @capacity                   float  
  
declare @alloc_status               char(1)  
declare @alloc_item_status          char(1)  
declare @parcel_status              tinyint  
declare @shipment_status            tinyint  
  
 
         
   /* **************************************************************** */  
   /* Getting a new shipment_oid */  
   
    exec get_new_num 'shipment_oid',0   
   select @shipment_oid = last_num from dbo.new_num where num_col_name = 'shipment_oid'     
     
   if @shipment_oid is null  
   begin   
      RAISERROR('=> Failed to obtain an OID for new shipment!', 0, 1) WITH NOWAIT  
      set @errcode = 1     
      goto endofsp                 
   end             
  
   if @debugon = 1  
   begin  
      RAISERROR('DEBUG: OID for new shipment is %d', 0, 1, @shipment_oid) WITH NOWAIT  
   end                    
  
   set @update_by_init = null  
   set @update_by_init = (select user_init  
                          from dbo.icts_user  
                          where user_logon_id = suser_name())  
                            
   select @alloc_type_code = alloc_type_code,  
          @sch_init = sch_init,  
          @alloc_status = alloc_status,  
          @creation_date = creation_date  
   from dbo.allocation  
   where alloc_num = @alloc_num  
  
   set @shipment_status = null  
   if @alloc_status in ('A', 'C')  
      set @shipment_status = 3  
   if @alloc_status = 'D'  
      set @shipment_status = 8  
  
   set @mot_type_code = case when @alloc_type_code in ('D', 'G', 'P') then 'P'  
                             when @alloc_type_code = 'K' then 'T'  
                             when @alloc_type_code = 'L' then 'L'  
                             when @alloc_type_code = 'R' then 'R'  
                             when @alloc_type_code = 'W' then 'V'  
                             else '?'  
                        end  
                          
   select @sch_qty_uom_code = sch_qty_uom_code,  
          @origin_loc_code = origin_loc_code,  
          @sch_from_date = nomin_date_from,  
          @cmdty_code = cmdty_code,  
          @nomin_qty_max_R = nomin_qty_max  
   from dbo.allocation_item   
   where alloc_num = @alloc_num and  
         alloc_item_num = 1   /* alloc_item_type = 'R' */  
  
   if @origin_loc_code is null  
   begin  
      set @origin_loc_code = (select load_port_loc_code  
                              from dbo.trade_item ti  
                   where exists (select 1  
                                            from dbo.allocation_item ai  
                                            where ai.alloc_num = @alloc_num and  
                                                  ai.alloc_item_num = 1 and  
                                                  ai.trade_num = ti.trade_num and  
                                                  ai.order_num = ti.order_num and  
                                                  ai.item_num = ti.item_num))  
   end  
  
   select @dest_loc_code = dest_loc_code,  
          @sch_to_date = nomin_date_to,  
          @nomin_qty_max_C = nomin_qty_max  
   from dbo.allocation_item   
   where alloc_num = @alloc_num and  
         alloc_item_num = 2   /* alloc_item_type = 'C' */  
  
   if @dest_loc_code is null  
   begin  
      set @dest_loc_code = (select disch_port_loc_code  
                            from dbo.trade_item ti  
                            where exists (select 1  
                                          from dbo.allocation_item ai  
                                          where ai.alloc_num = @alloc_num and  
                                                ai.alloc_item_num = 2 and  
                                                ai.trade_num = ti.trade_num and  
                                                ai.order_num = ti.order_num and  
                                                ai.item_num = ti.item_num))  
   end     
  
   set @capacity = isnull(@nomin_qty_max_R, 0)  
   if isnull(@nomin_qty_max_C, 0) > @capacity  
      set @capacity = @nomin_qty_max_C  
     
   begin try  
     insert into dbo.shipment  
         (oid,      
         status,  
         reference,  
         primary_shipment_num,      
         alloc_num,      
         mot_type_code,  
         capacity,      
         capacity_uom_code,  
         ship_qty,      
         ship_qty_uom_code,  
         cmdty_code,      
         start_loc_code,      
         end_loc_code,      
         start_date,      
         end_date,      
         transport_owner_id,      
         transport_operator_id,      
         pipeline_cycle_num,      
         freight_rate,      
         freight_rate_uom_code,  
         freight_rate_curr_code,      
         freight_pay_term_code,      
         contract_num,      
         creator_init,      
         creation_date,      
         last_update_by_init,      
         last_update_date,      
         trans_id,      
         transport_reference,      
         cmnt_num,      
         load_facility_code,      
         load_tank_num,      
         dest_facility_code,      
         dest_tank_num,      
         contract_order_num,      
         manual_transport_parcels,      
         feed_interface,      
         balance_qty,      
         sap_shipment_num)  
      values(@shipment_oid,                    /* oid */  
             @shipment_status,                 /* status */  
             cast(@shipment_oid as varchar),   /* reference */  
             null,                             /* primary_shipment_num */     
             @alloc_num,                       /* alloc_num */   
             @mot_type_code,                   /* mot_type_code */  
             @capacity,                        /* capacity */      
             @sch_qty_uom_code,                /* capacity_uom_code */  
             @capacity,                        /* ship_qty */      
             @sch_qty_uom_code,                /* ship_qty_uom_code */  
             @cmdty_code,                      /* cmdty_code */  
             @origin_loc_code,                 /* start_loc_code */      
             @dest_loc_code,                   /* end_loc_code */     
             @sch_from_date,                   /* start_date */     
             @sch_to_date,                     /* end_date */      
             null,                             /* transport_owner_id */      
             null,                             /* transport_operator_id */      
             null,             /* pipeline_cycle_num */      
             null,                             /* freight_rate */      
             null,                             /* freight_rate_uom_code */  
             null,                             /* freight_rate_curr_code */      
             null,                             /* freight_pay_term_code */      
             null,                             /* contract_num */      
             @sch_init,                        /* creator_init */     
             @creation_date,                   /* creation_date */  
             @update_by_init,                  /* last_update_by_init */      
             getdate(),                        /* last_update_date */      
             @trans_id,                        /* trans_id */  
             null,                             /* transport_reference */      
             null,                             /* cmnt_num */      
             null,                             /* load_facility_code */      
             null,                             /* load_tank_num */      
             null,                             /* dest_facility_code */      
             null,                             /* dest_tank_num */      
             null,                             /* contract_order_num */      
             0,                                /* manual_transport_parcels */      
             null,                             /* feed_interface */      
             null,                             /* balance_qty */      
             null)                             /* sap_shipment_num */    
      set @rows_affected = @@rowcount       
   end try  
   begin catch  
     RAISERROR('=> Failed to add a shipment record due to the error:', 0, 1) WITH NOWAIT    
     set @errmsg = ERROR_MESSAGE()  
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT    
     set @errcode = ERROR_NUMBER()        
     goto endofsp                     
   end catch  
  
   if @debugon = 1  
   begin  
      if @rows_affected > 0  
         RAISERROR('DEBUG: %d new shipment record (%d) was added successfully', 0, 1, @rows_affected, @shipment_oid) WITH NOWAIT    
      else  
         RAISERROR('DEBUG: No new shipment record (%d) was added!', 0, 1, @shipment_oid) WITH NOWAIT  
   end  
  
     
   /* **************************************************************** */  
   /* **************************************************************** */  
   /* Getting new parcel_oid */  
   
       exec get_new_num 'parcel_oid',2   /* There are 2 parcels needed, so reserve 2 parcel OIDs */    
   select @parcel_oid = (last_num - 1) from dbo.new_num where num_col_name = 'parcel_oid' 
  
   if @debugon = 1  
   begin  
      RAISERROR('DEBUG: First OID for new parcel is %d', 0, 1, @parcel_oid) WITH NOWAIT  
   end                    
  
   /* *********************************************** */             
   select @alloc_item_num = min(alloc_item_num)  
   from dbo.allocation_item  
   where alloc_num = @alloc_num  
     
   while @alloc_item_num is not null  
   begin  
      set @parcel_status = null  
      set @alloc_item_status = null  
      set @cmdty_code = null  
      set @parent_cmdty_code = null  
        
      select @alloc_item_status = alloc_item_status,  
             @cmdty_code = cmdty_code  
      from dbo.allocation_item  
      where alloc_num = @alloc_num and  
            alloc_item_num = @alloc_item_num  
        
      set @parent_cmdty_code = (select parent_cmdty_code   
                                from dbo.commodity_group with (nolock)   
                                where cmdty_code = @cmdty_code and   
                                      cmdty_group_type_code = 'POSITION')  
                                             
      if @alloc_item_status = 'C'  
      begin  
         if exists (select 1  
                    from dbo.ai_est_actual  
                    where alloc_num = @alloc_num and  
                          alloc_item_num = @alloc_item_num and  
                          ai_est_actual_ind = 'A')   
            set @parcel_status = 10  
         else  
            set @parcel_status = 9  
      end  
  
      if @alloc_item_status = 'A'  
         set @parcel_status = 6  
           
      begin try  
        insert into dbo.parcel  
           (oid,  
           type,  
           associative_state,  
           status,  
           reference,  
           sch_qty,  
           sch_qty_uom_code,  
           location_code,  
           facility_code,  
           tank_code,  
           cmdty_code,  
           product_code,  
           grade,  
           quality,  
           mot_type_code,  
           estimated_date,  
           sch_from_date,  
           sch_to_date,  
           creator_init,  
           creation_date,  
           last_update_by_init,  
           last_update_date,  
           forecast_num,  
           trade_num,  
           order_num,  
           item_num,  
           inv_num,  
           shipment_num,  
           alloc_num,  
           alloc_item_num,  
           trans_id,  
           nomin_qty,  
           nomin_qty_uom_code,  
           cmnt_num,  
           t4_loc,  
           t4_consignee,  
           t4_tankage,  
           gn_taric_code,  
           custom_code,  
           tariff_code,  
           custom_status,  
           excise_status,  
           transmitall_type,  
           inspector,  
           latest_feed_name,  
           send_to_sap,  
           bookco_bank_acct_num)          
       select @parcel_oid,                       /* oid */  
              case when alloc_item_type in ('I', 'R') then 'R'  
                    when alloc_item_type in ('C', 'D') then 'D'  
                    when alloc_item_type in ('N', 'T') then 'S'  
                    else '?'  
                 end,                               /* type */  
              2,                                /* associative_state */  
              11,                               /* @parcel_status status */  
              cast(@parcel_oid as varchar),      /* reference */  
              sch_qty,                           /* sch_qty */  
              sch_qty_uom_code,                  /* sch_qty_uom_code */  
              origin_loc_code,                   /* location_code */  
              null,                              /* facility_code */  
              null,                              /* tank_code */  
              @parent_cmdty_code,                /* cmdty_code */  
              @cmdty_code,                       /* product_code */  
              null,                              /* grade */  
              null,                              /* quality */          
              case when @alloc_type_code in ('D', 'G', 'P') then 'P'  
                      when @alloc_type_code = 'K' then 'T'  
                      when @alloc_type_code = 'L' then 'L'  
                      when @alloc_type_code = 'R' then 'R'  
                      when @alloc_type_code = 'W' then 'V'  
                 end,                                /* mot_type_code */  
              nomin_date_from,                    /* estimated_date */  
              nomin_date_from,                    /* sch_from_date */  
              nomin_date_to,                      /* sch_to_date */  
              @sch_init,                          /* creator_init */  
              @creation_date,                     /* creation_date */  
              @update_by_init,                    /* last_update_by_init */  
              getdate(),                          /* last_update_date */  
              null,                /* forecast_num */  
              trade_num,  
              order_num,  
              item_num,  
              inv_num,  
              @shipment_oid,                      /* shipment_num */  
              alloc_num,  
              alloc_item_num,  
              @trans_id,                          /* trans_id */  
              nomin_qty_max,                      /* nomin_qty */  
              nomin_qty_max_uom_code,             /* nomin_qty_uom_code */  
              null,                               /* cmnt_num */  
              null,                               /* t4_loc */  
              null,                               /* t4_consignee */  
              null,                               /* t4_tankage */  
              null,                               /* gn_taric_code */  
              null,                               /* custom_code */  
              null,                               /* tariff_code */  
              null,                               /* custom_status */  
              null,                               /* excise_status */  
              null,                               /* transmitall_type */  
              null,                               /* inspector */  
              null,                               /* latest_feed_name */  
              null,                               /* send_to_sap */  
              null                                /* bookco_bank_acct_num */  
       from dbo.allocation_item  
       where alloc_num = @alloc_num and  
             alloc_item_num = @alloc_item_num  
        set @rows_affected = @@rowcount       
      end try  
      begin catch  
        RAISERROR('=> Failed to add a parcel record (%d) due to the error:', 0, 1, @parcel_oid) WITH NOWAIT    
        set @errmsg = ERROR_MESSAGE()  
        RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT    
        set @errcode = ERROR_NUMBER()        
        goto endofsp                     
      end catch  
      if @debugon = 1  
      begin  
         if @rows_affected > 0  
            RAISERROR('DEBUG: %d new parcel record (%d) was added successfully', 0, 1, @rows_affected, @parcel_oid) WITH NOWAIT    
         else  
            RAISERROR('DEBUG: No new parcel record (%d) was added!', 0, 1, @parcel_oid) WITH NOWAIT  
      end  
  
      set @parcel_oid = @parcel_oid + 1  
        
      select @alloc_item_num = min(alloc_item_num)  
      from dbo.allocation_item  
      where alloc_num = @alloc_num and  
            alloc_item_num > @alloc_item_num  
   end     
       
endofsp:  
if @errcode > 0  
   return 1  
return 0  
GO
GRANT EXECUTE ON  [dbo].[usp_add_shipment_4_storage_trade] TO [next_usr]
GO

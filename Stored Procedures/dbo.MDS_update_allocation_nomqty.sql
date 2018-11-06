SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[MDS_update_allocation_nomqty]    
@alloc_num int,    
@alloc_item_num int,    
@nom_qty_max float,    
@nom_qty_min float=NULL,    
@debugon int=0    
    
AS    
BEGIN    
    
DECLARE @ai_est_actual_num int, @primary_uom char(8), @sec_uom char(8), @dest_loc_code char(8), @sec_conversion_factor float, @cmdty_code char(8), @sequence numeric, @trans_id int                                  
DECLARE @conv_ratio_gross float,@conv_ratio_net float,@ai_est_actual_gross_qty float,@ai_est_actual_net_qty float,@secondary_actual_gross_qty float,   
  @secondary_actual_net_qty float,@trade_num int,   
  @order_num int, @item_num int,@secondary_net_qty float,@num_of_days int    
    
  SELECT @trade_num=trade_num, @order_num=order_num , @item_num=item_num    
  from allocation_item     
  where alloc_num=@alloc_num    
  and alloc_item_num=@alloc_item_num    
    
    
SELECT @nom_qty_min=isnull(@nom_qty_max,0)    
WHERE isnull(@nom_qty_min,0)=0     
    
If not exists (select 1 from ai_est_actual where alloc_num=@alloc_num and alloc_item_num=@alloc_item_num and ai_est_actual_num=0 and ai_est_actual_net_qty>0)    
BEGIN    
  SELECT -1    
  return -1    
END    
      
/*  
Include condition for tolerance  
If not exists (select 1 from allocation_item where alloc_num=@alloc_num and alloc_item_num=@alloc_item_num and (nomin_qty_max-@nom_qty_max)>0 )    
BEGIN    
  SELECT -2    
  return -1    
END  */  
    
    
    
 select @conv_ratio_gross=ai_est_actual_gross_qty/secondary_actual_gross_qty,    
   @conv_ratio_net= ai_est_actual_net_qty/secondary_actual_net_qty    
 from ai_est_actual     
 where alloc_num=@alloc_num     
 and alloc_item_num=@alloc_num    
 and ai_est_actual_num=0    
    
    
 select @ai_est_actual_gross_qty=sum(ai_est_actual_gross_qty),    
   @ai_est_actual_net_qty= sum(ai_est_actual_net_qty),    
   @secondary_actual_gross_qty=sum(secondary_actual_gross_qty),    
   @secondary_actual_net_qty= sum(secondary_actual_net_qty)    
 from ai_est_actual     
 where alloc_num=@alloc_num     
 and alloc_item_num=@alloc_item_num     
 and ai_est_actual_num>0    
    
 if (@debugon=1)    
 BEGIN    
  SELECT sum(ai_est_actual_gross_qty), sum(ai_est_actual_net_qty),sum(secondary_actual_gross_qty),sum(secondary_actual_net_qty)    
  from ai_est_actual     
  where alloc_num=@alloc_num     
  and alloc_item_num=@alloc_item_num     
  and ai_est_actual_num>0    
      
    
  SELECT @ai_est_actual_net_qty,@nom_qty_max,@ai_est_actual_net_qty-@nom_qty_max,* from ai_est_actual where alloc_num=@alloc_num and alloc_item_num=@alloc_item_num and ai_est_actual_num=0    
     
 END    
     
    
  if exists (select 1 from trade_item where trade_num=@trade_num and order_num=@order_num and item_num=@item_num and contr_qty_periodicity='D' )    
  BEGIN    
   select @num_of_days=datediff(dd,del_date_from,del_date_to)+1    
   from trade_item_wet_phy     
   where trade_num =@trade_num     
   and order_num=@order_num     
   and item_num=@item_num    
    
   select @num_of_days= datediff(dd,storage_start_date,storage_end_date)+1    
   from trade_item_storage    
   where trade_num =@trade_num     
   and order_num=@order_num     
   and item_num=@item_num    
    
   select @num_of_days=datediff(dd,load_date_from,load_date_to)+1    
   from trade_item_transport    
   where trade_num =@trade_num     
   and order_num=@order_num     
   and item_num=@item_num    
    
    
   IF not exists (SELECT 1    
   FROM ai_est_actual    
   WHERE alloc_num=@alloc_num     
   and alloc_item_num=@alloc_item_num     
   and ai_est_actual_num=0     
   and (@nom_qty_max*@num_of_days)-@ai_est_actual_net_qty>0 )    
   BEGIN    
    SELECT -3    
    return -1    
   END     
       
  END     
  if not exists (select 1 from trade_item where trade_num=@trade_num and order_num=@order_num and item_num=@item_num and contr_qty_periodicity='D' )    
  BEGIN    
   IF (@debugon=1)    
    select @nom_qty_max-@ai_est_actual_net_qty    
        
    SELECT contr_qty_periodicity    
    from trade_item where trade_num=@trade_num and order_num=@order_num and item_num=@item_num     
       
   if not exists (select 1 from ai_est_actual where alloc_num=@alloc_num and alloc_item_num=@alloc_item_num and ai_est_actual_num=0 and @nom_qty_max-@ai_est_actual_net_qty>0)    
   BEGIN    
    SELECT -4    
    return -1    
   END       
  END    
     
      
 SELECT @num_of_days=1     
 where @num_of_days is null    
    
    
  IF(@secondary_net_qty is null)                                  
  BEGIN                                  
   SELECT @sec_conversion_factor=sec_conversion_factor                                   
   from trade_item_dist tid, allocation_item ai                                  
   where dist_type='D'                                   
   and tid.trade_num=ai.trade_num                                  
   and tid.order_num=ai.order_num                                  
   and tid.item_num=ai.item_num                                  
   and ai.alloc_num=@alloc_num                                  
   and ai.alloc_item_num=@alloc_item_num                                  
                                     
                                   
   IF(@sec_conversion_factor is null)                                  
   BEGIN                                  
    SELECT @sec_conversion_factor=uom_conv_rate from uom_conversion where cmdty_code=@cmdty_code and uom_code_conv_from=@primary_uom and uom_code_conv_to=@sec_uom and uom_conv_oper='M'                                  
    SELECT @sec_conversion_factor=1/uom_conv_rate from uom_conversion where cmdty_code=@cmdty_code and uom_code_conv_from=@primary_uom and uom_code_conv_to=@sec_uom and uom_conv_oper='D' and @sec_conversion_factor is null                                
   END                                   
   --SELECT  @secondary_gross_qty=isnull(@secondary_gross_qty,@actual_gross_qty*@sec_conversion_factor), @secondary_net_qty=isnull(@secondary_net_qty,@actual_net_qty*@sec_conversion_factor)                                  
                                   
  END                                  
            
    
    
      
  begin tran    
      
  exec gen_new_transaction 'MDS_update_allocation_nomqty','U'                                    
    
  select @trans_id=last_num from icts_trans_sequence     
                                     
  IF @@rowcount=0                                    
  BEGIN                                    
   select 'Unable to Generate new trans_id'                                    
   rollback                                    
   return                                    
  END                                  
        
 update allocation set trans_id= @trans_id     
 where alloc_num=@alloc_num    
     
 If @@rowcount=0    
 BEGIN    
  SELECT -100    
  rollback tran    
  return -1    
 end       
 ELSE     
     
 If (@debugon=1)    
 BEGIN    
  SELECT @nom_qty_min-@ai_est_actual_gross_qty GrossAdjustment, @nom_qty_max-@ai_est_actual_net_qty NetAdjustment,    
    (@nom_qty_min*@sec_conversion_factor)-@secondary_actual_gross_qty 'SecondaryGross',(@nom_qty_max*@sec_conversion_factor)-@secondary_actual_net_qty 'SecondaryNet'    
 END    
     
    
     
 update ai_est_actual set     
     trans_id=@trans_id ,     
     ai_est_actual_gross_qty = (@nom_qty_min*@num_of_days)-@ai_est_actual_gross_qty,      
     ai_est_actual_net_qty = (@nom_qty_max*@num_of_days)-@ai_est_actual_net_qty,     
     secondary_actual_gross_qty = ((@nom_qty_min*@num_of_days)*@sec_conversion_factor)-@secondary_actual_gross_qty,    
     secondary_actual_net_qty = ((@nom_qty_max*@num_of_days)*@sec_conversion_factor)-@secondary_actual_net_qty    
 where alloc_num=@alloc_num     
 and alloc_item_num=@alloc_item_num     
 and ai_est_actual_num=0    
 and ai_est_actual_net_qty>0    
 and (@nom_qty_max*@num_of_days)-@ai_est_actual_net_qty >=0    
      
 If @@rowcount=0    
 BEGIN    
  SELECT -200    
  rollback tran    
  return -1    
 end       
 ELSE     
 update allocation_item set     
     trans_id= @trans_id ,     
     nomin_qty_min=@nom_qty_min,    
     nomin_qty_max=@nom_qty_max     
 where alloc_num=@alloc_num     
 and alloc_item_num=@alloc_item_num    
    
 If @@rowcount=0    
 BEGIN    
  rollback tran    
  return -1    
 end       
 ELSE     
    
 update trade_item set trans_id=@trans_id     
 where trade_num=@trade_num     
 and order_num=@order_num     
 and item_num=@item_num    
    
 If @@rowcount=0    
 BEGIN    
  SELECT -300    
  rollback tran    
  return -1    
 end       
 ELSE    
 BEGIN    
  COMMIT TRAN    
  select 1    
  return 1    
 end    
end    
GO
GRANT EXECUTE ON  [dbo].[MDS_update_allocation_nomqty] TO [next_usr]
GO

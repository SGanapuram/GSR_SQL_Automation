SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_allocation_capacity]
(   
   @alloc_num          int,
	 @sch_qty_uom_code   char(4)
)
returns numeric(20, 8)
as
BEGIN
declare @nomin_qty_max_C_T     decimal(20, 8),
        @nomin_qty_max_I_N     decimal(20, 8),
        @nomin_qty_max_D       decimal(20, 8),
        @nomin_qty_max_R       decimal(20, 8),
        @nomin_qty_max         decimal(20, 8),
        @qty_uom_code          char(4),
        @cmdty_code            char(8)
        
   select @nomin_qty_max = 0.0
   
   /* nomin_qty_max - for transport/storage deliveries */             
   select @nomin_qty_max_C_T = (select sum(nomin_qty_max)  
                                from dbo.allocation_item
                                where alloc_num = @alloc_num and
                                      alloc_item_type in ('C', 'T'))
   select top 1 
      @qty_uom_code = nomin_qty_max_uom_code,
      @cmdty_code = cmdty_code
   from dbo.allocation_item
   where alloc_num = @alloc_num and
         alloc_item_type in ('C', 'T') and
         nomin_qty_max_uom_code is not null
   if @qty_uom_code <> @sch_qty_uom_code
      select @nomin_qty_max_C_T = @nomin_qty_max_C_T * dbo.udf_getUomConversion(@qty_uom_code, @sch_qty_uom_code, NULL, NULL, @cmdty_code)

   /* nomin_qty_max - for transport/storage reciepts */             
   select @nomin_qty_max_I_N = (select sum(nomin_qty_max)   
                                from dbo.allocation_item
                                where alloc_num = @alloc_num and
                                      alloc_item_type in ('I', 'N'))
   select top 1 
      @qty_uom_code = nomin_qty_max_uom_code,
      @cmdty_code = cmdty_code
   from dbo.allocation_item
   where alloc_num = @alloc_num and
         alloc_item_type in ('I', 'N') and
         nomin_qty_max_uom_code is not null
   if @qty_uom_code <> @sch_qty_uom_code
      select @nomin_qty_max_I_N = @nomin_qty_max_I_N * dbo.udf_getUomConversion(@qty_uom_code, @sch_qty_uom_code, NULL, NULL, @cmdty_code)

   /* nomin_qty_max - for physical deliveries */             
   select @nomin_qty_max_D = (select sum(nomin_qty_max)    
                              from dbo.allocation_item
                              where alloc_num = @alloc_num and
                                    alloc_item_type in ('D'))
   select top 1 
      @qty_uom_code = nomin_qty_max_uom_code,
      @cmdty_code = cmdty_code
   from dbo.allocation_item
   where alloc_num = @alloc_num and
         alloc_item_type in ('D') and
         nomin_qty_max_uom_code is not null
   if @qty_uom_code <> @sch_qty_uom_code
      select @nomin_qty_max_D = @nomin_qty_max_D * dbo.udf_getUomConversion(@qty_uom_code, @sch_qty_uom_code, NULL, NULL, @cmdty_code)

   /* nomin_qty_max - for physical receipts */             
   select @nomin_qty_max_R = (select sum(nomin_qty_max)    
                              from dbo.allocation_item
                              where alloc_num = @alloc_num and
                                    alloc_item_type in ('R'))
   select top 1 
      @qty_uom_code = nomin_qty_max_uom_code,
      @cmdty_code = cmdty_code
   from dbo.allocation_item
   where alloc_num = @alloc_num and
         alloc_item_type in ('R') and
         nomin_qty_max_uom_code is not null
   if @qty_uom_code <> @sch_qty_uom_code
      select @nomin_qty_max_R = @nomin_qty_max_R * dbo.udf_getUomConversion(@qty_uom_code, @sch_qty_uom_code, NULL, NULL, @cmdty_code)

   select @nomin_qty_max = @nomin_qty_max_C_T
   if @nomin_qty_max_I_N > @nomin_qty_max
      select @nomin_qty_max = @nomin_qty_max_I_N
   if @nomin_qty_max_D > @nomin_qty_max
      select @nomin_qty_max = @nomin_qty_max_D
   if @nomin_qty_max_R > @nomin_qty_max
      select @nomin_qty_max = @nomin_qty_max_R

	 return @nomin_qty_max
END
GO
GRANT EXECUTE ON  [dbo].[udf_allocation_capacity] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_allocation_capacity] TO [next_usr]
GO

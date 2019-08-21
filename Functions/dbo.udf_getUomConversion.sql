SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE function [dbo].[udf_getUomConversion]          
(             
  @fromUom       char(8),          
  @toUom         char(8),          
  @secConvFactor numeric(20, 8),          
  @secQtyUomCode char(8),          
  @cmdtyCode     char(8)          
)          
      
returns @rtnvalue table         
(        
   uom_factor     numeric(20, 8) null,         
   fromUom    char(8)null,        
   toUom         char(8) null        
)         
as          
BEGIN          
DECLARE @uom_factor    numeric(20, 8),          
      @bbl_factor    numeric(20, 8),          
      @base_value    numeric(20, 8),          
      @gal_value     numeric(20, 8),          
      @MB_value      numeric(20, 8),          
     @rows_affected int,          
    @uomConvRate   numeric(20, 8),          
    @uomOper      char(1)          
          
   -- THis is a hack, will work with peter to make it generic          
  select @bbl_factor = 1.0,          
         @base_value = 1.0,          
         @gal_value = 42.0,          
         @MB_value = 1000.0,          
         @uom_factor = @base_value,          
         @bbl_factor = @base_value          
           
   if @fromUom is not NULL OR @toUom is not NULL          
   begin          
   if @cmdtyCode is not NULL          
     begin                 
      select @uomConvRate = 1.0,           
             @uomOper = 'M'          
          
      select @uomConvRate = uom_conv_rate,           
             @uomOper = uom_conv_oper           
      from dbo.uom_conversion           
       where cmdty_code = @cmdtyCode AND           
         uom_code_conv_from = @fromUom AND          
         uom_code_conv_to = @toUom          
       select @rows_affected = @@rowcount            
      if @rows_affected > 0           
         goto calc1              
                     
      select @uomConvRate = 1.0 / uom_conv_rate,           
            @uomOper = uom_conv_oper           
          from dbo.uom_conversion           
      where cmdty_code = @cmdtyCode AND           
          uom_code_conv_from = @toUom AND          
         uom_code_conv_to = @fromUom                  
       select @rows_affected = @@rowcount            
      if @rows_affected > 0           
         goto calc1              
          
       select @uomConvRate = uom_conv_rate,           
          @uomOper = uom_conv_oper           
      from dbo.uom_conversion           
      where cmdty_code is NULL AND           
         uom_code_conv_from = @fromUom AND          
         uom_code_conv_to = @toUom          
       select @rows_affected = @@rowcount            
      if @rows_affected > 0           
         goto calc1              
          
      select @uomConvRate = 1.0 / uom_conv_rate,           
          @uomOper = uom_conv_oper           
      from dbo.uom_conversion           
      where cmdty_code is NULL AND           
         uom_code_conv_from = @toUom AND          
         uom_code_conv_to = @fromUom          
       select @rows_affected = @@rowcount     
                    
      if @rows_affected > 0           
         goto calc1              
  
             
     if @toUom = 'GAL'          
      select @uom_factor = @bbl_factor * @gal_value          
     else if @toUom = 'BBL'          
      select @uom_factor = @bbl_factor          
     else if @toUom = 'MB'          
      select @uom_factor = @bbl_factor / @MB_value          
  
      if @rows_affected > 0           
         goto calc1              
  
          
---Added new logic to get more conv rate -- added on 09/18/2013 by Subu    
   DECLARE @t1 TABLE     
   (uom_conv_num int,    
   uom_code_conv_from_start  varchar(15) null,    
   uom_code_conv_to varchar(15) null,    
   cmdty_code varchar(15) null,    
   uom_conv_rate float null,    
   uom_conv_oper char(1) null,    
   uom_code_conv_to_stop varchar(15) null,    
   cmdty_code1 varchar(15),    
   uom_conv_rate1 float null,    
   uom_conv_oper1 char(1) null,    
   final_rate float null    
   )      
            
   insert into @t1    
   SELECT uom_conv_num,uom_code_conv_from,uom_code_conv_to,cmdty_code,uom_conv_rate,uom_conv_oper,NULL,NULL,NULL,NULL,null    
   from dbo.uom_conversion           
   where isnull(cmdty_code,@cmdtyCode) = @cmdtyCode  AND             
   (uom_code_conv_from = @fromUom OR uom_code_conv_to = @fromUom )    
          
    
   update t    
   set uom_conv_rate1=uc.uom_conv_rate,    
   uom_conv_oper1=uc.uom_conv_oper,    
   uom_code_conv_to_stop=uc.uom_code_conv_to    
   from @t1 t, uom_conversion uc    
   where isnull(uc.cmdty_code,@cmdtyCode) = @cmdtyCode      
   and uc.uom_code_conv_from=t.uom_code_conv_to    
   and uc.uom_code_conv_to=@toUom    
    
   update t    
   set uom_conv_rate1=uc.uom_conv_rate,    
   uom_conv_oper1=case when uc.uom_conv_oper='M' then 'D' else 'M' end,    
   uom_code_conv_to_stop=@toUom    
   --SELECT *     
   from @t1 t, uom_conversion uc    
   where isnull(uc.cmdty_code,@cmdtyCode) = @cmdtyCode     
   and uc.uom_code_conv_from=@toUom    
   and uc.uom_code_conv_to=t.uom_code_conv_to    
    
   update t    
   set final_rate=case when uom_conv_oper='M' then uom_conv_rate else 1/uom_conv_rate end* case when uom_conv_oper1='M' then uom_conv_rate1 else 1/uom_conv_rate1  end    
   from @t1 t    
   where uom_code_conv_from_start is not null    
   and uom_code_conv_to_stop is not null    
       
   SELECT @uomConvRate=final_rate, @uomOper='M'    
   from @t1    
   where uom_code_conv_from_start is not null    
   and uom_code_conv_to_stop is not null    
    
---Added new logic to get more conv rate -- added on 09/18/2013 by Subu    
           
calc1:                 
      if @uomOper = 'D'          
        select @uom_factor = ROUND((1.0 / @uomConvRate), 7)          
      else          
        select @uom_factor = ROUND(@uomConvRate,7)          
          
      goto endoffun          
     end          
     else          
      select @bbl_factor = 1.0          
             
     if @toUom = 'GAL'          
      select @uom_factor = @bbl_factor * @gal_value          
     else if @toUom = 'BBL'          
      select @uom_factor = @bbl_factor          
     else if @toUom = 'MB'          
      select @uom_factor = @bbl_factor / @MB_value          
     else if ((@secQtyUomCode is not NULL) AND           
              (@toUom = @secQtyUomCode) AND           
              (@secConvFactor is not NULL))          
      select @uom_factor = @secConvFactor          
   end          
        
          
endoffun:         
 insert into  @rtnvalue      
 SELECT @uom_factor,@fromUom,  @toUom      
 return      
        
END       
GO
GRANT SELECT ON  [dbo].[udf_getUomConversion] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_getUomConversion] TO [next_usr]
GO

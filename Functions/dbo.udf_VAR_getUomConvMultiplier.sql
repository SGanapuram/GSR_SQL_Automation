SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_VAR_getUomConvMultiplier]  
  
(     
 @fromUom char(8),  
 @toUom    char(8),  
 @cmdtyCode char(8)  
 --@secConvFactor numeric(20, 8),  
 --@secQtyUomCode char(8)  
  
)  
  
returns float  
  
as  
  
BEGIN  
  
DECLARE  
 @uomConvRate float,  
 @uomOper  char(1)  
  
SELECT  
 @uomConvRate = NULL  
  
IF @fromUom IS NOT NULL AND @toUom IS NULL  
 SELECT @toUom = 'MT'  
  
IF @fromUom = @toUom OR @fromUom IS NULL  
 RETURN 1  
  
--- Searching for Commodity Specific UOM conversion  
IF @fromUom IS NOT NULL AND @toUom IS NOT NULL AND @cmdtyCode IS NOT NULL  
 BEGIN  
   
    /*  
    ECT TOP 1   
                case when uom_conv_rate = 0 then @uomConvRate = null else @uomConvRate = 1 end , --  (1 / uom_conv_rate) end) ,         
                @uomOper   = uom_conv_oper   
    */  
      
  SELECT TOP 1   
   @uomConvRate = (case when uom_conv_rate = 0  then  null else uom_conv_rate end),  
            @uomOper   = uom_conv_oper   
  FROM uom_conversion  
  WHERE uom_code_conv_from = @fromUom AND uom_code_conv_to = @toUom AND cmdty_code = @cmdtyCode  
  IF @uomConvRate IS NOT NULL   
   GOTO ConversionFound  
  ELSE  
   -- find the opposite  
   BEGIN  
    SELECT TOP 1   
     @uomConvRate = (case when uom_conv_rate = 0  then  null else  (1 / uom_conv_rate) end),  
     @uomOper   = uom_conv_oper   
    FROM uom_conversion  
     WHERE uom_code_conv_from = @toUom AND uom_code_conv_to = @fromUom AND cmdty_code = @cmdtyCode  
    IF @uomConvRate IS NOT NULL   
     GOTO ConversionFound  
   END  
    
 END  
  
--- Searching for General UOM conversion  
SELECT @cmdtyCode = NULL  
IF @fromUom IS NOT NULL AND @toUom IS NOT NULL AND @cmdtyCode IS NULL --OR @uomConvRate IS NULL  
 BEGIN  
  SELECT TOP 1   
   @uomConvRate = (case when uom_conv_rate = 0  then  null else  uom_conv_rate end),  
   @uomOper   = uom_conv_oper   
  FROM uom_conversion  
  WHERE uom_code_conv_from = @fromUom AND uom_code_conv_to = @toUom AND cmdty_code IS NULL  
  IF @uomConvRate IS NOT NULL   
   GOTO ConversionFound  
  ELSE  
   -- find the opposite  
   BEGIN  
    SELECT TOP 1   
     @uomConvRate = (case when uom_conv_rate = 0  then  null else  (1 / uom_conv_rate) end),  
     @uomOper   = uom_conv_oper   
    FROM uom_conversion  
     WHERE uom_code_conv_from = @toUom AND uom_code_conv_to = @fromUom AND cmdty_code IS NULL  
      
    IF @uomConvRate IS NOT NULL   
     GOTO ConversionFound  
   END  
    
 END  
  
  
--- To always return the a Multiplier  
ConversionFound:  
  
IF @uomOper = 'M'  
 select @uomConvRate = @uomConvRate  
  
ELSE IF @uomOper = 'D'  
 select @uomConvRate = 1 / @uomConvRate  
  
RETURN @uomConvRate  
END  
GO
GRANT EXECUTE ON  [dbo].[udf_VAR_getUomConvMultiplier] TO [next_usr]
GO

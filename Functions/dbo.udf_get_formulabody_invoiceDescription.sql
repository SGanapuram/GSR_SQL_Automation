SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_get_formulabody_invoiceDescription]      
(      
   @formula_num int,      
   @formula_body_num int,      
   @formula_body varchar(MAX)
)        
RETURNS VARCHAR(MAX)       
AS      
BEGIN      
Declare @frmCompVal varchar(100);      
declare @formualComp varchar(100)      
declare @replacedFormula varchar(max)      
      
      
DECLARE @Text VARCHAR(MAX)      
--SET @Text = 'Zinc: <ZnPayPct>% minimum deduction of <ZnDeduct>%/ tm at LBMA spot'      
SET @Text = @formula_body      
--Set @formualactComp = @Text;      
DECLARE fc CURSOR FOR      
SELECT formula_comp_name,formula_comp_val FROM formula_component where formula_num = @formula_num and  formula_body_num = @formula_body_num      
open fc ;      
fetch next from fc into @formualComp,@frmCompVal      
WHILE   @@FETCH_STATUS = 0         
begin      
-- select '<'+@formualComp +'>',@formualComp,@frmCompVal,@Text,@replacedFormula      
      
      
 set @replacedFormula = replace(@Text,'<'+@formualComp +'>' ,@frmCompVal);      
--select @Text,@formualactComp      
fetch next from fc into @formualComp,@frmCompVal      
if (@replacedFormula IS NOT NULL)      
set  @Text = @replacedFormula;      
--select @Text,@formualactComp      
end      
CLOSE fc;      
DEALLOCATE fc;      
RETURN @Text      
end;   
GO
GRANT EXECUTE ON  [dbo].[udf_get_formulabody_invoiceDescription] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_get_formulabody_invoiceDescription] TO [next_usr]
GO

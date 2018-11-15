SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_position_type_desc]  
(  
   @pos_type        char(1),  
   @option_type     char(1),  
   @is_hedge_ind    char(1),  
   @is_equiv_ind    char(1)  
)  
RETURNS varchar(80)  
as  
begin  
declare @tempstr   varchar(80)  
  
   set @tempstr = case when @pos_type = 'I' then 'Inv'          
                       when @pos_type = 'F' then 'Fut'          
                       when @pos_type = 'S' then 'Synth'          
                       when @pos_type = 'P' then 'Phys'          
                       when @pos_type = 'Q' and @option_type = 'S' then 'Swap Form'          
                       when @pos_type = 'Q' and @option_type is null then 'Trade Form'          
                       else @pos_type          
                  end + (case when @is_hedge_ind = 'Y' then ' Hedge'   
                               else ' Prim'   
                          end) + (case when @is_equiv_ind = 'Y' then ' Equiv'   
                                       else ''   
                                  end)         
     
   return @tempstr          
end    
GO
GRANT EXECUTE ON  [dbo].[udf_position_type_desc] TO [next_usr]
GO

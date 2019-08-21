SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_profit_centers]
(
   @user_logon_id varchar(40)
)
RETURNS @profit_centers TABLE 
(
   profit_center   varchar(32) NULL
) 
AS
BEGIN   
declare @MultiCompanyDB          char(1)

   set @MultiCompanyDB = (select attribute_value
                          from dbo.constants with (nolock)
                          where attribute_name = 'MultiCompanyDB')

                          
   if @MultiCompanyDB not in ('Y', 'N')
      set @MultiCompanyDB = 'N'
      
   if not exists (select 1
                  from dbo.function_detail fd with (nolock)
                  where function_num = (select function_num
                                        from dbo.icts_function with (nolock)
                                        where app_name = 'ICTSControl' and
                                              function_name = 'TradingEntity') )
      set @MultiCompanyDB = 'N'                                         

   if exists (select 1
              from dbo.portfolio_tag with (nolock)
              where tag_name = 'PRFTCNTR') and
      (@MultiCompanyDB = 'Y')
   begin
      insert into @profit_centers
      select distinct pt.tag_value
      from dbo.portfolio p  with (nolock), 
	         dbo.portfolio_tag pt  with (nolock)
      where pt.tag_name = 'PRFTCNTR' and 
	          pt.port_num = p.port_num and 
            exists (select 1
                    from dbo.v_user_trading_entity_map usr 
                    where isnull(p.trading_entity_num, 0) = usr.trading_entity_num and 
	                 	      usr.user_logon_id = @user_logon_id)                                                  
   end
   else
   begin    
      insert into @profit_centers
      select distinct pt.tag_value
      from dbo.portfolio p  with (nolock), 
	         dbo.portfolio_tag pt  with (nolock)
      where pt.tag_name = 'PRFTCNTR' and
            len(rtrim(pt.tag_value)) > 0 
   end
   RETURN;
END;
GO
GRANT SELECT ON  [dbo].[udf_profit_centers] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_profit_centers] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[udf_profit_centers] TO [public]
GO

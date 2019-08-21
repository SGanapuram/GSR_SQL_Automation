SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_trading_entities]
(
   @user_logon_id varchar(40)
)
RETURNS @trading_entities TABLE 
(
   acct_full_name   nvarchar(255) NULL
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

   if (@MultiCompanyDB = 'Y')
   begin
      insert into @trading_entities
      select acct_full_name
      from dbo.account b  with (nolock)
      where exists (select 1
                    from dbo.v_user_trading_entity_map usr, 
	                       dbo.portfolio p  with (nolock)
                    where b.acct_num = usr.trading_entity_num and
	                        isnull(p.trading_entity_num, 0) = usr.trading_entity_num and 
	                 	      usr.user_logon_id = @user_logon_id)                                                  
   end
   RETURN;
END;
GO
GRANT SELECT ON  [dbo].[udf_trading_entities] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_trading_entities] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[udf_trading_entities] TO [public]
GO

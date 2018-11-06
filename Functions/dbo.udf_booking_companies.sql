SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[udf_booking_companies]
(
   @user_logon_id varchar(40)
)
RETURNS @booking_company_names TABLE 
(
   acct_short_name   nvarchar(15) NOT NULL
) 
AS
BEGIN 
declare @MultiCompanyDB          char(1),
        @xml                     xml,
        @popular_bookcomp_list   varchar(800)
        
   set @popular_bookcomp_list = ''
   select @popular_bookcomp_list = rtrim(config_value)
   from dbo.dashboard_configuration with (nolock)
   where config_name = 'PopularBookingComapnies'

   if len(@popular_bookcomp_list) > 0
      set @xml = cast(('<X>' + replace(@popular_bookcomp_list, ',','</X><X>')+'</X>') as xml)


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
              where tag_name = 'BOOKCOMP') and
      (@MultiCompanyDB = 'Y')
   begin
   	  if len(@popular_bookcomp_list) > 0
   	  begin 
         insert into @booking_company_names
         select acct_short_name
         from dbo.account b with (nolock)
         where exists (select 1
                       from dbo.v_user_trading_entity_map usr, 
	                          dbo.portfolio p with (nolock), 
	                          dbo.portfolio_tag pt with (nolock)
                       where b.acct_num = pt.tag_value and
	                           pt.tag_name = 'BOOKCOMP' and 
	                           pt.port_num = p.port_num and 
	                           isnull(p.trading_entity_num, 0) = usr.trading_entity_num and 
	                 	         usr.user_logon_id = @user_logon_id) and 
               b.acct_num in (select cast(value as int)
                              from (select N.value('.', 'varchar(10)') as value 
                                    from @xml.nodes('X') as T(N)) a)    
      end
      else
      begin
         insert into @booking_company_names
         select acct_short_name
         from dbo.account b with (nolock)
         where exists (select 1
                       from dbo.v_user_trading_entity_map usr, 
	                          dbo.portfolio p with (nolock), 
	                          dbo.portfolio_tag pt with (nolock)
                       where b.acct_num = pt.tag_value and
	                           pt.tag_name = 'BOOKCOMP' and 
	                           pt.port_num = p.port_num and 
	                           isnull(p.trading_entity_num, 0) = usr.trading_entity_num and 
	                 	         usr.user_logon_id = @user_logon_id) and 
               b.acct_num in (select acct_num
                              from dbo.account with (nolock)
                              where acct_type_code = 'PEICOMP' and
                                    acct_status = 'A')
      end                                              
   end
   else
   begin    
   	  if len(@popular_bookcomp_list) > 0
   	  begin 
         insert into @booking_company_names
         select acct_short_name
         from dbo.account b with (nolock)
         where exists (select 1
                       from dbo.portfolio p with (nolock), 
	                          dbo.portfolio_tag pt with (nolock)
                       where b.acct_num = pt.tag_value and
	                           pt.tag_name = 'BOOKCOMP') and 
               b.acct_num in (select cast(value as int)
                              from (select N.value('.', 'varchar(10)') as value 
                                    from @xml.nodes('X') as T(N)) a)
      end
      else
      begin
         insert into @booking_company_names
         select acct_short_name
         from dbo.account b with (nolock)
         where exists (select 1
                       from dbo.portfolio p with (nolock), 
	                          dbo.portfolio_tag pt with (nolock)
                       where b.acct_num = pt.tag_value and
	                           pt.tag_name = 'BOOKCOMP') and 
               b.acct_num in (select acct_num
                              from dbo.account with (nolock)
                              where acct_type_code = 'PEICOMP' and
                                    acct_status = 'A')
      end                                                 
   end
   RETURN;
END;
GO
GRANT SELECT ON  [dbo].[udf_booking_companies] TO [public]
GO

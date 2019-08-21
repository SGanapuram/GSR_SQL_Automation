SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_get_portfolio]      
(    
    @my_user_logon_id char(20) = null    
)    
returns @result table    
 (    
    port_num VARCHAR(50),  
    port_short_name VARCHAR(100)   
 )    
as    
begin    
 declare @my_is_superuser char(1)     
 declare @smsg varchar(255)     
 declare @status int     
 declare @errcode int     
 declare @trading_entity table    
 (    
    trading_account varchar(40) null    
 )    
     
 set @my_is_superuser='N'     
 set @status = 0     
 set @errcode = 0    
      
     
 insert into @trading_entity     
 select fdv.attr_value from icts_user_permission iup, function_detail_value fdv, function_detail fd, icts_function icf     
 where     
  iup.fdv_id = fdv.fdv_id And     
  fdv.fd_id = fd.fd_id And     
  fd.function_num = icf.function_num and     
  icf.app_name = 'ICTSControl' and     
  icf.function_name = 'TradingEntity' and     
  iup.user_init =(select user_init from icts_user where user_logon_id = @my_user_logon_id)     
    
 if exists (select 1 from @trading_entity where trading_account='ANY')     
 begin     
  set @my_is_superuser='Y'     
 End           
     
 if @my_is_superuser ='Y'     
  insert into @result select port_num,port_short_name from portfolio where port_type='R' and port_num <> 0     
 else    
 begin    
  insert into @result select port_num,port_short_name from portfolio where port_type='R' and port_num <> 0 and     
  (trading_entity_num in (select cast (trading_account as int) from @trading_entity) or trading_entity_num is null)    
    end     
        
 /*if @my_is_superuser ='Y'     
  insert into @result select TOP 100 convert(VARCHAR(10),port_num) + '  ' + port_short_name from portfolio where port_type='R' and port_num <> 0     
 else    
 begin    
  insert into @result select  TOP 100 convert(VARCHAR(10),port_num) + '  ' + port_short_name from portfolio where port_type='R' and port_num <> 0 and     
  (trading_entity_num in (select cast (trading_account as int) from @trading_entity) or trading_entity_num is null)    
    end  */    
      
/*    
 if @my_is_superuser ='N'     
 begin     
  Delete t1 from @result t1     
  WHERE not exists     
  (    
   select 1 from portfolio p where t1.port_num=p.port_num and      
   (trading_entity_num in (select cast (trading_account as int) from @trading_entity) or trading_entity_num is null)    
  )     
  or port_num=0    
 End     
*/    
    
 RETURN    
END    
GO
GRANT SELECT ON  [dbo].[udf_get_portfolio] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_get_portfolio] TO [next_usr]
GO

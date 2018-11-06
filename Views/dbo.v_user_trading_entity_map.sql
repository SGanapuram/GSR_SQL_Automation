SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 
CREATE view [dbo].[v_user_trading_entity_map]  
(  
   user_init,  
   user_logon_id,  
   trading_entity_num,   
   trading_entity_name,  
   trading_entity_full_name,  
   trans_id  
)  
as  
select u.user_init,
       u.user_logon_id, 
       a.acct_num,
       a.acct_short_name,
       a.acct_full_name,
       fdv.trans_id
from dbo.icts_user u with (nolock),
     dbo.icts_user_permission up with (nolock),
     dbo.function_detail_value fdv with (nolock)
        inner join dbo.account a with (nolock)
           on a.acct_type_code = 'TRDNGNTT' and
              cast(a.acct_num as varchar) = fdv.attr_value
where u.user_status = 'A' and
      u.user_init = up.user_init and
      up.fdv_id = fdv.fdv_id and
      fdv.attr_value not in ('ANY', 'DEPT', 'OWN') and
      fdv.fd_id in (select fd_id
                    from dbo.function_detail fd with (nolock)
                    where fd.entity_name = 'TradingEntity' and
                          fd.attr_name = 'acctNum' and
                          function_num in (select function_num
                                           from dbo.icts_function with (nolock)
                                           where app_name = 'ICTSControl' and
                                                 function_name = 'TradingEntity'))
GO
GRANT SELECT ON  [dbo].[v_user_trading_entity_map] TO [next_usr]
GO

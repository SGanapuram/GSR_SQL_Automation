SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_MDS_user_entity_map]  
(  
user_init,  
user_logon_id,  
BookEntityNum,   
BookEntityName,  
trans_id  
)  
as  
  
select iup.user_init,user_logon_id,A.acct_num , A.acct_short_name,fdv.trans_id  
from dbo.icts_user_permission iup, dbo.icts_user iu,  
dbo.function_detail fd,   
dbo.icts_function icf ,  
dbo.function_detail_value fdv   
INNER JOIN dbo.account A ON A.acct_type_code='TRDNGNTT' and (Convert(varchar(15),A.acct_num) = convert(varchar(15),fdv.attr_value)  or attr_value='ANY')  
where iup.fdv_id = fdv.fdv_id and fdv.fd_id = fd.fd_id and fd.function_num = icf.function_num   
and icf.app_name = 'ICTSControl' and icf.function_name = 'TradingEntity'   
and iup.user_init = iu.user_init   
and user_status='A'  
--and (iu.user_job_title in ('MIDDLE OFFICER','RISK ANALYST','TRADER','RISK CONTROL') OR iu.user_init in ('MRS','ALI'))  


GO
GRANT SELECT ON  [dbo].[v_MDS_user_entity_map] TO [next_usr]
GO

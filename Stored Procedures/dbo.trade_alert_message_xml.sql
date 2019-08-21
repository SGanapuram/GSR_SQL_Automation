SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[trade_alert_message_xml]
( 
   @ticket int    
)       
as    
begin  
set nocount on
  
declare @audit_type_code char(8), 
        @cdty_grp_code char(8), 
        @cdty_code char(8),   
	      @booking_company_short_name varchar(15), 
	      @cpty_short_name varchar(15),   
	      @broker_short_name varchar(15), 
	      @trade_dt datetime, 
	      @trade_type_code char(8),   
	      @inst_code char(8), 
	      @trade_stat_code char(8),   
	      @trans_id bigint, 
	      @trade_trans_id bigint, 
	      @record_count int, 
	      @trade_mod_name varchar(100)
		
declare @xml as xml
declare @xml_val varchar(max)
   
	 select @trans_id = null   
	 select @trade_trans_id = null   
	 select @trans_id = max(trans_id) 
	 from dbo.icts_transaction 
	 where tran_date <= GetDate()   
	 select @trade_trans_id = trans_id 
	 from dbo.trade 
	 where trade_num = @ticket   

   /*   
	 if (@trans_id is not null and @trade_trans_id is not null)   
	 begin   
		  if (@trade_trans_id <= @trans_id)   
		  begin      
		  end   
		  else   
		  begin   
			   select @trade_trans_id = null   
			   select @trade_trans_id = max(trans_id) 
			   from dbo.aud_trade 
			   where trans_id <= @trans_id   
		  end   
	 end	*/   
   
	 select @record_count = count(distinct cmdty_code) 
	 from dbo.trade_item   
	 where trade_num = @ticket   
	 if (@record_count > 1)   
		  select @cdty_code = 'VARIOUS'   
	 else   
	 begin   
		  select @cdty_code = cmdty_code 
		  from dbo.trade_item 
		  where trade_num = @ticket  
		 
		  select @cdty_grp_code = parent_cmdty_code 
		  from dbo.commodity_group   
		  where cmdty_code = @cdty_code   
	 end   
   
	 select @record_count = count(distinct booking_comp_num) 
	 from dbo.trade_item   
	 where trade_num = @ticket   
	 if (@record_count > 1)   
		  select @booking_company_short_name = 'VARIOUS'   
	 else   
	 begin   
		  select @booking_company_short_name = acct_short_name   
		  from dbo.trade_item i, 
		       dbo.account a   
		  where i.trade_num = @ticket and 
		        i.booking_comp_num = a.acct_num   
	 end   
	
	 select @cpty_short_name = a.acct_short_name, 
	        @trade_dt = t.contr_date,  
	        --@trade_dt = CONVERT(VARCHAR(10), t.contr_date, 101) as [MM/DD/YYYY],
	        @trade_stat_code = t.trade_status_code 
	 from dbo.trade t, 
	      dbo.account a
	 where t.trade_num = @ticket and 
	       t.acct_num = a.acct_num
   
	 select @record_count = count(distinct brkr_num) 
	 from dbo.trade_item 
	 where trade_num = @ticket   
	 if (@record_count > 1)   
		  select @broker_short_name = 'VARIOUS'   
   else   
	 begin   
		  select @broker_short_name = acct_short_name   
		  from trade_item i, account a   
		  where i.trade_num = @ticket and 
		        i.brkr_num = a.acct_num   
	 end   
   
	 select @record_count = count(*) 
	 from dbo.aud_trade 
	 where trade_num = @ticket   
	 if (@record_count = 0)   
		  select @audit_type_code = 'NEW'   
	 else   
	 begin   
		  if @trade_stat_code = 'DELETE'   
			   select @audit_type_code = 'VOID'   
		  else   
			   select @audit_type_code = 'CORRECT'   
	 end   
   
	 if (@cpty_short_name is not null)   
		  select @trade_type_code = 'OTC'   
	 else   
		  select @trade_type_code = 'EXCHANGE'   
   
	 select @record_count = count(distinct order_type_code) 
	 from dbo.trade_order 
	 where trade_num = @ticket   
	 if (@record_count > 1)   
		  select @inst_code = 'VARIOUS'   
	 else   
	 begin   
		  select @inst_code = order_type_code   
		  from dbo.trade_order   
		  where trade_num = @ticket   
	 end   
    
   select @trade_mod_name = user_first_name + ' ' + user_last_name 
   from dbo.trade t, 
        dbo.icts_user iu 
   where t.trade_mod_init = iu.user_init and 
         trade_num = @ticket
    
   set @xml_val = (select (select rtrim(@audit_type_code) as '*' for xml path ('')) as audit_type_code,   
		                      (select rtrim(@cdty_grp_code) as '*' for xml path ('')) as cdty_grp_code,   
		                      (select rtrim(@cdty_code) as '*' for xml path ('')) as cdty_code,   
		                      (select rtrim(@booking_company_short_name) as '*' for xml path ('')) as booking_company_short_name,   
                          (select rtrim(@cpty_short_name) as '*' for xml path ('')) as cpty_short_name,   
                          (select rtrim(@broker_short_name) as '*' for xml path ('')) as broker_short_name,   
                          (select rtrim(convert(char(10), @trade_dt,120)) as '*' for xml path ('')) as trade_dt,   
                          (select rtrim(@trade_type_code) as '*' for xml path ('')) as trade_type_code,   
                          (select rtrim(@inst_code) as '*' for xml path ('')) as inst_code,   
                          (select rtrim(@trade_stat_code) as '*' for xml path ('')) as trade_stat_code,
                          (select rtrim(@trade_mod_name) as '*' for xml path ('')) as trade_mode_name 
                             for xml path ('TradeAlertData'))

   select @xml_val as XML_VAL
end
GO
GRANT EXECUTE ON  [dbo].[trade_alert_message_xml] TO [next_usr]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_add_DUMMY_account_data]
(
   @acct_num         int output
)
as
set nocount on
set xact_abort on
declare @trans_id            int,
        @rows_affected       int,
        @temp_acct_num       int,
        @country_code        char(8),
        @cr_country_code     char(8),
        @dflt_cr_anly_init   char(3),
        @status              int

   set @status = 0
   set @acct_num = null 
   
   set @acct_num = (select acct_num                            
                    from dbo.account
                    where acct_short_name = 'DUMMY CPARTY' and
                          acct_type_code = 'CUSTOMER')
   if @acct_num is not null
      goto endofsp
      
   begin try
     exec dbo.gen_new_transaction_NOI @app_name = 'adddummyacct_1337466'
   end try
   begin catch
     print '=> Failed to execute the ''gen_new_transaction_NOI'' stored procedure to create an icts_transaction record due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch
  
   select @trans_id = last_num 
   from dbo.icts_trans_sequence
   where oid = 1

   if @trans_id is null
   begin
      print '=> Unable to obtain a valid trans_id for insertion!'
      goto errexit
   end

   select @temp_acct_num = (select top 1 acct_num
                            from dbo.account
                            where acct_type_code = 'CUSTOMER' and
                                  acct_status = 'A')
   
   /* Get a default country_code to be used. This country code 
      will be used in adding account_address record */
   -- Find out if the country_code 'UNKNOWN' is available                    
   select @country_code = country_code
   from dbo.country
   where country_code = 'UNKNOWN'

   if @country_code is null
   begin
      set @country_code = (select top 1 country_code 
                           from dbo.account_address 
                           where acct_num = @temp_acct_num)
   end

   /* Get a default dflt_cr_anly_init and country_code to be used 
      in adding account_credit_info record */
   set @dflt_cr_anly_init = (select dflt_cr_anly_init
                             from dbo.account_credit_info
                             where acct_num = @temp_acct_num)

   set @cr_country_code = (select country_code
                           from dbo.account_credit_info
                           where acct_num = @temp_acct_num)

   if @cr_country_code is null
      set @cr_country_code = @country_code

   if @dflt_cr_anly_init is null
      set @dflt_cr_anly_init = (select user_init
                                from dbo.icts_user
                                where user_logon_id = 'ictsanalyst')
                             
   if @dflt_cr_anly_init is null
      set @dflt_cr_anly_init = (select top 1 user_init
                                from dbo.icts_user
                                where user_logon_id in ('ictspass', 'ictssrvr', 'icts_user'))

   
   begin tran
   select @acct_num = max(acct_num)
   from dbo.account
   
   if @acct_num is null
      set @acct_num = 0
      
   set @acct_num = @acct_num + 1
   begin try
     insert into dbo.account 
          (acct_num, acct_short_name, acct_full_name, acct_status,
           acct_type_code, acct_parent_ind, acct_sub_ind, trans_id)
        values(@acct_num, 'DUMMY CPARTY', 'DUMMY COUNTERPARTY', 'A', 'CUSTOMER', 'N', 'N', @trans_id)
     select @rows_affected = @@rowcount
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add DUMMY account record due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch
   if @rows_affected > 0
      print '=> DUMMY account record was added successfuly!'
   else
      print '=> DUMMY account record was NOT added ????'
 
   begin try
     insert into dbo.account_address 
          (acct_num, acct_addr_num, acct_addr_line_1, acct_addr_city,
           country_code, acct_addr_status, trans_id)
        values(@acct_num, 1, 'DEFAULT', 'DEFAULT', @country_code, 'A', @trans_id)
     select @rows_affected = @@rowcount
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add an account_address record for DUMMY account due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch
   if @rows_affected > 0
      print '=> A new account_address record for the DUMMY account was added successfuly!'
   else
      print '=> No account_address record for the DUMMY account was added ????'
   
   begin try
     insert into dbo.account_contact 
            (acct_num,
             acct_cont_num,
             acct_cont_last_name,
             acct_cont_first_name,
             acct_cont_status,
             trans_id)
          values(@acct_num, 1, 'DEFAULT', 'DEFAULT', 'A', @trans_id)
        select @rows_affected = @@rowcount
      end try
      begin catch
        if @@trancount > 0
           rollback tran
        print '=> Failed to add an account_contact record for DUMMY account due to the error:'
        print '==> ERROR: ' + ERROR_MESSAGE()
        goto errexit
      end catch       
      if @rows_affected > 0
         print '=> A new account_contact record for the DUMMY account was added successfuly!'
      else
         print '=> No account_contact record for the DUMMY account was added ????'

      begin try
        insert into dbo.account_credit_info 
          (acct_num,
           cr_status,
           dflt_cr_anly_init,
           acct_bus_desc,
           first_trade_date,
           doing_bus_since_date,
           fiscal_year_end_date,
           last_fin_doc_date,
           invoice_date,
           dflt_telex_hold_ind,
           bus_restriction_type,
           dflt_cr_term_code,
           country_code,
           exposure_priority_code,
           trans_id,
           use_dflt_cr_info)
         values(@acct_num,                   /* acct_num */
                'A',                         /* cr_status */
                @dflt_cr_anly_init,          
                'DFLT',                      /* acct_bus_desc */
                'Jan  1 1900 12:00:00',      /* first_trade_date */
                'Jan  1 1900 12:00:00',      /* doing_bus_since_date */
                'Jan  1 1900 12:00:00',      /* fiscal_year_end_date */
                'Jan  1 1900 12:00:00',      /* last_fin_doc_date */
                'Jan  1 1900 12:00:00',      /* invoice_date */
                'Y',                         /* dflt_telex_hold_ind */
                'U',                         /* bus_restriction_type */
                'OPEN',                      /* dflt_cr_term_code */
                @cr_country_code,
                'R',                         /* exposure_priority_code */
                @trans_id,
                'N')                         /* use_dflt_cr_info */
        select @rows_affected = @@rowcount
      end try
      begin catch
        if @@trancount > 0
           rollback tran
        print '=> Failed to add an account_credit_info record for DUMMY account due to the error:'
        print '==> ERROR: ' + ERROR_MESSAGE()
        goto errexit
      end catch       
      if @rows_affected > 0
         print '=> A new account_credit_info record for the DUMMY account was added successfuly!'
      else
         print '=> No account_credit_info record for the DUMMY account was added ????'

      begin try
        insert into dbo.account_ext_info  
             (acct_num, trans_id)
           values(@acct_num, @trans_id)
        select @rows_affected = @@rowcount
      end try
      begin catch
        if @@trancount > 0
           rollback tran
        print '=> Failed to add an account_ext_info record for DUMMY account due to the error:'
        print '==> ERROR: ' + ERROR_MESSAGE()
        goto errexit
      end catch       
      if @rows_affected > 0
         print '=> A new account_ext_info record for the DUMMY account was added successfuly!'
      else
         print '=> No account_ext_info record for the DUMMY account was added ????'
      commit tran      
   goto endofsp
  
errexit:
   set @status = 1

endofsp:
exec dbo.refresh_a_last_num 'account', 'acct_num'
return @status  
GO
GRANT EXECUTE ON  [dbo].[usp_add_DUMMY_account_data] TO [next_usr]
GO

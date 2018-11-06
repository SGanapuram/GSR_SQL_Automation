SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_create_bulk_voucher_vouchercost]    
(               
   @voucher_num    int = null,
   @voucher_type   char(1),        
   @user_init      char(3),        
   @workstation_id varchar(20)= null 
)       
as                      
begin          
set nocount on                      
set xact_abort on                
declare @transId             int,                  
        @status              int,                  
        @allocNum            int,                      
        @aCostNum            int,                      
        @acctNum             int,                      
        --@voucher_num       int,  
        @costNum             int,    
        @otrans_id           int,  
        @maxCount            int,                      
        @recAcctNum          int,                      
        @recAcctInstrNum     int,                      
        @recAcctBankId       int,                      
        @count               int,                      
        @totalPayable        real,                      
        @totalReceivable     real,                      
        @totalVoucherAmount  real,                      
        @rPayMethodCode      char(8),                      
        @voucherPayRecInd    char(1),   
        @vouch_flag          int,  
        @vouch_tran          int,  
        @voucherNum_flag     int,  
        @rows_affected       int,
        @voucher_type_code	 char(8)                      
                      
   if object_id('tempdb..#tempcosts', 'U') is not null                      
   begin                     
      if object_id('tempdb..#temp_costs', 'U') is not null                      
         exec('drop table #temp_costs')                      
                         
      create table #temp_costs 
      (
         ID               int IDENTITY(1,1), 
         cost_num         int, 
         cost_pay_rec_ind varchar(1),
         cost_amt         float, 
         trans_id         int
      )                      
                    
      select @rows_affected = 0             
      insert into #temp_costs(cost_num, cost_pay_rec_ind, cost_amt, trans_id)                      
        select c.cost_num,c.cost_pay_rec_ind,c.cost_amt, tc.trans_id 
        from dbo.cost c 
                inner join dbo.#tempcosts tc                    
                   on c.cost_num = tc.cost_num               
      select @rows_affected = @@rowcount                      
      if @rows_affected > 0                      
         print '=> ' + cast(@rows_affected as varchar) + ' were added into the #temp_costs'                      
      else                      
      begin                      
         print '=> No records were added into the #temp_costs'                      
         goto endofsp                      
      end                    
                      
      -- selecting one cost using the search criteria                      
                      
      select TOP 1 @aCostNum = cost_num                      
      from dbo.#temp_costs  c                       
                      
      if @aCostNum is not null                      
         print '=> The first cost_num for the search criteria = ' + cast(@aCostNum as varchar)                      
      else                      
      begin                      
         print '=> The first cost_num for the search criteria = NULL'                      
         print ''                      
         print '=> A voucher already exists for the cost(s)'                      
         print ''                      
         goto endofsp                      
      end                      
                      
      SELECT @recAcctNum = acct_num, @rPayMethodCode = pay_method_code                      
      FROM dbo.cost WHERE cost_num = @aCostNum                      
                      
 if @recAcctNum is not null                      
  print '=> @recAcctNum     = ' + cast(@recAcctNum as varchar)                      
 else                      
  print '=> @recAcctNum     = NULL'                      
                      
 if @rPayMethodCode is not null                      
  print '=> @rPayMethodCode = ' + @rPayMethodCode                      
 else                      
  print '=> @rPayMethodCode = NULL'                      
                      
                      
 SELECT @recAcctInstrNum = acct_instr_num                      
  FROM dbo.account_instruction                      
  WHERE acct_num = @recAcctNum and acct_instr_type_code = 'INVOICE'                      
                      
 if @recAcctInstrNum is not null                      
  print '=> @recAcctInstrNum = ' + cast(@recAcctInstrNum as varchar)                    
 else                      
  print '=> @recAcctInstrNum = NULL'                      
                      
 SELECT @recAcctBankId = acct_bank_id                      
  FROM dbo.account_bank_info                      
   WHERE acct_num = @recAcctNum and pay_method_code = @rPayMethodCode and p_or_r_ind = 'R'                      
                      
 if @recAcctBankId is not null                      
  print '=> @recAcctBankId = ' + cast(@recAcctBankId as varchar)                      
 else                      
  print '=> @recAcctBankId = NULL'                      
                      
begin tran          
   exec dbo.get_new_num_NOI 'trans_id', 0          
         
 select @transId = last_num        
         from dbo.icts_trans_sequence where oid = 1        
                 
     if @transId is null        
  begin        
  print '=> Unable to get new trans_id from icts_trans_sequence table'        
   goto endofsp         
  end        
                   
      insert into dbo.icts_transaction           
           (trans_id, type, user_init, tran_date, app_name, app_revision, spid, workstation_id)          
      values(@transId, 'E', @user_init, getdate(), 'Bulk_Vouching_SP', NULL, @@spid, @workstation_id)        
      select @rows_affected = @@rowcount         
if (@rows_affected > 0)          
begin          
 commit tran         
end        
else         
begin        
 rollback tran          
 print 'failed to create a new icts_transaction record.'         
 print ERROR_MESSAGE()           
   goto endofsp         
end        
  
select @voucherNum_flag = isnull(@voucher_num,0)  
  
if @voucher_num is null   
begin  
 select @vouch_flag = 1   
   
end  
else  
begin  
 select @vouch_flag = 0   
end  
  
if @voucher_type = 'F'
begin
	select @voucher_type_code = 'FINAL'
end
else  
begin  
	select @voucher_type_code = 'PRELIMIN'   
end  
	
select @vouch_tran = 0  
  
 EXEC dbo.get_new_num_NOI @key_name = 'voucher_num'                      
                      
-- Inserting the new voucher                      
                     
 select @rows_affected = 0                      
                      
  begin tran                      
 begin try                   
                
  if @voucher_num is null                
  begin                
                
   SELECT @voucher_num = last_num                      
   FROM dbo.new_num                      
   WHERE num_col_name = 'voucher_num'                  
  
      print '=> Adding a new voucher record with the voucher #' + cast(@voucher_num as varchar)                
    
   INSERT INTO dbo.voucher                      
   (                      
   [voucher_num],                      
   [voucher_status],                      
   [voucher_type_code],                      
   [voucher_cat_code],                      
   [voucher_pay_recv_ind],                      
   [acct_num],                      
   [acct_instr_num],             
   [voucher_tot_amt],                      
   [voucher_curr_code],                      
   [credit_term_code],                      
   [pay_method_code],                      
   [pay_term_code],                      
   [voucher_pay_days],                      
   [voch_tot_paid_amt],                      
   [voucher_creation_date],                      
   [voucher_creator_init],                      
   [voucher_auth_reqd_ind],                      
   [voucher_auth_date],                      
   [voucher_auth_init],                      
   [voucher_eff_date],                      
   [voucher_print_date],                      
   [voucher_send_to_cust_date],                      
   [voucher_book_date],                      
   [voucher_mod_date],                      
   [voucher_mod_init],                      
   [voucher_writeoff_init],                      
   [voucher_writeoff_date],                      
   [voucher_cust_inv_amt],                      
   [voucher_cust_inv_date],                      
   [voucher_short_cmnt],                    
   [cmnt_num],                      
   [voucher_book_comp_num],                      
   [voucher_book_curr_code],                      
   [voucher_book_exch_rate],                      
   [voucher_xrate_conv_ind],                      
   [voucher_loi_num],                      
   [voucher_arap_acct_code],                      
   [voucher_send_to_arap_date],                      
   [voucher_cust_ref_num],                      
   [voucher_book_prd_date],                      
   [voucher_paid_date],                      
   [voucher_due_date],                      
   [voucher_acct_name],                      
   [voucher_book_comp_name],                      
   [cash_date],                      
   [trans_id],                      
   [ref_voucher_num],                      
   [custom_voucher_string],                      
   [voucher_reversal_ind],                      
   [voucher_hold_ind],                      
   [max_line_num],                      
   [book_comp_acct_bank_id],                      
   [cp_acct_bank_id],                      
   [voucher_inv_curr_code],                      
   [voucher_inv_exch_rate],                      
   [invoice_exch_rate_comment],                      
   [cust_inv_recv_date],                      
   [cust_inv_type_ind],                      
   [special_bank_instr],                      
   [revised_book_comp_bank_id],                      
   [voucher_expected_pay_date],                      
   [external_ref_key],                      
   [cpty_inv_curr_code],                      
   [voucher_approval_date],                      
   [voucher_approval_init]                      
   )                      
   SELECT @voucher_num,                       
   'B',                       
   @voucher_type_code,                       
   NULL,                       
   NULL,--@voucherPayRecInd,                       
   acct_num,                       
   @recAcctInstrNum,                       
   NULL,--@totalVoucherAmount,                       
   cost_price_curr_code,                      
   credit_term_code,                       
   @rPayMethodCode,                       
   pay_term_code,                       
   cost_pay_days,                       
   NULL,                       
   getDate(),                       
   @user_init,--'ICT',                       
   NULL,                       
   NULL,                       
   NULL,                       
   cost_eff_date,                       
   NULL,                       
   NULL,                       
   NULL,                       
   NULL,                       
   @user_init,--'ICT',                       
   NULL,                       
   NULL,                       
   NULL,                       
   NULL,                  
   NULL,                       
   NULL,                       
   cost_book_comp_num,                       
   cost_book_curr_code,                       
   cost_book_exch_rate,                       
   cost_xrate_conv_ind,                       
   NULL,                       
   NULL,                       
   NULL,                       
   NULL,--@voucher_num,                      
   cost_book_prd_date,                       
   NULL,                       
   cost_due_date,                       
   NULL,                       
   NULL,                       
   NULL,                      
   @transId,                       
   @voucher_num,                       
   NULL,                       
   'N',                       
   'N',                       
   1,                       
   @recAcctBankId,                       
   NULL,                       
   NULL,                       
   NULL,                       
   NULL,                       
   NULL,                       
   'O',                       
   NULL,                       
   NULL,                       
   cost_due_date,                       
   NULL,                       
   cost_price_curr_code,                       
   NULL,                       
   NULL                       
   FROM dbo.cost                       
   WHERE cost_num = @aCostNum                      
    select @rows_affected = @@rowcount                
  end  
  else  
  begin  
	select @voucher_type_code = voucher_type_code 
	from dbo.voucher 
	where voucher_num = @voucher_num
	
   update dbo.voucher  
   set voucher_status='B',  
   trans_id = @transId  
   where voucher_num = @voucher_num  
    select @rows_affected = @@rowcount  
  end   
 end try                      
 begin catch                      
     --if @rows_affected > 0                      
       rollback tran   
  select @vouch_tran = 1  
  print '=> Failed to Insert\Updated record into voucher table due to below error '                      
  print ERROR_MESSAGE()           
 goto endofsp                     
 end catch    
                     
 if @rows_affected > 0                      
  print '=> ' + convert(varchar, @rows_affected) + ' Rows inserted into voucher table '                      
                      
 SET @count = 1                      
                      
SELECT @maxCount = max(ID)                       
FROM #temp_costs                      
                      
WHILE (@count <= @maxCount)                      
BEGIN                      
                        
   SELECT @costNum = cost_num, @otrans_id = trans_id                        
   FROM #temp_costs                       
   WHERE ID = @count                         
                         
   -- inserting voucher cost for each cost                      
                         
   select @rows_affected = 0                       
                      
   begin try                      
    INSERT INTO dbo.voucher_cost(voucher_num, cost_num, prov_price, prov_price_curr_code, prov_qty, prov_qty_uom_code,   
    prov_amt, trans_id, line_num, voucher_cost_status)                       
    SELECT @voucher_num, @costNum, NULL, NULL, NULL, NULL, NULL, @transId, @count,'ADD_Scheduled'                      
    select @rows_affected = @@rowcount                      
   end try                      
   begin catch                      
        --if @rows_affected > 0                      
   rollback tran     
  select @vouch_tran = 1  
  print '=> Failed to insert a new record into voucher_cost table with cost_num ' + convert(varchar, @costNum )                      
  print ERROR_MESSAGE()              
   goto endofsp                  
   end catch                      
   if @rows_affected > 0                      
        print '=> Inserted a new record into voucher_cost table with cost_num ' + convert(varchar, @costNum )                      
                      
   -- updating each cost                      
                         
   select @rows_affected = 0                       
 
if @voucher_type_code = 'FINAL'
begin

   begin try                      
   UPDATE dbo.cost                      
   SET cost_status = 'VOUCHED',                      
        trans_id = @transId                    
   WHERE cost_num = @costNum and trans_id = @otrans_id                    
   select @rows_affected = @@rowcount    
     
   if @rows_affected = 0    
   begin    
   rollback tran     
      select @vouch_tran = 1  
      print 'Missmatch trans_id '+ convert(varchar, @otrans_id) + 'for cost_num' + convert(varchar, @costNum)    
      print 'Creation of voucher cost is rollbacked'    
         --select @voucher_num   
    goto endofsp    
   end   
  
   end try                      
   begin catch                      
      --if @rows_affected > 0          
   rollback tran   
        select @vouch_tran = 1   
   print '=> Failed to update cost record for cost_num ' + convert(varchar, @costNum )                      
          print ERROR_MESSAGE()             
   goto endofsp                   
   end catch    
                       
   if @rows_affected > 0                      
        print '=> Updated cost.cost_status with VOUCHED for cost_num ' + convert(varchar, @costNum )                      
                      
   -- updating cost ext info for each cost                      
                      
   select @rows_affected = 0                      
                      
   begin try                      
   UPDATE dbo.cost_ext_info                      
   SET orig_voucher_num = @voucher_num,                      
        trans_id = @transId                      
   WHERE cost_num = @costNum                    
   select @rows_affected = @@rowcount                      
   end try                      
   begin catch                      
      --if @rows_affected > 0                      
   rollback tran    
        select @vouch_tran = 1  
         print '=> Failed to update cost_ext_info record for cost_num ' + convert(varchar, @costNum )                      
         print ERROR_MESSAGE()           
   goto endofsp                     
   end catch  
   if @rows_affected > 0                      
        print '=> Updated cost_ext_info.orig_voucher_num for cost_num ' + convert(varchar, @costNum )                       
   
end
                   
   print ''                      
   SET @count = @count + 1                      
END                      
  
commit tran  
end   
  
endofsp:                      
  
select @rows_affected = 0  
  
if (isnull(@vouch_tran, 0) = 1 and isnull(@vouch_flag, 0) = 1)  
begin  
    begin tran  
    begin try  
 update dbo.new_num  
 set last_num = @voucher_num-1                     
 where num_col_name = 'voucher_num' and last_num = @voucher_num  
 select @rows_affected = @@rowcount  
    end try                      
    begin catch                      
 --if @rows_affected > 0                      
  rollback tran    
         print '=> Failed to rollback voucher_num for voucher from new_num table!'                     
         print ERROR_MESSAGE()                             
   end catch  
     
   if @rows_affected > 0  
  commit tran  
    
 select @voucher_num = 0  
end  
else if ( @voucherNum_flag <> 0 and isnull(@vouch_tran, 0) = 1)  
begin  
 select @voucher_num = 0  
end  
  
  select @voucher_num   
    
if object_id('tempdb..#temp_costs', 'U') is not null                      
   exec('DROP TABLE #temp_costs')                      
                    
if object_id('tempdb..#tempcosts', 'U') is not null                      
   exec('DROP TABLE #tempcosts')                     
                    
return           
end   
GO
GRANT EXECUTE ON  [dbo].[usp_create_bulk_voucher_vouchercost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_create_bulk_voucher_vouchercost', NULL, NULL
GO

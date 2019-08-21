SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_unpaid_voucher_details]      
as      
set nocount on      
declare @ReasonOfDelay_TAG_ID        int,      
        @RspbleUserInit_TAG_ID       int,      
        @NxtActDate_TAG_ID           int,      
        @RskCover_TAG_ID             int,      
        @rows_affected               int,      
        @errcode                     int      
            
   select @errcode = 0      
        
   create table #tempEntityTags      
   (      
     entity_tag_id    int,      
     voucher_num     int null,      
     target_key     varchar(16) null      
   )      
        
   create nonclustered index xx517353_EntityTags_idx1      
      on #tempEntityTags (voucher_num)      
                       
   create table #unpaidvouchers      
   (        
      voucher_num              int,      
      voucher_type_code         char(8),      
      voucher_pay_recv          varchar(20),      
      bc_acct_short_name       varchar(30) null,      
      cp_acct_short_name       varchar(30) null,      
      voucher_creation_date     datetime null,      
      voucher_creator_name     varchar(40) null,        
      voucher_due_date        datetime null,      
      expected_pmt_date        datetime null,      
      confirmed_pmt_date       datetime null,      
      voucher_tot_amt          float null,              
      voucher_paid_amt          float null,            
      voucher_unpaid_amt        float null,            
      voucher_paid_date        datetime null,            
      voucher_curr_code        char(8) null,      
      credit_term_desc        varchar(40) null,        
      bc_bank_name            varchar(100) null,        
      cp_bank_name            varchar(100) null,        
      voucher_short_cmnt       varchar(40) null,      
      cmnt_text               varchar(max),        
      reason_for_delay        varchar(64) null,      
      followup_user_name       varchar(40) null,      
      next_act_date            varchar(20) null,      
      risk_cover              varchar(64) null,  
      pay_method_code  char(8) null  
   )        
      
   create nonclustered index xx517353_unpaidvouchers_idx1      
      on #unpaidvouchers (voucher_num)      
      
   select @ReasonOfDelay_TAG_ID = oid      
   from dbo.entity_tag_definition      
   where entity_tag_name = 'ReasonOfDelay'      
      
   select @RspbleUserInit_TAG_ID = oid      
   from dbo.entity_tag_definition      
   where entity_tag_name = 'RspbleUserInit'      
      
   select @NxtActDate_TAG_ID = oid      
   from dbo.entity_tag_definition      
   where entity_tag_name = 'NxtActDate'      
      
   select @RskCover_TAG_ID = oid      
   from dbo.entity_tag_definition      
   where entity_tag_name = 'RskCover'       
      
   insert into #tempEntityTags      
     select entity_tag_id,      
           convert(int, key1),      
           target_key1      
     from dbo.entity_tag      
     where entity_tag_id in (@ReasonOfDelay_TAG_ID,       
                             @RspbleUserInit_TAG_ID,       
                             @NxtActDate_TAG_ID,       
                             @RskCover_TAG_ID)      
                                   
   insert into #unpaidvouchers       
   (        
      voucher_num,      
      voucher_type_code ,      
      voucher_pay_recv,      
      bc_acct_short_name,      
      cp_acct_short_name,      
      voucher_creation_date,      
      voucher_creator_name,        
      voucher_due_date,      
      expected_pmt_date,      
      confirmed_pmt_date,       
      voucher_tot_amt,              
      voucher_paid_amt,            
      voucher_unpaid_amt,            
      voucher_paid_date,            
      voucher_curr_code,      
      credit_term_desc,        
      bc_bank_name,        
      cp_bank_name,        
      voucher_short_cmnt,      
      cmnt_text,  
      pay_method_code  
   )        
   select DISTINCT v.voucher_num,       
         voucher_type_code,       
         case voucher_pay_recv_ind when 'P' then 'PAYABLE'       
                                   else 'RECEIVABLE'       
         end,       
         bc.acct_short_name,      
         cp.acct_short_name,      
         voucher_creation_date,      
         iu.user_last_name + ', ' + iu.user_first_name,      
         voucher_due_date,      
         voucher_expected_pay_date,      
         null,      
         isnull(voucher_tot_amt,0),      
         isnull(voch_tot_paid_amt,0),      
         isnull(voucher_tot_amt,0) - isnull(voch_tot_paid_amt,0),       
         voucher_paid_date,      
         voucher_curr_code,      
         credit_term_desc,      
         bcbi.bank_name,      
         cpbi.bank_name,               
         voucher_short_cmnt,      
         null,  
         v.pay_method_code  
   from (select *      
         from dbo.voucher i      
         where voucher_status in ('F', 'U')
         and exists (select 1 from voucher_cost vc where vc.voucher_num=i.voucher_num) ) v      
           left outer join dbo.account cp       
              on cp.acct_num = v.acct_num      
           left outer join dbo.icts_user iu       
              on iu.user_init = v.voucher_creator_init      
           left outer join dbo.account bc       
              on bc.acct_num = v.voucher_book_comp_num      
           left outer join dbo.credit_term ct       
              on ct.credit_term_code = v.credit_term_code      
           left outer join dbo.account_bank_info cpbi       
              on cpbi.acct_bank_id = cp_acct_bank_id      
           left outer join dbo.account_bank_info bcbi       
              on bcbi.acct_bank_id = book_comp_acct_bank_id      
   select @rows_affected = @@rowcount,      
          @errcode = @@error      
   if @errcode > 0      
   begin      
      print '=> Failed to copy records to #unpaidvouchers!'      
      goto endofsp       
   end      
         
   if @rows_affected > 0       
   begin        
      -- A voucher can have multiple Payments, the report expects     
      -- only 1 column for all the payment comments, so this block     
      -- of code is using XML Paths to concatenate the multiple     
      -- Voucher Payment comments.  (Kishore)    
      update uv         
      set cmnt_text = t1.cmnt_text                                      
      from #unpaidvouchers uv      
   join (select uv1.voucher_num,    
     REPLACE((SELECT RTRIM(convert(varchar(max),c.cmnt_text)) + ',' AS 'data()'     
     from #unpaidvouchers uv2    
      join dbo.voucher_payment vp  on uv2.voucher_num=vp.voucher_num    
         join dbo.comment c  on c.cmnt_num = vp.cmnt_num    
                        where uv2.voucher_num = uv1.voucher_num     
      FOR XML PATH(''))+' ',', ','') as cmnt_text    
   from #unpaidvouchers uv1) as t1 on t1.voucher_num=uv.voucher_num    
      select @errcode = @@error      
      if @errcode > 0      
      begin      
         print '=> Failed to update the #unpaidvouchers table for voucher_payment_cmnt, etc!'      
         goto errexit      
      end      
    
      update uv         
      set confirmed_pmt_date = (select max(value_date)       
                               from dbo.voucher_payment vp       
                               where uv.voucher_num = vp.voucher_num)       
      from #unpaidvouchers uv      
      select @errcode = @@error      
      if @errcode > 0      
      begin      
         print '=> Failed to update the #unpaidvouchers table for expected_pmt_date, etc!'      
         goto errexit      
      end      
         
      -- reason for delay      
      update uv      
      set reason_for_delay = tag_option_desc      
      from #unpaidvouchers uv      
              join #tempEntityTags tet       
                 on tet.voucher_num = uv.voucher_num      
              join dbo.entity_tag_option eto       
                 on eto.entity_tag_id = tet.entity_tag_id and       
                    eto.tag_option = tet.target_key      
      where tet.entity_tag_id = @ReasonOfDelay_TAG_ID      
      select @errcode = @@error      
      if @errcode > 0      
      begin      
         print '=> Failed to update the #unpaidvouchers table for "reason for delay", etc!'      
goto errexit      
      end      
            
      -- risk cover      
      update uv      
      set risk_cover = tag_option_desc      
      from #unpaidvouchers uv      
              join #tempEntityTags tet       
                 on tet.voucher_num = uv.voucher_num      
              join dbo.entity_tag_option eto       
                 on eto.entity_tag_id = tet.entity_tag_id and       
                    eto.tag_option = tet.target_key      
      where tet.entity_tag_id = @RskCover_TAG_ID      
      if @errcode > 0      
      begin      
         print '=> Failed to update the #unpaidvouchers table for "risk cover", etc!'      
         goto errexit      
      end      
      
      -- Next Action Date      
      update uv      
      set next_act_date = target_key      
      from #unpaidvouchers uv      
              join #tempEntityTags tet       
                 on tet.voucher_num = uv.voucher_num      
      where entity_tag_id = @NxtActDate_TAG_ID      
      if @errcode > 0      
      begin      
         print '=> Failed to update the #unpaidvouchers table for "Next Action Date", etc!'      
         goto errexit      
      end      
      
      -- Follow up user name      
      update uv      
      set followup_user_name = (user_last_name + ', ' + user_first_name)      
      from #unpaidvouchers uv      
              join #tempEntityTags tet       
                 on tet.voucher_num = uv.voucher_num      
              join dbo.icts_user iu       
                 on iu.user_init = tet.target_key      
      where tet.entity_tag_id = @RspbleUserInit_TAG_ID      
      if @errcode > 0      
      begin      
         print '=> Failed to update the #unpaidvouchers table for "Follow up user name", etc!'      
         goto errexit      
      end      
   end      
         
errexit:         
   select voucher_num 'Unpaid Voucher #',      
        voucher_type_code 'Type Code',      
        voucher_pay_recv 'Pay/Rec Code',      
        bc_acct_short_name 'Booking Company',      
        cp_acct_short_name 'Counterparty',      
        voucher_creation_date 'Creation Date',       
        voucher_creator_name 'Creator',      
        voucher_due_date 'Due Date',      
        expected_pmt_date 'Expected Payment Date',      
        confirmed_pmt_date 'Confirmed Payment Date',      
        voucher_tot_amt 'Voucher Amount',      
        voucher_paid_amt 'Partial Payment Amount',      
        voucher_unpaid_amt 'Unpaid Amount',      
        voucher_curr_code 'Currency',      
        voucher_paid_date 'Partial Payment Date',      
        reason_for_delay 'Reason For Delay',      
        followup_user_name 'Responsible For Follow Up',      
        next_act_date 'Next Action Date',      
        credit_term_desc 'Credit Terms',      
        bc_bank_name 'Booking Co Bank Name',      
        cp_bank_name 'Counterparty Bank Name',              
        risk_cover 'Risk Cover',      
        voucher_short_cmnt 'Short Comment',      
        cmnt_text 'Payment Short Comment',  
        pay_method_code 'Payment Method'  
   from #unpaidvouchers      
   order by voucher_num      
      
endofsp:      
   drop table #unpaidvouchers      
   drop table #tempEntityTags      
    
   if @errcode > 0      
      return 1      
   return 0      
GO
GRANT EXECUTE ON  [dbo].[usp_get_unpaid_voucher_details] TO [next_usr]
GO

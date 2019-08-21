SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[usp_cq_triggerJavaALSforModularFormula]
(
   @timeSpan    int = -10
)
AS
set nocount on
set xact_abort on

declare @transId	      int,
	      @loginame	      varchar(100),
	      @init		        char(3),
	      @rows_affected	int

   create table #inserted_fb_module_info
   (
      formula_num      int not null,
      formula_body_num int not null 
   )

   alter table #inserted_fb_module_info
     add constraint inserted_fb_module_info_pk 
        PRIMARY KEY (formula_num, formula_body_num)

   set @rows_affected = 0

   insert into #inserted_fb_module_info
        (formula_num, formula_body_num )
     select formula_num,
            formula_body_num
     from dbo.fb_module_info fbm
             join dbo.icts_transaction it 
                on fbm.trans_id = it.trans_id
     where it.executor_id = 0 and 
           it.tran_date > DATEADD(ss, @timeSpan, GETDATE())
     set @rows_affected = @@rowcount

   if @rows_affected > 0
   begin
      exec dbo.get_new_num @key_name = 'trans_id', @location = 0    
      select @transId = last_num 
      from dbo.icts_trans_sequence
    
      select @loginame = loginame 
      from master.sys.sysprocesses 
      where spid = @@spid  
  
      select @init = user_init   
      from dbo.icts_user with (nolock) 
      where user_logon_id = @loginame  
    
      insert into dbo.icts_transaction
           (trans_id,type,user_init,tran_date,app_name,app_revision,spid,
            workstation_id,parent_trans_id,executor_id)
        select @transId, 'U', @init, GETDATE(),'System', null, @@spid, null, null, 1
    
      begin tran
      begin try
	      update fb
	      set fb.trans_id = @transId
	      from dbo.fb_modular_info fb 
	              inner join #inserted_fb_module_info ifb
	                 on fb.formula_num = ifb.formula_num and 
	                    fb.formula_body_num = ifb.formula_body_num
      end try
      begin catch
	      if @@trancount > 0 
           rollback tran 
        print '=> Failed to perform update on fb_modular_info table '
        print '==> ERROR: ' + ERROR_MESSAGE()
        goto endofsp
      end catch
      commit tran
   end

endofsp:
drop table #inserted_fb_module_info
GO
GRANT EXECUTE ON  [dbo].[usp_cq_triggerJavaALSforModularFormula] TO [next_usr]
GO

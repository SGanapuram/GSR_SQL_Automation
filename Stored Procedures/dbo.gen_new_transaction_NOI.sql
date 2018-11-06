SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[gen_new_transaction_NOI]
(
   @app_name    varchar(80) = 'osql',
   @trans_type  char(1) = 'U'
)
As
set nocount on
set xact_abort on
declare @rowcount  int
declare @loginame  varchar(30)
declare @init      char(3)
declare @status    int
declare @workstation_name varchar(20) 

   if @app_name = ''
   begin
      print 'You must give a NON-EMPTY string for the argument @app_name'
      return 1
   end

   if @trans_type not in ('U', 'E', 'S', 'A', 'I')
   begin
      print 'You must give a valid code for the argument @trans_type'
      return 1
   end

   select @init = null

   select @loginame = SUBSTRING(loginame,CHARINDEX('\',loginame)+1,30),
          @workstation_name = RTRIM(hostname)
   from master..sysprocesses where spid = @@spid


   select @init = user_init 
   from dbo.icts_user 
   where user_logon_id = @loginame
 
   if @init is null  select @init = @loginame
  
   begin tran
   exec @status = dbo.get_new_num_NOI 'trans_id', 0
   if @status = 0
   begin
      insert into dbo.icts_transaction 
           (trans_id, type, user_init, tran_date,
            app_name, app_revision, spid, workstation_id)
      select last_num, @trans_type, @init, getdate(), @app_name, NULL, @@spid, @workstation_name
      from dbo.icts_trans_sequence    
      where oid = 1
      select @rowcount = @@rowcount
      if @rowcount = 1
         select @status = 0
      else
         select @status = 1
   end
   
   if @status = 0
   begin
      if @@trancount > 0
         commit tran
   end
   else
   begin
      if @@trancount > 0
         rollback tran
   end
   return @status
GO
GRANT EXECUTE ON  [dbo].[gen_new_transaction_NOI] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[gen_new_transaction_NOI] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'gen_new_transaction_NOI', NULL, NULL
GO

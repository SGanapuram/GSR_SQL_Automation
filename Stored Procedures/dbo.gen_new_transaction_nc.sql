SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[gen_new_transaction_nc]
(
   @app_name    varchar(80) = 'isql',
   @trans_type  char(1) = 'U'
)
as
set nocount on
set xact_abort on
declare @anewnum   int
declare @rowcount  int
declare @loginame  varchar(30)
declare @init      char(3)
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
      exec dbo.get_new_num 'trans_id', 0

      select @anewnum = last_num 
      from dbo.icts_trans_sequence    
      where oid = 1

      insert into dbo.icts_transaction   
            (trans_id, type, user_init, tran_date, app_name, app_revision, spid, workstation_id)  
         values (@anewnum, @trans_type, @init, getdate(), @app_name, NULL, @@spid, @workstation_name)

      select @rowcount = @@rowcount
      if (@@rowcount = 1)
      begin
         commit tran
         print 'New icts_transaction record was created successfully'
         return 0
      end
      else
      begin
         rollback tran
         print 'Failed to create a new icts_transaction record.'
         return 1
      end
GO
GRANT EXECUTE ON  [dbo].[gen_new_transaction_nc] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[gen_new_transaction_nc] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'gen_new_transaction_nc', NULL, NULL
GO

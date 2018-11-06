SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[gen_new_trans_qf] 
(
   @aTransId int output
)
as
set nocount on
declare @anewnum   int,
        @rowcount  int,
        @loginame  varchar(30),
        @init      char(3),
        @status    int

   select @init = null
   select @loginame = loginame 
   from master..sysprocesses 
   where spid = @@spid

   select @init = user_init 
   from dbo.icts_user 
   where user_logon_id = @loginame
 
   if @init is null  
      select @init = @loginame
   
   exec @status = dbo.get_new_num_qf @anewnum output, 'trans_id', 0

   if (@status = 0)
   begin
      insert into dbo.icts_transaction
          (trans_id, type, user_init, tran_date,
           app_name, app_revision, spid, workstation_id)
        values (@anewnum, 'U', @init, getdate(), 'isql', NULL, @@spid, NULL)
      select @rowcount = @@rowcount
      select @aTransId = @anewnum
      return @rowcount
   end
   else
   begin
      select @aTransId = 0
      return 3
   end
GO
GRANT EXECUTE ON  [dbo].[gen_new_trans_qf] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'gen_new_trans_qf', NULL, NULL
GO

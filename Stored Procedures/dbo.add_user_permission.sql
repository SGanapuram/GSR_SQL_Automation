SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[add_user_permission]
(
   @user_init      varchar(3) = null,
   @function_num   int = null,
   @perm_level     varchar(8) = null
)
as
set nocount on
set xact_abort on
declare @fdv_id       int,
        @row_affected int,
        @errcode      int,
        @smsg         varchar(max)

   if @user_init is null or
      @function_num is null or
      @perm_level is null
   begin
      print 'You must provide values for all arguments!'
      goto reportusage
   end

   if not exists (select 1
                  from dbo.icts_user with (nolock)
                  where user_init = @user_init)
   begin
      print 'You must provide a valid value for the argument @user_init!'
      goto reportusage
   end

   if not exists (select 1
                  from dbo.icts_function with (nolock)
                  where function_num = @function_num)
   begin
      print 'You must provide a valid value for the argument @function_num!'
      goto reportusage
   end

   select @perm_level = upper(@perm_level)
   if @perm_level not in ('OWN', 'DEPT', 'ANY')
   begin
      print 'You must provide a valid value for the argument @perm_level!'
      goto reportusage
   end
  
   if exists (select 1
              from dbo.user_permission
              where user_init = @user_init and
                    function_num = @function_num and
                    perm_level = @perm_level)
   begin
      print 'The record you want to add has existed in icts_user_permission table'
      goto endofsp
   end

   begin try
     select @fdv_id = fdv_id
     from dbo.function_detail fd with (nolock),
          dbo.function_detail_value fdv with (nolock)
     where fd.function_num = @function_num and
           fd.entity_name = 'LEVEL' and
           fd.fd_id = fdv.fd_id and
           fdv.attr_value = @perm_level
     set @row_affected = @@rowcount
   end try
   begin catch
     set @smsg = ERROR_MESSAGE()
     set @errcode = ERROR_NUMBER()
     RAISERROR('=> Failed to get fdv_id for function #%d/perm_level ''%s'' due to the error:', 0, 1, @function_num, @perm_level) with nowait
     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
     goto endofsp
   end catch

   begin tran
   begin try
     insert into dbo.icts_user_permission
         (user_init, fdv_id, trans_id)
       values(@user_init, @fdv_id, 1)
     set @row_affected = @@rowcount
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     set @smsg = ERROR_MESSAGE()
     set @errcode = ERROR_NUMBER()
     RAISERROR('=> Failed to get fdv_id for function #%d/perm_level ''%s'' due to the error:', 0, 1, @function_num, @perm_level) with nowait
     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
     goto endofsp
   end catch
   commit tran
   if @row_affected > 0
      RAISERROR('A new icts_user_permission record was added successfully!', 0, 1) with nowait
   else
      RAISERROR('No new icts_user_permission record was added!', 0, 1) with nowait
   goto endofsp

reportusage:
   print 'Usage: exec dbo.add_user_permission @user_init = ''?'', @function_num = ?, @perm_level = ''?'''
   print '        Where, the value for the argument @user_init must exist in icts_user table'
   print '               the value for the argument @function_num must exist in icts_function table'
   print '               the value for the argument @perm_level must be one of (''OWN'', ''DEPT'', ''ANY'')'
   return 1

endofsp:
return 0
GO
GRANT EXECUTE ON  [dbo].[add_user_permission] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[add_user_permission] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'add_user_permission', NULL, NULL
GO

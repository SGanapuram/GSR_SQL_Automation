SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_add_user_permission]
(
   @user_init    char(3) = null,
   @function_num int = 0,
   @perm_level   varchar(8) = null   
)
as
set nocount on
set xact_abort on
declare @fdv_id        int,
        @row_existed   int,
        @errcode       int,
        @smsg          varchar(255)

   if @user_init is null or
      @function_num = 0 or
      @perm_level is null
   begin
      print 'You must give NON-NULL values to the arguments!'
      goto reportusage
   end

   if not exists (select 1
                  from icts_user
                  where user_init = @user_init)
   begin
      print 'You must give a valid value to the argument @user_init!'
      goto reportusage
   end

   if not exists (select 1
                  from icts_function
                  where function_num = @function_num)
   begin
      print 'You must give a valid value to the argument @function_num!'
      goto reportusage
   end

   if upper(@perm_level) not in ('ANY', 'DEPT', 'OWN')
   begin
      print 'The value given to the argument @perm_level must be one of the followings:'
      print '(''ANY'', ''OWN'', ''DEPT'''
      goto reportusage
   end
          
   select @fdv_id = fdv_id
   from function_detail fd,
        function_detail_value fdv
   where fd.function_num = @function_num and
         fd.entity_name = 'LEVEL' and
         fd.fd_id = fdv.fd_id and
         fdv.attr_value = upper(@perm_level)
   select @row_existed = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      print 'Error occurred when obtaining a fdv_id!'
      goto exit1
   end
   if @row_existed = 0
   begin
      select @smsg = 'Failed to get fdv_id for function #' + convert(varchar, @function_num) + '/perm_level ''' + @perm_level + '''!'
      print @smsg
      goto exit1 
   end

   if not exists (select 1
                  from icts_user_permission
                  where user_init = @user_init and
                        fdv_id = @fdv_id)
   begin
       begin tran
       insert into icts_user_permission
           (user_init, fdv_id, trans_id)
         values(@user_init, @fdv_id, 1)
       select @row_existed = @@rowcount,
              @errcode = @@error
       if @errcode > 0 or @row_existed = 0
       begin
          rollback tran
          print 'Failed to add a new icts_user_permission record!'
          if @errcode > 0
             goto exit1
       end
       else
       begin
          commit tran
          select @smsg = '=> icts_user_permission: (user_init ''' + @user_init + ''', '
          select @smsg = @smsg + 'fdv_id #' + convert(varchar, @fdv_id) + ', '
          select @smsg = @smsg + 'function #' + convert(varchar, @function_num) + ', '
          select @smsg = @smsg + 'perm_level ''' + upper(@perm_level) + ''') was added ...'
          print @smsg
       end
    end
    return 0
    
exit1:
   return 1
   
reportusage:
   print ' '
   print 'Usage: exec dbo.usp_add_user_permission @user_init = ''?'','
   print '                                        @function_num int = ?,'
   print '                                        @perm_level = ''?'''
   return 2   
GO
GRANT EXECUTE ON  [dbo].[usp_add_user_permission] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_add_user_permission', NULL, NULL
GO

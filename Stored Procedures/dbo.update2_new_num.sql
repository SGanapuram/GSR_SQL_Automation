SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[update2_new_num]
(
   @last_num         int output,
   @for_type0        varchar(40) = null,
   @for_ref0         int = null,
   @for_type1        varchar(40) = null,
   @for_ref1         varchar(40) = null,
   @for_type2        varchar(40) = null,
   @for_ref2         varchar(40) = null,
   @for_type3        varchar(40) = null,
   @for_ref3         int = null,
   @incrementIndex   int = null
)
as 
set nocount on
set xact_abort on
declare @rowcount    int
declare @next_num    int
declare @rc          int
declare @output      int

   if (@for_type0 != 'loc_num' and 
       @for_type1 not in ('num_col_name', 'col name'))
      return 4

   if @for_type2 is null 
   begin
      if @for_ref1 = 'bsi_num'
      begin
         exec @rc = dbo.update3_new_num @incrementIndex,
                                        @for_ref0,
                                        @output output
         if (@rc = 0)
         begin
            select @last_num = @output
            return 0
         end
         return @rc
      end
   end

   if @for_type2 is null 
   begin
      begin transaction
      update dbo.new_num
      set last_num = last_num + @incrementIndex
      where num_col_name = @for_ref1 and    
            loc_num = @for_ref0
      select @rowcount = @@rowcount
      if (@rowcount = 1)
      begin
         select @last_num = last_num
         from dbo.new_num
         where num_col_name = @for_ref1 and    
               loc_num = @for_ref0             
         commit transaction
         return 0
      end
      else
      begin
         rollback transaction
         if (@rowcount = 0)
            return 1
         else 
            return 2
      end
   end
        
   if (@for_type2 != 'table_name') return 4
   if (@for_ref2 = 'account_address' and
       @for_type3 = 'acct_num')
   begin
      if exists (select 1 
                 from dbo.account
                 where acct_num = @for_ref3)
      begin
         select @next_num = max(acct_addr_num)
         from dbo.account_address
         where  acct_num = @for_ref3

         if (@next_num is not null)
            select @last_num = @next_num + 1
         else
            select @last_num = 1
         return 0
      end
      return 4
   end

   if (@for_ref2 = 'account_instruction' and
       @for_type3 = 'acct_num')
   begin
      if exists (select 1 
                 from dbo.account
                 where acct_num = @for_ref3)
      begin
         select @next_num = max(acct_instr_num)
         from dbo.account_instruction
         where acct_num = @for_ref3

         if (@next_num is not null)
            select @last_num = @next_num + 1
         else
            select @last_num = 1
         return 0
      end
      return 4
   end

   if (@for_ref2 = 'account_credit_limit' and
       @for_type3 = 'acct_num') 
   begin
      if exists (select 1 
                 from dbo.account
                 where acct_num = @for_ref3)
      begin
         select @next_num = max(acct_limit_num)
         from dbo.account_credit_limit
         where acct_num = @for_ref3

         if (@next_num is not null)
            select @last_num = @next_num + 1
         else
            select @last_num = 1
         return 0
      end
      return 4
   end

   if (@for_ref2 = 'account_contact' and
       @for_type3 = 'acct_num')
   begin
      if exists (select 1 
                 from dbo.account
                 where acct_num = @for_ref3)
      begin
         select @next_num = max(acct_cont_num)
         from dbo.account_contact
         where acct_num = @for_ref3

         if (@next_num is not null)
            select @last_num = @next_num + 1
         else
            select @last_num = 1
         return 0
      end
      return 4
   end
   return 4
GO
GRANT EXECUTE ON  [dbo].[update2_new_num] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[update2_new_num] TO [next_usr]
GO

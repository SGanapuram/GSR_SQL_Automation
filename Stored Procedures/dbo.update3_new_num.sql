SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[update3_new_num]
(
   @incrementIndex   int = null,
   @for_ref0         int = null,
   @last_num         int output
)
as 
set nocount on
set xact_abort on
declare @rowcount     int
declare @max_count    int
declare @min_count    int
declare @first_count  int
declare @first_max    int
declare @second_count int
declare @second_max   int
declare @third_count  int
declare @third_max    int

   if @for_ref0 = 0
   begin  
      select @max_count    = 59998
      select @min_count    = 19999
      select @first_count  = 29999
      select @first_max    = 29998
      select @second_count = 39999
      select @second_max   = 39998
      select @third_count  = 49999
      select @third_max    = 49998
   end

   if @for_ref0 = 1
   begin  
      select @max_count    = 89998
      select @min_count    = 59999
      select @first_count  = 69999
      select @first_max    = 69998
      select @second_count = 79999
      select @second_max   = 79998
      select @third_count  = 0
   end

   if @for_ref0 = 3
   begin  
      select @max_count    = 99998
      select @min_count    = 89999
      select @first_count  = 0
   end

   begin transaction
   update dbo.new_num
   set last_num = @min_count + @incrementIndex
   where num_col_name = 'bsi_num' and    
         loc_num = @for_ref0 and    
         (last_num + @incrementIndex) > @max_count

   select @rowcount = @@rowcount
   if (@rowcount = 1)
   begin
      select @last_num = last_num - @incrementIndex + 1
      from dbo.new_num
      where num_col_name = 'bsi_num' and
            loc_num = @for_ref0          
      commit transaction            
      return 0
   end

   if (@rowcount != 0)
   begin
      rollback transaction
      return 2
   end
        
   if @first_count = 0
   begin
      update dbo.new_num
      set last_num = last_num + @incrementIndex
      where num_col_name = 'bsi_num' and 
            loc_num = @for_ref0 and
            (last_num + @incrementIndex) !> @max_count

      select @rowcount = @@rowcount
      if (@rowcount = 1)
      begin
         select @last_num = last_num - @incrementIndex + 1
         from dbo.new_num
         where num_col_name = 'bsi_num' and    
               loc_num = @for_ref0           
         commit transaction             
         return 0
      end
      rollback transaction
      if (@rowcount = 0)
         return 1
      else
         return 2
   end

   update dbo.new_num
   set last_num = @first_count + @incrementIndex
   where num_col_name = 'bsi_num' and
         loc_num = @for_ref0 and
         last_num < @first_count and
         (last_num + @incrementIndex) > @first_max
   select @rowcount = @@rowcount
   if (@rowcount = 1)
   begin
      select @last_num = last_num - @incrementIndex + 1
      from new_num
      where num_col_name = 'bsi_num' and
            loc_num = @for_ref0           
      commit transaction              
      return 0
   end
   if (@rowcount != 0)
   begin
      rollback transaction
      return 2
   end

   update dbo.new_num
   set last_num = @second_count + @incrementIndex
   where num_col_name = 'bsi_num' and 
         loc_num = @for_ref0 and
         last_num < @second_count and
         (last_num + @incrementIndex) > @second_max
   select @rowcount = @@rowcount
   if (@rowcount = 1)
   begin
      select @last_num = last_num - @incrementIndex + 1
      from dbo.new_num
      where num_col_name = 'bsi_num' and
            loc_num = @for_ref0           
      commit transaction              
      return 0
   end

   if (@rowcount != 0)
   begin
      rollback transaction
      return 2
   end

   if @third_count != 0
   begin
      update dbo.new_num
      set last_num = @third_count + @incrementIndex
      where num_col_name = 'bsi_num' and   
            loc_num = @for_ref0 and
            last_num < @third_count and    
            (last_num + @incrementIndex) > @third_max
      select @rowcount = @@rowcount
      if (@rowcount = 1)
      begin
         select @last_num = last_num - @incrementIndex + 1
         from dbo.new_num
         where num_col_name = 'bsi_num' and    
               loc_num = @for_ref0            
         commit transaction              
         return 0
      end
      if (@rowcount != 0)
      begin
         rollback transaction
         return 2
      end
   end

   update dbo.new_num
   set last_num = last_num + @incrementIndex
   where num_col_name = 'bsi_num' and
         loc_num = @for_ref0 and    
         (last_num + @incrementIndex) !> @max_count
   select @rowcount = @@rowcount
   if (@rowcount = 1)
   begin
      select @last_num = last_num - @incrementIndex + 1
      from dbo.new_num
      where num_col_name = 'bsi_num' and
            loc_num = @for_ref0            
      commit transaction              
      return 0
   end
   rollback transaction
   if (@rowcount = 0)
      return 1
   else
      return 2
GO
GRANT EXECUTE ON  [dbo].[update3_new_num] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[update3_new_num] TO [next_usr]
GO

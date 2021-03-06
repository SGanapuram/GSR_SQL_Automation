SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_new_num_4_Cayenne]
(
   @key_name       varchar(40) = null, 
   @location       int = null,
   @block_size     smallint = 1,
   @next_num       int  OUTPUT   
)   
as
set nocount on
set xact_abort on
declare @my_loc_num     int,
        @my_key_name    varchar(40),
        @seqnums_needed smallint,
        @n              smallint,
		@rows_affected  int

   set @my_key_name = @key_name
   select @rows_affected = 0
  
   if @location is null
      set @my_loc_num = 0
   else 
      set @my_loc_num = @location

   set @seqnums_needed = isnull(@block_size, 1)
   if @seqnums_needed <= 0
      set @seqnums_needed = 1
   
   set @next_num = 0
   BEGIN TRANSACTION 
   if @my_key_name = 'trans_id'
   begin      
      update dbo.icts_trans_sequence 
      set @next_num = last_num + @seqnums_needed,
          last_num = last_num + @seqnums_needed
			where oid = 1 
	  select @rows_affected = @@rowcount
   end
   else
   begin
      if @my_key_name = 'TI_feed_transaction_oid'
      begin
         update dbo.TI_feed_trans_sequence
         set @next_num = last_num + @seqnums_needed,
             last_num = last_num + @seqnums_needed
         where oid = 1
		 select @rows_affected = @@rowcount		 
      end
      else   
      begin
         -- use (-1 * @seqnums_needed) for the case that the @my_key_name 
         -- does not exist in the new_num table. In this case, @next_num
         -- will have the value 0 which will trigger a ROLLBACK TRAN
         set @n = -1 * @seqnums_needed
         update dbo.new_num 
         set @next_num = isnull(last_num, @n) + @seqnums_needed,  
             last_num = isnull(last_num, @n) + @seqnums_needed
         where num_col_name = @my_key_name and    
               loc_num = @my_loc_num
		 select @rows_affected = @@rowcount			   
      end
   end
   if @next_num > 0
   begin
      COMMIT TRANSACTION 
      return 0 
   end  
   else 
   begin 
      ROLLBACK TRANSACTION 
      return 1 
   end  
GO
GRANT EXECUTE ON  [dbo].[get_new_num_4_Cayenne] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[get_new_num_4_Cayenne] TO [next_usr]
GO

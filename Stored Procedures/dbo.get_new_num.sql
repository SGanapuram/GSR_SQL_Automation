SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_new_num]
(
   @key_name            varchar(40) = null, 
   @location            int = null,
   @block_size          smallint = 1,
   @display_next_num    bit = 1 
)   
as
set nocount on
set xact_abort on
declare @first_value     sql_variant,  
        @last_value      sql_variant,  
        @next_num        bigint,  
        @errcode         int,  
  @smsg            varchar(max),  
  @seqnums_needed  int,  
  @seqname         sysname  
   
   set @next_num = 0  
   set @errcode = 0  
   
   set @seqnums_needed = isnull(@block_size, 1)  
   if @seqnums_needed <= 0  
      set @seqnums_needed = 1  
  
   set @seqname = dbo.udf_sqlserver_sequence_name_4_a_key(@key_name)  
   if @seqname is null  
   begin  
      set @errcode = 1  
   RAISERROR('=> Unable to find a sequence object for the key ''%s''???', 16, 1, @key_name) with nowait  
   goto endofsp  
   end  
     
   if @seqnums_needed > 1  
   begin  
      begin try  
        begin tran   
        exec sys.sp_sequence_get_range @sequence_name = @seqname,   
                                       @range_size = @seqnums_needed,   
            @range_first_value = @first_value OUTPUT,  
                                       @range_last_value = @last_value OUTPUT;  
  commit tran  
        set @next_num = convert(bigint, @last_value)              
   end try  
   begin catch  
     set @errcode = ERROR_NUMBER()  
        set @smsg = ERROR_MESSAGE()  
        if @@trancount > 0  
           rollback tran  
        RAISERROR('=> Failed to execute the stored procedure ''sys.sp_sequence_get_range'' due to the error below:', 0, 1) with nowait  
        RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait  
      end catch  
      goto endofsp  
   end  
     
   exec @errcode = dbo.usp_get_next_sequence_num @key_name, @next_num output  
  
endofsp:  
if @errcode > 0  
begin  
   if @display_next_num = 1  
      select null   
   return 1   
end  
     
if @display_next_num = 1  
   select @next_num   
return 0   
GO
GRANT EXECUTE ON  [dbo].[get_new_num] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[get_new_num] TO [next_usr]
GO

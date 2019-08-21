SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[insert_market_info]
(
   @headline		        char(255),
   @concluded_ind	    	char(1),
   @type		            tinyint,
   @idms_board_name	        char(40),
   @newsgrazer_dept_name	char(40),
   @max_id		            int = 0 output
)
as
set nocount on  
set xact_abort on            
declare @errcode         int,
        @smsg            varchar(max),
        @mkt_info_num    int

   set @mkt_info_num = 0

   begin tran
   begin try
     set @mkt_info_num = NEXT VALUE FOR dbo.market_info_SEQ
   end try
   begin catch
     set @errcode = ERROR_NUMBER()
     set @smsg = ERROR_MESSAGE()
     if @@trancount > 0
        rollback tran
     RAISERROR('=> Failed to obtain the next sequence number from the sequence ''market_info_SEQ'' due to the error below:', 0, 1) with nowait
     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
     goto errexit
   end catch

   begin try
	 insert into dbo.market_info
		   (mkt_info_num,
		    mkt_info_headline,
            mkt_info_concluded_ind,
            mkt_info_type,
            idms_board_name,
            newsgrazer_dept_name,
            trans_id)	
	  values (@mkt_info_num,
	          @headline,
              @concluded_ind,
              @type,
              @idms_board_name,
              @newsgrazer_dept_name,
              1)		
   end try
   begin catch
     set @errcode = ERROR_NUMBER()
     set @smsg = ERROR_MESSAGE()
     if @@trancount > 0
        rollback tran
     RAISERROR('=> Failed to add a new market_info record due to the error below:', 0, 1) with nowait
     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
     goto errexit
   end catch
   commit tran
   
   set @max_id = @mkt_info_num
   select @max_id as max_id

 errexit:
   if @errcode = 0
      return 0
   else 
	  return 1
GO
GRANT EXECUTE ON  [dbo].[insert_market_info] TO [next_usr]
GO

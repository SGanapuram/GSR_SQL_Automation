SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[insert_market_info]
(
		@headline		          char(255),
		@concluded_ind	    	char(1),
		@type		              tinyint,
		@idms_board_name	    char(40),
		@newsgrazer_dept_name	char(40),
		@max_id		            int = 0 output
)
as
set nocount on  
set xact_abort on            
declare @rc int,
	      @mkt_info_num int

	 select @rc = 0,
	        @mkt_info_num = 0

	 BEGIN TRANSACTION MKT_INFO_TRAN
	 select @mkt_info_num = last_num
	 from dbo.new_num
	 where num_col_name = 'mkt_info_num' 
   set @rc = @@rowcount

   if (@rc = 0)
	 begin
	    set @mkt_info_num = 1
	    insert into dbo.new_num (num_col_name, loc_num, last_num, trans_id)
	      values ('mkt_info_num', 0, @mkt_info_num, 1)
	    if (@@rowcount = 1)
	       COMMIT TRANSACTION MKT_INFO_TRAN
   	  else
	    begin
	       ROLLBACK TRAN MKT_INFO_TRAN
	       return 1
	    end		
   end
	 else
	 begin
	    set @mkt_info_num = @mkt_info_num + 1
	    update dbo.new_num
	    set last_num = @mkt_info_num,
          trans_id = trans_id
      where num_col_name = 'mkt_info_num' 
	    if (@@rowcount = 1)
	       COMMIT TRANSACTION MKT_INFO_TRAN
   	  else
	    begin
	       ROLLBACK TRAN MKT_INFO_TRAN
	       return 1
	    end
   end

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
		
	 set @rc = @@rowcount

	 select @max_id = @mkt_info_num
	 select @max_id max_id

	 if @rc = 1
	    return 0
	 else 
	    return 1
GO
GRANT EXECUTE ON  [dbo].[insert_market_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'insert_market_info', NULL, NULL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[update_new_num]
(
	 @num_col_name      varchar(30),
	 @loc_num           smallint,
	 @last_num          int,
	 @old_trans_id      int,
	 @trans_id           int
)
as
begin
declare @rowcount  int

	 update dbo.new_num
	 set last_num = @last_num, 
       trans_id = @trans_id 
	 where trans_id = @old_trans_id and
		     num_col_name = @num_col_name and 
		     loc_num = @loc_num
	 set @rowcount = @@rowcount

	 if (@rowcount = 1)
		  return 0     /* success */
	   
	 if @rowcount > 1
	    return 2      /* multiple rows updated */

   if not exists (select * 
			            from dbo.new_num
		              where num_col_name = @num_col_name and 
		                    loc_num = @loc_num)
	    return 1
	 else
	    return -100
end
GO
GRANT EXECUTE ON  [dbo].[update_new_num] TO [next_usr]
GO

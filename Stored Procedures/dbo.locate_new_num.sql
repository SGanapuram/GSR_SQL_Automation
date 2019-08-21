SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_new_num]
(
   @by_type0   varchar(40),
   @by_ref0    varchar(255),
   @by_type1   varchar(40),
   @by_ref1    varchar(255)
)
as
begin
set nocount on
declare @rowcount int
declare @ref_num0 smallint

	 if @by_type0 = 'num_col_name' and
		  @by_type1 = 'loc_num'
	 begin
		  set @ref_num0 = convert(smallint, @by_ref1)
		  select
			   /* :LOCATE: NewNum */
		     nn.num_col_name,    /* :IS_KEY: 1 */
		     nn.loc_num,         /* :IS_KEY: 2 */
		     nn.last_num,                            
   		   nn.owner_table,
   		   nn.owner_column,
		     nn.trans_id 
		  from dbo.new_num nn with (nolock)
		  where nn.num_col_name = @by_ref0 and 
            nn.loc_num = @ref_num0 
	 end
	 else
		  return 4

	 set @rowcount = @@rowcount
	 if @rowcount = 1
		  return 0
	 else if @rowcount = 0
		  return 1
	 else
		  return 2
end
GO
GRANT EXECUTE ON  [dbo].[locate_new_num] TO [next_usr]
GO

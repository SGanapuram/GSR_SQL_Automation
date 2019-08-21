SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_new_num_NOI] 
(
   @key_name       varchar(40) = null, 
   @location       int = null,
   @block_size     smallint = 1 
)   
as
set nocount on
declare @status   int

   exec @status = dbo.get_new_num @key_name,
                                  @location,
								  @block_size,
								  0           /* @display_next_num */ 
   return @status								  
GO
GRANT EXECUTE ON  [dbo].[get_new_num_NOI] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[get_new_num_NOI] TO [next_usr]
GO

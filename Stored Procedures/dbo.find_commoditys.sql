SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_commoditys]
(
	 @by_type0 	varchar(40) = null,
	 @by_ref0	  varchar(40) = null,
	 @by_type1 	varchar(40) = null,
	 @by_ref1	  varchar(40) = null,
	 @by_type2 	varchar(40) = null,
	 @by_ref2	  varchar(40) = null,
	 @by_type3 	varchar(40) = null,
	 @by_ref3	  varchar(40) = null
)
as 
begin
set nocount on
declare @rowcount int

	 if @by_type0 = 'all'
	 begin
	    select
		     c.cmdty_code,
		     c.cmdty_tradeable_ind,
	    	 c.cmdty_type,
		     c.cmdty_status,
		     c.cmdty_short_name,
		     c.cmdty_full_name,
		     c.country_code,
		     c.cmdty_loc_desc,
		     c.prim_curr_code,
		     c.prim_curr_conv_rate,
		     c.trans_id
	    from dbo.commodity c
	    order by c.cmdty_short_name
	 end
	 else if (@by_type0 in ('CTI', 
	                        'tradeable_ind', 
	                        'tradeable', 
	                        'TA',
							            'cmdty_tradeable_ind'))
	 begin
	    select
		     c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id
		  from dbo.commodity c
			where c.cmdty_tradeable_ind = @by_ref0
	 end
   else if ((@by_type0 in ('status', 'ST', 'cmdty_status')) and 
            (@by_type1 is null))
	 begin
	    select
		     c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id
		  from dbo.commodity c
			where c.cmdty_status = @by_ref0
	 end
	 else if (@by_type0 in ('type', 'CT', 'cmdty_type') and
            @by_type1 is null)
	 begin
	    select
		     c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id
		  from dbo.commodity c
			where c.cmdty_type = @by_ref0
      order by c.cmdty_full_name
   end
   else if ((@by_type0 in ( 'CT', 'cmdty_type')) and
		        (@by_type1 in ( 'CT', 'cmdty_type')))
	 begin
	    select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id
      from dbo.commodity c
			where c.cmdty_type not in (@by_ref0, @by_ref1)
      order by c.cmdty_full_name
	 end
   else if ((@by_type0 in ('parent_cmdty_code')) and
            (@by_type1 in ('CT', 'cmdty_type')) and
            (@by_type2 in ('CT', 'cmdty_type')) and
            (@by_type3 in ('included')) and
            (@by_ref3 = 'y'))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id
      from dbo.commodity c,
           dbo.commodity_group cg
      where cg.parent_cmdty_code = @by_ref0 and   
            cg.cmdty_code = c.cmdty_code and   
            c.cmdty_type not in (@by_ref1, @by_ref2)
   end
   else if ((@by_type0 in ('parent_cmdty_code')) and
            (@by_type1 in ('CT', 'cmdty_type')) and
            (@by_type2 in ('CT', 'cmdty_type')) and
            (@by_type3 in ('included')) and
            (@by_ref3 = 'n'))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id 
      from dbo.commodity c,
			     dbo.commodity_group cg
      where cg.parent_cmdty_code != @by_ref0 and   
            cg.cmdty_code = c.cmdty_code and   
            c.cmdty_type not in (@by_ref1, @by_ref2)
   end
   else if ((@by_type0 in ('mkt_code', 'MC')) and
            (@by_type1 in ('cmdty_status', 'CS')) and
            (@by_type2 = 'included') and
            (@by_ref2 = 'y'))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id 
      from dbo.commodity  c,
           dbo.commodity_market cm
      where cm.mkt_code = @by_ref0 and   
            cm.cmdty_code = c.cmdty_code and   
            c.cmdty_status != @by_ref1
      order by c.cmdty_short_name
   end
   else if ((@by_type0 in ('mkt_code', 'MC')) and
            (@by_type1 in ('cmdty_status', 'CS')) and
            (@by_type2 = 'included') and
            (@by_ref2 = 'n'))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id 
      from dbo.commodity c
      where c.cmdty_status != @by_ref1 and   
            c.cmdty_code not in (select cm.cmdty_code
			                           from dbo.commodity_market cm
			                           where cm.mkt_code = @by_ref0)
 		  order by c.cmdty_short_name
   end
   else if ((@by_type0 in ('status', 'ST', 'cmdty_status')) and 
            (@by_type1 in ('status', 'ST', 'cmdty_status')))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id 
      from dbo.commodity c
      where c.cmdty_status in (@by_ref0, @by_ref1)
   end
   else if ((@by_type0 in ('CT', 'cmdty_type')) and
            (@by_type1 in ('CS', 'cmdty_status')) and
            (@by_type2 in ('CS', 'cmdty_status') or 
             @by_type2 is null))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id 
      from dbo.commodity c
      where c.cmdty_type = @by_ref0 and    
            ((c.cmdty_status = @by_ref1 and 
              @by_ref2 is null) or
              (c.cmdty_status in (@by_ref2, @by_ref3)))
   end
   else if ((@by_type0 in ('CT', 'cmdty_type')) and
		        (@by_type1 in ('CTI', 'cmdty_tradeable_ind')) and
            (@by_type2 in ('CS', 'cmdty_status')) and
            (@by_type3 in ('CS', 'cmdty_status') or @by_type3 is null))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id 
      from dbo.commodity c
      where c.cmdty_type = @by_ref0 and     
            c.cmdty_tradeable_ind = @by_ref1 and    
            ((c.cmdty_status = @by_ref2 and @by_ref3 is null) or
             (c.cmdty_status in (@by_ref2, @by_ref3)))
		  order by c.cmdty_short_name
   end
   else if ((@by_type0 in ('MT', 'mkt_type')) and
            (@by_type1 in ('status1')) and
            (@by_type2 in ('status2')))
   begin
      select
         c.cmdty_code,
         c.cmdty_tradeable_ind,
         c.cmdty_type,
         c.cmdty_status,
         c.cmdty_short_name,
         c.cmdty_full_name,
         c.country_code,
         c.cmdty_loc_desc,
         c.prim_curr_code,
         c.prim_curr_conv_rate,
         c.trans_id 
      from dbo.commodity c,
		       dbo.market m,
		       dbo.commodity_market cm
      where cm.mkt_code = m.mkt_code and	
            m.mkt_type = @by_ref0 and     
            m.mkt_status in (@by_ref1, @by_ref2) and     
            cm.cmdty_code = c.cmdty_code and     
            c.cmdty_status in (@by_ref1, @by_ref2)
		  order by c.cmdty_short_name
   end
   else 
      return 4

   set @rowcount = @@rowcount
   if (@rowcount = 1)
      return 0
   else if (@rowcount = 0)
      return 1
   else 
      return 2
end
GO
GRANT EXECUTE ON  [dbo].[find_commoditys] TO [next_usr]
GO

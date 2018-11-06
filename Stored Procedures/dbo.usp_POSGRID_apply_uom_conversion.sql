SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_POSGRID_apply_uom_conversion]
(
   @debugon      bit = 0
)                 
as                      
set nocount on
declare @smsg             varchar(800),
        @rows_affected    int,
        @time_started     varchar(20),
        @time_finished    varchar(20)
           
   create table #uomconv
   (
      from_uom_code           char(4),
      to_uom_code             char(4),
      cmdty_code              char(8),
      uom_conv_factor         float default 1.0
   )

   create table #uomconv1
   (
      from_uom_code           char(4),
      to_uom_code             char(4),
      cmdty_code              char(8),
      uom_conv_factor         float default 1.0
   )
	         	  
	 create nonclustered index xx0191_uomconv_idx1
	    on #uomconv (from_uom_code, to_uom_code, cmdty_code) 
	 create nonclustered index xx0191_uomconv1_idx1
	    on #uomconv1 (from_uom_code, to_uom_code, cmdty_code) 

   set @time_started = (select convert(varchar, getdate(), 109))
   begin try
	   update p                                                  
	   set quantity_in_MT = case when pos_qty_uom_code = 'MT' 
	                                then primary_pos_qty                      
		                           when secondary_qty_uom_code = 'MT' 
		                              then secondary_pos_qty 
		                      end                      
	   from #pos p                                                  
	   where pos_qty_uom_code = 'MT' or 
	         secondary_qty_uom_code = 'MT'                      
     select @rows_affected = @@rowcount
   end try
	 begin catch
	   set @smsg = '=> Failed to update quantity_in_MT in the #pos table due to the error:'
	   RAISERROR(@smsg, 0, 1) WITH NOWAIT
	   set @smsg = '==> ERROR: ' + ERROR_MESSAGE()
	   RAISERROR(@smsg, 0, 1) WITH NOWAIT
     return 1	   
	 end catch
	 if @debugon = 1
	 begin
      set @smsg = 'quantity_in_MT (update): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT  
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end

   set @time_started = (select convert(varchar, getdate(), 109))                  
   begin try
	   update p                                                  
	   set quantity_in_BBL = case when pos_qty_uom_code = 'BBL' 
	                                 then primary_pos_qty                      
		                            when secondary_qty_uom_code = 'BBL' 
		                               then secondary_pos_qty 
		                       end                      
	   from #pos p                                                  
	   where pos_qty_uom_code = 'BBL' or 
	         secondary_qty_uom_code = 'BBL'                      
     select @rows_affected = @@rowcount
   end try
	 begin catch
	   set @smsg = '=> Failed to update quantity_in_BBL in the #pos table due to the error:'
	   RAISERROR(@smsg, 0, 1) WITH NOWAIT
	   set @smsg = '==> ERROR: ' + ERROR_MESSAGE()
	   RAISERROR(@smsg, 0, 1) WITH NOWAIT
     return 1	   
	 end catch
	 if @debugon = 1
	 begin
      set @smsg = 'quantity_in_BBL (update): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT  
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end
   
   if exists (select 1 
              from #pos 
              where cmdty_group = 'METALS')    
   begin 
      set @time_started = (select convert(varchar, getdate(), 109))
      begin try
	      update p                                                  
	      set quantity_in_KG = case when pos_qty_uom_code = 'KG' 
	                                   then primary_pos_qty                      
		                              when secondary_qty_uom_code = 'KG' 
		                                 then secondary_pos_qty 
		                         end                      
	      from #pos p                                                  
	      where pos_qty_uom_code = 'KG' or 
	            secondary_qty_uom_code = 'KG'                      
        select @rows_affected = @@rowcount
      end try
	    begin catch
	      set @smsg = '=> Failed to update quantity_in_KG in the #pos table due to the error:'
	      RAISERROR(@smsg, 0, 1) WITH NOWAIT
	      set @smsg = '==> ERROR: ' + ERROR_MESSAGE()
	      RAISERROR(@smsg, 0, 1) WITH NOWAIT
        return 1	   
	    end catch
    	if @debugon = 1
	    begin
         set @smsg = 'quantity_in_KG (update): # of rows retrieved = ' + cast(@rows_affected as varchar) 
         RAISERROR(@smsg, 0, 1) WITH NOWAIT  
         set @time_finished = (select convert(varchar, getdate(), 109))
         set @smsg = '==> Started : ' + @time_started
         RAISERROR (@smsg, 0, 1) WITH NOWAIT
         set @smsg = '==> Finished: ' + @time_finished
         RAISERROR (@smsg, 0, 1) WITH NOWAIT     
      end
   end
                                                         

   /* ************************************************************************** */	                       
   set @time_started = (select convert(varchar, getdate(), 109))
   insert into #uomconv
     select pos_qty_uom_code, 'MT', cmdty_code, 1.0
     from #pos
     where pos_qty_uom_code is not null
     union all
     select pos_qty_uom_code, 'BBL', cmdty_code, 1.0
     from #pos
     where pos_qty_uom_code is not null
     union all  
     select secondary_qty_uom_code, 'MT', cmdty_code, 1.0
     from #pos
     where secondary_qty_uom_code is not null
     union all
     select secondary_qty_uom_code, 'BBL', cmdty_code, 1.0
     from #pos
     where secondary_qty_uom_code is not null
   set @rows_affected = @@rowcount
   if @debugon = 1
   begin
      RAISERROR ('Copying records into the #uomconv table', 0, 1) WITH NOWAIT
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end
   
   if exists (select 1 
              from #pos 
              where cmdty_group = 'METALS')    
   begin
      set @time_started = (select convert(varchar, getdate(), 109))
      insert into #uomconv
        select pos_qty_uom_code, 'KG', cmdty_code, 1.0
        from #pos
        where pos_qty_uom_code is not null
        union all
        select secondary_qty_uom_code, 'KG', cmdty_code, 1.0
        from #pos
        where secondary_qty_uom_code is not null
      set @rows_affected = @@rowcount
      if @debugon = 1
      begin
         RAISERROR ('Copying records into the #uomconv table for METALS', 0, 1) WITH NOWAIT
         set @time_finished = (select convert(varchar, getdate(), 109))
         set @smsg = '==> Started : ' + @time_started
         RAISERROR (@smsg, 0, 1) WITH NOWAIT
         set @smsg = '==> Finished: ' + @time_finished
         RAISERROR (@smsg, 0, 1) WITH NOWAIT     
      end
   end
   
   -- Using ROW_NUMBER() to make sure we have unique conversion rate for
   -- each (from_uom_code, to_uom_code, cmdty_code)
   set @time_started = (select convert(varchar, getdate(), 109))
   insert into #uomconv1
   select from_uom_code, 
          to_uom_code, 
          cmdty_code, 
          uom_conv_factor
   from (select 
            ROW_NUMBER() OVER (PARTITION BY from_uom_code, to_uom_code, cmdty_code 
                               ORDER BY from_uom_code, to_uom_code, cmdty_code) as ord, 
            from_uom_code, 
            to_uom_code, 
            cmdty_code, 
            uom_conv_factor
         from #uomconv) u
   where ord = 1 
   set @rows_affected = @@rowcount
   if @debugon = 1
   begin
      RAISERROR ('Copying records into the #uomconv1 table (removing duplicated records)', 0, 1) WITH NOWAIT
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end

   set @time_started = (select convert(varchar, getdate(), 109))
   update #uomconv1
   set uom_conv_factor = dbo.udf_uom_conv_rate(from_uom_code, to_uom_code, null, null, cmdty_code)
         
   set @time_started = (select convert(varchar, getdate(), 109))
	 update p                                                  
	 set quantity_in_MT = p.primary_pos_qty * u.uom_conv_factor 
	 from #pos p
	         left outer join #uomconv1 u
	            on p.pos_qty_uom_code = u.from_uom_code and
	               u.to_uom_code = 'MT' and
	               p.cmdty_code = u.cmdty_code                                              
	 where quantity_in_MT is null 
	 set @rows_affected = @@rowcount                                                 
	 if @debugon = 1
	 begin
      set @smsg = 'quantity_in_MT (primary_pos_qty - uom conversion): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT  
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end
                      
   set @time_started = (select convert(varchar, getdate(), 109))
	 update p                                                  
	 set quantity_in_BBL = p.primary_pos_qty * u.uom_conv_factor 
	 from #pos p
	         left outer join #uomconv1 u
	            on p.pos_qty_uom_code = u.from_uom_code and
	               u.to_uom_code = 'BBL' and
	               p.cmdty_code = u.cmdty_code                                              
	 where quantity_in_BBL is null                                                  
	 set @rows_affected = @@rowcount                                                 
	 if @debugon = 1
	 begin
      set @smsg = 'quantity_in_BBL (primary_pos_qty - uom conversion): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT  
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end
   
   if exists (select 1 
              from #pos 
              where cmdty_group = 'METALS')    
   begin
      set @time_started = (select convert(varchar, getdate(), 109))
	    update p                                                  
	    set quantity_in_KG = p.primary_pos_qty * u.uom_conv_factor 
	    from #pos p
	            left outer join #uomconv1 u
	               on p.pos_qty_uom_code = u.from_uom_code and
	                  u.to_uom_code = 'KG' and
	                  p.cmdty_code = u.cmdty_code                                              
	    where quantity_in_KG is null                                                  
	    set @rows_affected = @@rowcount                                                 
   	  if @debugon = 1
	    begin
         set @smsg = 'quantity_in_KG (primary_pos_qty - uom conversion): # of rows retrieved = ' + cast(@rows_affected as varchar) 
         RAISERROR(@smsg, 0, 1) WITH NOWAIT  
         set @time_finished = (select convert(varchar, getdate(), 109))
         set @smsg = '==> Started : ' + @time_started
         RAISERROR (@smsg, 0, 1) WITH NOWAIT
         set @smsg = '==> Finished: ' + @time_finished
         RAISERROR (@smsg, 0, 1) WITH NOWAIT     
      end
   end
           
   /* ********** */            
   set @time_started = (select convert(varchar, getdate(), 109))
	 update p                                                  
	 set quantity_in_MT = p.secondary_pos_qty * u.uom_conv_factor 
	 from #pos p
	         left outer join #uomconv1 u
	            on p.secondary_qty_uom_code = u.from_uom_code and
	               u.to_uom_code = 'MT' and
	               p.cmdty_code = u.cmdty_code                                              
	 where quantity_in_MT is null                                                  
	 set @rows_affected = @@rowcount                                                 
	 if @debugon = 1
	 begin
      set @smsg = 'quantity_in_MT (secondary_pos_qty - uom conversion): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT  
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end
                      
   set @time_started = (select convert(varchar, getdate(), 109))
	 update p                                                  
	 set quantity_in_BBL = p.secondary_pos_qty * u.uom_conv_factor 
	 from #pos p
	         left outer join #uomconv1 u
	            on p.secondary_qty_uom_code = u.from_uom_code and
	               u.to_uom_code = 'BBL' and
	               p.cmdty_code = u.cmdty_code                                              
	 where quantity_in_BBL is null     
	 set @rows_affected = @@rowcount                                                 
	 if @debugon = 1
	 begin
      set @smsg = 'quantity_in_BBL (secondary_pos_qty - uom conversion): # of rows retrieved = ' + cast(@rows_affected as varchar) 
      RAISERROR(@smsg, 0, 1) WITH NOWAIT  
      set @time_finished = (select convert(varchar, getdate(), 109))
      set @smsg = '==> Started : ' + @time_started
      RAISERROR (@smsg, 0, 1) WITH NOWAIT
      set @smsg = '==> Finished: ' + @time_finished
      RAISERROR (@smsg, 0, 1) WITH NOWAIT     
   end
   
   if exists (select 1 
              from #pos 
              where cmdty_group = 'METALS')    
   begin
      set @time_started = (select convert(varchar, getdate(), 109))
	    update p                                                  
	    set quantity_in_KG = p.secondary_pos_qty * u.uom_conv_factor 
	    from #pos p
	            left outer join #uomconv1 u
	               on p.secondary_qty_uom_code = u.from_uom_code and
	                  u.to_uom_code = 'KG' and
	                  p.cmdty_code = u.cmdty_code                                              
	    where quantity_in_KG is null     
	    set @rows_affected = @@rowcount                                                 
   	  if @debugon = 1
	    begin
         set @smsg = 'quantity_in_KG (secondary_pos_qty - uom conversion): # of rows retrieved = ' + cast(@rows_affected as varchar) 
         RAISERROR(@smsg, 0, 1) WITH NOWAIT  
         set @time_finished = (select convert(varchar, getdate(), 109))
         set @smsg = '==> Started : ' + @time_started
         RAISERROR (@smsg, 0, 1) WITH NOWAIT
         set @smsg = '==> Finished: ' + @time_finished
         RAISERROR (@smsg, 0, 1) WITH NOWAIT     
      end
   end
   
endofsp:
if object_id('tempdb..#uomconv', 'U') is not null
   exec('drop table #uomconv')
if object_id('tempdb..#uomconv1', 'U') is not null
   exec('drop table #uomconv1') 
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_apply_uom_conversion] TO [next_usr]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_inv_roll_position] 
(
   @pl_asof_date         datetime = null,  
   @top_port_num         int = 0,  
   @debugon              bit = 0  
)
as  
set nocount on  
declare @rows_affected     int,  
        @smsg              varchar(255),  
        @status            int,  
        @oid               numeric(18, 0),  
        @stepid            smallint,  
        @my_pl_asof_date   datetime,  
        @my_port_num       int  
  
   select @my_pl_asof_date = @pl_asof_date,  
          @my_port_num = @top_port_num
              
   if @debugon = 1  
   begin  
      declare @times   table
      (
         oid                int,
         step               varchar(80),
         starttime          datetime null,
         endtime            datetime null,
         rows_affected      int default -1 null
      )
   end  
  
   declare @port_num_list table 
   (
      real_port_num     int 
   )

   insert into @port_num_list
   select port_num 
   from dbo.udf_RVFile_child_port_nums(@my_port_num)
   where port_type = 'R'
   select @rows_affected = @@rowcount  
  
   if @rows_affected > 0  
   begin    
      if @debugon = 1  
      begin  
         print ' '  
         print '***************************************'  
         print ' real_port_nums'  
         print '---------------------------------------'  
         select real_port_num from @port_num_list order by real_port_num       
      end   
   end  
   else  
   begin  
      print 'No real port_nums found!'  
      goto endofsp  
   end  
  
   create table #plh  
   (  
      oid                     numeric(18, 0) IDENTITY,  
      pl_record_key           int null,  
      pl_asof_date            datetime null,  
      pl_real_port_num        int null,  
      pl_owner_code           char(8) null,  
      pl_type                 char(8) null,  
      pl_trans_id             bigint null,  
      inv_trans_id            bigint null  
   )  
    
   select @stepid = 0  
   /* -----------------------------------------------  
       STEP: Copying rows into #plh table  
      ----------------------------------------------- */     
   select @stepid = @stepid + 1  
   if @debugon = 1  
      insert into @times   
         (oid, step, starttime)  
        values(@stepid, 'Copying rows into #plh table', getdate())  
  
   insert into #plh  
   (  
      pl_record_key,  
      pl_asof_date,  
      pl_real_port_num,  
      pl_owner_code,  
      pl_type,  
      pl_trans_id  
   )  
   select plh.pl_record_key,  
          plh.pl_asof_date,  
          plh.real_port_num,  
          plh.pl_owner_code,  
          plh.pl_type,  
          plh.trans_id  
   from dbo.pl_history plh WITH (NOLOCK)
   where plh.pl_asof_date <= @my_pl_asof_date AND   
         exists (select 1  
                 from @port_num_list port  
                 where plh.real_port_num = port.real_port_num) AND  
         plh.pl_owner_code = 'P' AND  
         plh.pl_type = 'U'  
   select @rows_affected = @@rowcount  
   if @debugon = 1  
   begin  
      update @times   
      set endtime = getdate(),  
          rows_affected = @rows_affected  
      where oid = @stepid  
   end  
  
   if @rows_affected <= 0  
   begin  
      if @debugon = 1   
      begin  
         print 'No pl_history records found!'  
      end  
      goto endofsp  
   end  

   create nonclustered index xx_plh_xx_idx1  
      on #plh(pl_record_key,pl_real_port_num,pl_owner_code, pl_asof_date)  

    /* ------------------------------------------------------------ 
        STEP: Filtering pl_history rows, where 
                asof_date < max(pl_asof_date) < max(pl_asof_date)
       -------------------------------------------------------------- */  
   select @stepid = @stepid + 1  
   if @debugon = 1   
      insert into @times   
         (oid, step, starttime)  
        values(@stepid, 'Filtering pl_history rows', getdate())  

   create table #plh1  
   (  
      pl_record_key           int,  
      pl_asof_date            datetime  
   )  
  
   insert into #plh1
   (  
      pl_record_key,  
      pl_asof_date 
   )  
   select a.pl_record_key,  
          max(a.pl_asof_date)
   from #plh1 a  
   where a.pl_asof_date < (select max(b.pl_asof_date) 
			                     from #plh b
			                    where a.pl_record_key = b.pl_record_key and 
				                        b.pl_asof_date < @my_pl_asof_date) 
   group by a.pl_record_key
   
   select @rows_affected = @@rowcount  
   if @debugon = 1  
   begin  
      update @times   
      set endtime = getdate(),  
          rows_affected = @rows_affected  
      where oid = @stepid  
   end  
  
   if @debugon = 1   
   begin  
      print 'Filtering pl_history rows, where asof_date < max(pl_asof_date) < max(pl_asof_date)'  
   end  

   create nonclustered index xx_plh1_xx_idx1  
      on #plh1(pl_record_key, pl_asof_date)  

  /* -------------------------------------------------  
     STEP: Removing positions which were rolled on 
           asofDate before we ran this  
     ------------------------------------------------- */  
   select @stepid = @stepid + 1  
   if @debugon = 1   
      insert into @times   
         (oid, step, starttime)  
        values(@stepid, 'Rremoving positions which were rolled on asofDate before we ran this', getdate())  

   delete #plh   
   from #plh plh  
   where pl_asof_date = @my_pl_asof_date AND
	       not exists (select 1 
                     from (select pos_num,
                                  open_close_ind,
                                  trans_id
                           from dbo.inventory WITH (NOLOCK)
                           union
                           select pos_num,
                                  open_close_ind,
                                  trans_id
                           from dbo.aud_inventory WITH (NOLOCK)) inv  
                     where pos_num = plh.pl_record_key and 
                           open_close_ind = 'O' and 
                           trans_id >= (select isnull(max(pl_trans_id), 0)
				                                from #plh a, #plh1 b
					                              where a.pl_record_key = inv.pos_num and
					                                    a.pl_record_key = b.pl_record_key and
					                                    a.pl_asof_date = b.pl_asof_date)
                   )  
   select @rows_affected = @@rowcount  
   if @debugon = 1  
   begin  
      update @times   
      set endtime = getdate(),  
          rows_affected = @rows_affected  
      where oid = @stepid  
   end  
   drop table #plh1		     
   
   /* -------------------------------------------------  
       STEP: Getting inventory information  
      ------------------------------------------------- */     
   select @stepid = @stepid + 1  
   if @debugon = 1   
      insert into @times   
         (oid, step, starttime)  
        values(@stepid, 'Getting inventory information', getdate())  
  
   create table #invs  
   (  
      inv_num           int not null,  
      pos_num           int not null,  
      port_num          int null,  
      prev_inv_num      int null,
      next_inv_num      int null,
      rolled_to_pos_num int null,
      trans_id          bigint null,  
      pl_trans_id       bigint null  
   )  
   
   insert into #invs  
   select i.inv_num,  
          i.pos_num,  
          i.port_num,  
          i.prev_inv_num,
          i.next_inv_num,
          (select i2.pos_num
           from dbo.inventory i2 WITH (NOLOCK)
           where i.next_inv_num = i2.inv_num),
          i.trans_id,  
          plh.pl_trans_id  
   from dbo.inventory i WITH (NOLOCK),  
        #plh plh  
   where plh.pl_asof_date = @my_pl_asof_date AND
	       i.pos_num = plh.pl_record_key AND     
         i.port_num = plh.pl_real_port_num AND  
         i.open_close_ind = 'R' AND   
         i.trans_id <= plh.pl_trans_id
   union  
   select i.inv_num,  
          i.pos_num,  
          i.port_num,    
          i.prev_inv_num,
          i.next_inv_num,
          (select i2.pos_num
           from dbo.inventory i2 WITH (NOLOCK)
           where i.next_inv_num = i2.inv_num),
          i.trans_id,  
          plh.pl_trans_id  
   from dbo.aud_inventory i WITH (NOLOCK),  
        #plh plh  
   where plh.pl_asof_date = @my_pl_asof_date AND
	       i.pos_num = plh.pl_record_key AND      
         i.port_num = plh.pl_real_port_num AND   
         i.open_close_ind = 'R' AND  
         i.trans_id <= plh.pl_trans_id
   select @rows_affected = @@rowcount  
   if @debugon = 1   
   begin  
      update @times  
      set endtime = getdate(),  
          rows_affected = @rows_affected   
      where oid = @stepid  
   end  

   create nonclustered index xx_878_inv_idx1  
      on #invs(pos_num, trans_id)  
   
   if @rows_affected > 0  
   begin  
      /* -----------------------------------------------  
          STEP: Updating inv_trans_id in #plh  
         ----------------------------------------------- */     
      select @stepid = @stepid + 1  
      if @debugon = 1   
         insert into @times   
            (oid, step, starttime)  
           values(@stepid, 'Updating inv_trans_id in #plh', getdate())  
  
      update #plh  
      set inv_trans_id = (select max(trans_id)  
                          from #invs i      
                          where i.pos_num = #plh.pl_record_key AND  
                                i.port_num = #plh.pl_real_port_num)      
      select @rows_affected = @@rowcount  
      if @debugon = 1  
      begin  
         update @times  
         set endtime = getdate(),  
             rows_affected = @rows_affected   
         where oid = @stepid  
      end  
   end  
  
   /* -----------------------------------------------  
       STEP: Returns data back to caller  
      ----------------------------------------------- */     
   select @stepid = @stepid + 1  
   if @debugon = 1  
      insert into @times   
         (oid, step, starttime)          
        values(@stepid, 'Return result set', getdate())  
  
   select distinct  
      plh.pl_record_key,
      inv.prev_inv_num,
      inv.next_inv_num,
      inv.rolled_to_pos_num
   from #plh plh,   
        #invs inv  
   where plh.pl_asof_date = @my_pl_asof_date AND
	       inv.pos_num = plh.pl_record_key AND  
         inv.trans_id = plh.inv_trans_id AND  
         inv.port_num = plh.pl_real_port_num   
   order by pl_record_key    
   select @rows_affected = @@rowcount  
   if @debugon = 1  
   begin  
      update @times  
      set endtime = getdate(),  
          rows_affected = @rows_affected  
      where oid = @stepid  
   end  
  
   if @debugon = 1  
   begin  
      print ' '  
      select @smsg = 'usp_RVFile_inv_roll_position: ' + convert(varchar, @rows_affected) + ' rows returned.'  
      print @smsg  
      print ' '  
  
      declare @step       varchar(80),  
              @starttime  varchar(30),  
              @endtime    varchar(30)  
  
      select @oid = min(oid)  
      from @times  
  
      while @oid is not null  
      begin  
         select @step = step,  
                @starttime = convert(varchar, starttime, 109),  
                @endtime = convert(varchar, endtime, 109),  
                @rows_affected = rows_affected  
         from @times  
         where oid = @oid  
  
         select @smsg = convert(varchar, @oid) + '. ' + @step  
         print @smsg  
         select @smsg = '    STARTED  AT  : ' + @starttime  
         print @smsg         
         select @smsg = '    FINISHED AT  : ' + @endtime  
         print @smsg  
         select @smsg = '    ROWS AFFECTED: ' + convert(varchar, @rows_affected)  
         print @smsg  
           
         select @oid = min(oid)  
         from @times  
         where oid > @oid  
      end /* while */  
   end /* debug */  
   drop table #invs  
  
endofsp:  
drop table #plh  
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_inv_roll_position] TO [next_usr]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_pipeline_year_cycle]
(
   @debugon              bit = 0,
   @pipeline_cycle_num   int = null,
   @year_num             smallint = null
)
as
set nocount on
declare @a_year_num        smallint,
        @last_year_num     smallint,
        @mot_code          char(8),
        @rows_affected     int,
        @errcode           int,
        @last_oid          numeric(18, 0)

   if @pipeline_cycle_num = 0
      select @pipeline_cycle_num = null

   if @year_num = 0
      select @year_num = null
      
   select @rows_affected = 0,
          @errcode = 0,
          @last_oid = 0

   -- The pipeline_cycle records for a pipeline may not be loaded
   -- in their chronical orders. So, copy these records to the
   -- following temporary table and order them by   
   --       mot_code, cycle_start_date       
   create table #pipeline_cycles
   (
      oid                   numeric(18, 0) IDENTITY,
      mot_code              char(8) null,
      year_num              smallint null,
      pipeline_cycle_num    int default 0 null,
      trans_id              int not null
   )
   select @errcode = @@error
   if @errcode > 0
      return
          
   create table #cycles
   (
      mot_code              char(8) null,
      year_num              smallint null,
      pipeline_cycle_num    int default 0 null,
      trans_id              int null,
      oid                   numeric(18, 0)
   )
   select @errcode = @@error
   if @errcode > 0
   begin
      drop table #pipeline_cycles
      return
   end
   
   create table #mot_year_nums
   (
      mot_code              char(8) null,
      year_num              smallint null,
      last_oid              numeric(18, 0) default 0
   )
   select @errcode = @@error
   if @errcode > 0
   begin
      drop table #cycles
      return
   end

   insert into #pipeline_cycles 
       (mot_code, year_num, pipeline_cycle_num, trans_id)
     select mot_code, year(cycle_start_date), pipeline_cycle_num, trans_id
     from pipeline_cycle
     order by mot_code, cycle_start_date
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
      goto endofsp
   if @rows_affected = 0
   begin
      if @debugon = 1
      begin
         print 'No pipeline_cycle records found!'
         goto endofsp         
      end
   end   

   insert into #mot_year_nums
         (mot_code, year_num)
     select pc.mot_code, 
            gdv.int_value
     from generic_data_values gdv, 
          generic_data_definition gdd, 
          generic_data_name gdn, 
          (select distinct mot_code 
           from pipeline_cycle) pc
     where gdn.data_name = "pipeline cycle year" and
           gdd.gdn_num = gdn.gdn_num and
           gdv.gdd_num = gdd.gdd_num
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
      goto endofsp
      
   if @rows_affected = 0
   begin
      if @debugon = 1
      begin
         print 'No GDN/GDD/GDV records were setup for PIPELINE CYCLE!'
         goto endofsp         
      end
   end   

   select @mot_code = min(mot_code)
   from #mot_year_nums
   
   while @mot_code is not null
   begin
      select @a_year_num = min(year_num)
      from #mot_year_nums
      where mot_code = @mot_code 
   
      while @a_year_num is not null
      begin  
         if exists (select 1
                    from #pipeline_cycles
                    where mot_code = @mot_code and
                          year_num = @a_year_num)
         begin
            insert into #cycles (mot_code, year_num, pipeline_cycle_num, trans_id, oid)
            select @mot_code, 
                   @a_year_num,
                   pipeline_cycle_num,
                   trans_id,
                   oid
            from #pipeline_cycles pc
            where mot_code = @mot_code and
                  year_num = @a_year_num
            select @errcode = @@error
            if @errcode > 0
               goto endofsp 
            update #mot_year_nums
            set last_oid = (select max(oid)
                            from #cycles
                            where mot_code = @mot_code)
            where mot_code = @mot_code and
                  year_num = @a_year_num           
         end
         else
         begin
            select @last_oid = isnull(max(last_oid), 0)
            from #mot_year_nums
            where mot_code = @mot_code and
                  year_num < @a_year_num
                  
            insert into #cycles (mot_code, year_num, pipeline_cycle_num, trans_id, oid)
            select @mot_code, 
                   @a_year_num,
                   pipeline_cycle_num,
                   trans_id,
                   oid
            from #pipeline_cycles pc
            where mot_code = @mot_code and
                  year_num < @a_year_num and
                  oid > @last_oid
            select @errcode = @@error
            if @errcode > 0
               goto endofsp            
         end
                          
         select @a_year_num = min(year_num)
         from #mot_year_nums
         where mot_code = @mot_code and
               year_num > @a_year_num
      end /* while */

      select @last_year_num = max(year_num)
      from #mot_year_nums
      where mot_code = @mot_code

      if not exists (select 1
                     from #pipeline_cycles
                     where mot_code = @mot_code and
                           year_num = @last_year_num)
      begin     
         insert into #cycles (mot_code, year_num, pipeline_cycle_num, trans_id, oid)
         select @mot_code, 
                @last_year_num,
                pipeline_cycle_num,
                trans_id,
                oid
         from #pipeline_cycles pc
         where mot_code = @mot_code and
               year_num > @last_year_num and
               oid > (select isnull(max(oid), 0)
                      from #cycles
                      where mot_code = @mot_code)
         select @errcode = @@error
         if @errcode > 0
            goto endofsp            
      end
      
      select @mot_code = min(mot_code)
      from #mot_year_nums
      where mot_code > @mot_code
   end /* while */

   if @year_num is null or @pipeline_cycle_num is null
      select mot_code,
             pipeline_cycle_num,
             trans_id,
             year_num
      from #cycles
   else
      select mot_code,
             pipeline_cycle_num,
             trans_id,
             year_num
      from #cycles
      where year_num = @year_num and
            pipeline_cycle_num = @pipeline_cycle_num 
   goto endofsp1

endofsp:
   -- force to return NOTHING
   select mot_code,
          pipeline_cycle_num,
          trans_id,
          year_num
   from #cycles
   where trans_id = -1

endofsp1:
   drop table #pipeline_cycles
   drop table #mot_year_nums
   drop table #cycles
return
GO
GRANT EXECUTE ON  [dbo].[usp_pipeline_year_cycle] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_pipeline_year_cycle', NULL, NULL
GO

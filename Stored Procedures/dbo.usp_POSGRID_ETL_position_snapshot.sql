SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_POSGRID_ETL_position_snapshot]                 
as                  
declare @pl_asof_date datetime, 
        @trans_id     int                  
                  
   create table #COB                  
   (
      pos_num       int,                 
      asof_date     datetime,               
      long_qty      float null,            
      short_qty     float null,    
      qty_uom_code  char(4) null,            
      trans_id      int                  
   )                  

   -- Creating the temp table #LIVE by cloning the table layout from the POSGRID_snapshot_pos_detail table
   select * into #LIVE
   from dbo.POSGRID_snapshot_pos_detail 
   where 1 = 2                         
                  
   set @trans_id = 1        
   select @trans_id = case when config_value is null then 1
                           when len(config_value) = 0 then 1
                           else cast(config_value as int)
                      end 
   from dbo.dashboard_configuration
   where config_name = 'LastPositionSnapshotTransId'
      
   exec dbo.usp_POSGRID_roll_COB_date
              
   select @pl_asof_date = case when config_value is null then '01/01/1900'
                               when len(config_value) = 0 then '01/01/1900'
                               else config_value
                          end 
   from dbo.dashboard_configuration
   where config_name = 'MostRecentCOBDate'
              
   -- Fetching the position_history records which are new records or have been changed since the
   -- last snapshot, save these records into #COB             
   insert into #COB                  
   select pos_num, 
          asof_date, 
          isnull(long_qty, 0), 
          isnull(short_qty, 0), 
          qty_uom_code, 
          trans_id                
   from dbo.position_history ph              
   where asof_date = @pl_asof_date and 
         trans_id >= @trans_id and 
         last_frozen_ind = 'N'          
  
   create index xx19810_COB_idx1 on #COB (pos_num, asof_date)
      include (long_qty, short_qty, qtu_uom_code, trans_id)  

   create index xx19810_LIVE_idx1 on #LIVE (pos_num)
      include (trans_id)  
  
   -- Removing the records from #COB if the associated records in the POSGRID_snapshot_pos_summary table do not show
   -- changes on long_qty and short_qty
   delete cob            
   from #COB cob            
   where exists (select 1     
                 from dbo.POSGRID_snapshot_pos_summary tcob     
                 where cob.pos_num = tcob.pos_num and 
                       cob.asof_date = tcob.asof_date and 
                       round(isnull(cob.long_qty, 0), 0) - round(isnull(tcob.long_qty, 0), 0) = 0 and 
                       round(isnull(cob.short_qty, 0), 0) - round(isnull(tcob.short_qty, 0), 0) = 0 and 
                       cob.qty_uom_code = tcob.qty_uom_code)    
    
   -- Taking a LIVE position snapshot                      
   insert into #LIVE                  
   select @pl_asof_date, p.*              
   from dbo.v_POSGRID_risk_position p              
   where exists (select 1
                 from #COB cob
                 where p.pos_num = cob.pos_num)
  
   -- Deleting records from #COB if these records have been changed (in other words, they apppear in #LIVE with greater trans_ids)          
   delete cob            
   from #COB cob            
   where exists (select 1 
                 from #LIVE live            
                 where live.pos_num = cob.pos_num and 
                       cob.trans_id <= live.trans_id)          
   
   -- Removing records from #LIVE if they do not have associated pos_num(s) in #COB                  
   delete live              
   from #LIVE live              
   where not exists (select 1 
                     from #COB cob 
                     where cob.pos_num = live.pos_num)              

   -- Deleting old records from the POSGRID_snapshot_pos_detail table   
   -- if their (pos_num, asof_date) exists in #COB         
   delete p
   from dbo.POSGRID_snapshot_pos_detail p 
   where asof_date = @pl_asof_date and 
         exists (select 1
                 from #COB cob
                 where p.pos_num = cob.pos_num)
                        
   insert into dbo.POSGRID_snapshot_pos_detail                  
   select p.* 
   from #LIVE p
   where exists (select 1
                 from #COB cob
                 where p.pos_num = cob.pos_num)
                                           
   -- Deleting old records for the @pl_asof_date                  
   delete tcob     
   from dbo.POSGRID_snapshot_pos_summary tcob    
   where asof_date = @pl_asof_date and 
         exists (select 1 
                 from #COB cob 
                 where tcob.pos_num = cob.pos_num)    
    
   -- Adding new records for the @pl_asof_date
   insert into dbo.POSGRID_snapshot_pos_summary 
   select pos_num, asof_date, long_qty, short_qty, qty_uom_code, trans_id 
   from #COB    

   -- Saving the "last" trans_id in new snapshot
   select @trans_id = max(isnull(trans_id, 1)) 
   from dbo.POSGRID_snapshot_pos_detail 
   where asof_date = @pl_asof_date                   

   update dbo.dashboard_configuration
   set config_value = cast(@trans_id as varchar)
   where config_name = 'LastPositionSnapshotTransId'
                                                           
endofsp:
if object_id('tempdb..#LIVE', 'U') is not null
   exec('drop table #LIVE')
if object_id('tempdb..#COB', 'U') is not null
   exec('drop table #COB')
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_ETL_position_snapshot] TO [next_usr]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_POSGRID_roll_COB_date]
AS
declare @cob_date         datetime,
        @portfolio_list   varchar(2000),
        @sql              varchar(max),
        @snapshot_date    datetime,
        @yyyy             int,
        @mm               tinyint
   
   create table #cobdate
   (
      cob_date          datetime
   )
   
   select @portfolio_list = ''
   select @portfolio_list = isnull(config_value, '')
   from dbo.dashboard_configuration
   where config_name = 'PortfolioListForRollingCOBDate'

   set @sql = 'select max(pl_asof_date) from dbo.portfolio_profit_loss '
   if len(@portfolio_list) > 0
      set @sql = @sql + 'where port_num in (' + @portfolio_list + ')'  
   
   insert into #cobdate
      exec(@sql)

   select @cob_date = cob_date
   from #cobdate
   	
	 update dbo.dashboard_configuration 
	 set config_value = convert(varchar, @cob_date, 101)
	 where config_name = 'MostRecentCOBDate'

   select @snapshot_date = config_value
	 from dbo.dashboard_configuration 
	 where config_name = 'CurrentPositionSnapshotDate'

	 update dbo.dashboard_configuration 
	 set config_value = @snapshot_date
	 where config_name = 'PreviousPositionSnapshotDate'

   set @snapshot_date = (select GETDATE())
	 update dbo.dashboard_configuration 
	 set config_value = convert(varchar, @snapshot_date, 101)
	 where config_name = 'CurrentPositionSnapshotDate'

   set @yyyy = Year(@snapshot_date)
   set @mm = Month(@snapshot_date)
	 update dbo.dashboard_configuration
	 set config_value = (select cast(@yyyy as varchar) + 
                                  case when @mm < 10 then '0' 
                                       else ''
                                  end + cast(@mm as varchar))
	 where config_name = 'CurrentPositionSnapshotYearMonth'
	 
	 drop table #cobdate
GO
GRANT EXECUTE ON  [dbo].[usp_POSGRID_roll_COB_date] TO [next_usr]
GO

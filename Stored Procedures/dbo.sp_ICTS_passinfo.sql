SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[sp_ICTS_passinfo]
as
set nocount on

select Host = hostname, 
       Program = convert(char(7), program_name), 
       HostID# = hostprocess,
       SPID = spid, 
       Command = cmd
from master..sysprocesses
where (upper(program_name) like '%PASS%') and 
      dbid = db_id('dba_trade')
order by hostname desc
return
GO
GRANT EXECUTE ON  [dbo].[sp_ICTS_passinfo] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'sp_ICTS_passinfo', NULL, NULL
GO

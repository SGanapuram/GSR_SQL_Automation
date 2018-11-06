SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[CheckALSrun]
as
set nocount on
set ANSI_WARNINGS OFF 
declare @rc                     int

   create table #mytable
   (
       als_module_group_desc     varchar(40),
       first_sequence            numeric(32, 0) null,
       last_sequence             numeric(32, 0) null,
       behind                    numeric(32, 0) default 0 null
   )

   insert into #mytable
   select 
      a.als_module_group_desc,
      b.firstSeq, 
      b.lastSeq, 
      isnull(b.behind, 0)
   from dbo.server_config a WITH (NOLOCK)
           left outer join (select b.als_module_group_id, 
                                   min(b.sequence) 'firstSeq' , 
                                   max(b.sequence) 'lastSeq',
                                   count(*) 'behind'            
                            from dbo.als_run b
                            where b.als_run_status_id in (select als_run_status_id
                                                          from dbo.als_run_status WITH (NOLOCK)
                                                          where als_run_status_desc in ('WORKING', 'PENDING'))
                            group by b.als_module_group_id) b
              on a.als_module_group_id = b.als_module_group_id 
    order by a.als_module_group_desc 
                                          
   select @rc = @@rowcount
   if @rc = 0
      return 1

   update #mytable
   set first_sequence = (select min(sequence)
                         from dbo.als_run b,
                              dbo.server_config a WITH (NOLOCK)
                         where a.als_module_group_desc = #mytable.als_module_group_desc and
                               a.als_module_group_id = b.als_module_group_id and
                               b.als_run_status_id in (select als_run_status_id
                                                       from dbo.als_run_status WITH (NOLOCK)
                                                       where als_run_status_desc not in ('WORKING', 'PENDING'))),
      last_sequence = (select max(sequence)
                       from dbo.als_run b,
                            dbo.server_config a WITH (NOLOCK)
                       where a.als_module_group_desc = #mytable.als_module_group_desc and
                             a.als_module_group_id = b.als_module_group_id and
                             b.als_run_status_id in (select als_run_status_id
                                                     from dbo.als_run_status WITH (NOLOCK)
                                                     where als_run_status_desc not in ('WORKING', 'PENDING'))),
      behind = 0
   where first_sequence is null

   declare @maxTransID   numeric(32, 0)

   select @maxTransID = max(trans_id)
   from dbo.icts_transaction WITH (NOLOCK)

   select als_module_group_desc 'ALS Module',
          convert(char(15), first_sequence) 'First seq #',
          convert(char(15), last_sequence) 'Last seq #',
          convert(char(15), behind) 'Behind',
          getdate() 'Snapshot Time',
          @maxTransID 'Max Trans ID'
   from #mytable
   order by als_module_group_desc
   drop table #mytable
   return 0

reportusage:
   print ' '
   print 'Usage: exec dbo.CheckALSrun'
   return 2
GO
GRANT EXECUTE ON  [dbo].[CheckALSrun] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'CheckALSrun', NULL, NULL
GO

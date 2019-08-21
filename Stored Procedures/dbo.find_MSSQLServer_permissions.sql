SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_MSSQLServer_permissions]
(
   @by_type0    varchar(40) = null,
   @by_ref0     varchar(255) = null
)
as
begin
set nocount on
declare @rowcount    int,
        @object_name varchar(32),
        @protecttype tinyint

   if (@by_type0 is null or @by_ref0 is null)
      return 4

   set @protecttype = 99
   set @object_name = substring(@by_ref0, 1, 32)

   if substring(@by_type0, 1, 1) = 'G' or substring(@by_type0, 1, 1) = 'g'
      set @protecttype = 205
   
   if substring(@by_type0, 1, 1) = 'R' or substring(@by_type0, 1, 1) = 'r'
      set @protecttype = 206

   if @protecttype = 99
   begin
      print 'Usage: exec find_MSSQLServer_permission @by_type0 = ''<either GRANT or REVOKE>'', @by_ref0 = ''<a object name>''.'
      return
   end

   if not exists (select 1 
                  from sys.objects 
                  where name = @object_name)
      return 1

   declare @uid smallint, 
           @gid smallint

   select @uid = usr.uid, 
          @gid = usr.gid 
   from master.sys.sysprocesses ps, 
        sys.sysusers usr 
   where ps.spid = @@spid and
         ps.uid = usr.uid
   
   select distinct upper(sptv.name)
   from sys.sysprotects s, 
        master.dbo.spt_values sptv
   where s.uid in (@uid, @gid) and
	       s.id = object_id(@object_name) and
	       s.protecttype = @protecttype and
	       s.action = sptv.number and 
         sptv.type = 'T'
   order by upper(sptv.name)
   set @rowcount = @@rowcount
   if (@rowcount = 1)
      return 0
   else
      if (@rowcount = 0)
	       return 1
      else
	       return 2
end
GO
GRANT EXECUTE ON  [dbo].[find_MSSQLServer_permissions] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[find_MSSQLServer_permissions] TO [next_usr]
GO

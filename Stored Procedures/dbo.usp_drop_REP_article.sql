SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_drop_REP_article]
(
   @objname        sysname,
   @debugon        bit = 0
)
as
set nocount on
declare @dbname        sysname,
        @pubid         int,
        @pubdesc       varchar(512),
        @pubname       sysname,
        @objtype       char(2)

   select @dbname = db_name()
   if not exists (select 1
                  from sys.objects
                  where name = @objname)
      goto endofsp
    
      
   if @objtype is null
   begin
      print 'You must provide an object name which exists in database!'
      goto usage
   end
   if not exists (select 1 
                  from master.sys.databases 
                  where name = @dbname and 
                        is_published = 1)
      goto endofsp


   if @debugon = 1
      print 'The database ''' + @dbname + ''' is a publication database!'
   select @pubdesc = '%''' + db_name() + '''%'
      
   /*
      Object type (SQL 2005):
         AF = Aggregate function (CLR)
         C = CHECK constraint
         D = DEFAULT (constraint or stand-alone)
         F = FOREIGN KEY constraint
         PK = PRIMARY KEY constraint
         P = SQL stored procedure
         PC = Assembly (CLR) stored procedure
         FN = SQL scalar function
         FS = Assembly (CLR) scalar function
         FT = Assembly (CLR) table-valued function
         R = Rule (old-style, stand-alone)
         RF = Replication-filter-procedure
         SN = Synonym
         SQ = Service queue
         TA = Assembly (CLR) DML trigger
         TR = SQL DML trigger 
         IF = SQL inlined table-valued function
         TF = SQL table-valued-function
         U = Table (user-defined)
         UQ = UNIQUE constraint
         V = View
         X = Extended stored procedure
         IT = Internal table
   */
   
   select @objtype = type
   from sys.objects
   where name = @objname
                                                                      
   select @pubid = pubid,
          @pubname = name 
   from dbo.syspublications 
   where description like @pubdesc
   
   if @pubid is null
   begin
      print 'ERROR: Unable to obtain pubid and publication name!'
      goto endofsp
   end
   
   if @debugon = 1
      print 'Publication ID = ' + cast(@pubid as varchar) 

   if @objtype = 'U'
   begin
      if exists (select 1
                 from dbo.sysarticles 
                 where pubid = @pubid and 
                       name = @objname)
      begin
         exec dbo.sp_droparticle @publication = @pubname, @article = @objname
         if exists (select 1
                    from dbo.sysarticles 
                    where pubid = @pubid and 
                          name = @objname)
            print '<<< FAILED DROPPING article ' + @objname + ' >>>'
         else
            print '<<< DROPPED article ' + @objname + ' >>>'                         
      end
   end
   else
   begin
      if exists (select 1
                 from dbo.sysschemaarticles 
                 where pubid = @pubid and 
                       name = @objname)
      begin
         exec dbo.sp_droparticle @publication = @pubname, @article = @objname
         if exists (select 1
                    from dbo.sysschemaarticles 
                    where pubid = @pubid and 
                          name = @objname)
            print '<<< FAILED DROPPING article ' + @objname + ' >>>'
         else
            print '<<< DROPPED article ' + @objname + ' >>>'                         
      end
   end
   
usage:
   print 'Usage: exec dbo.usp_drop_REP_article @objname = ''?'''
   print '                                     [ ,@debugon = ?'
   print ''

endofsp:
   return
GO

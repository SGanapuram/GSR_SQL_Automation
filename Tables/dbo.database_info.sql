CREATE TABLE [dbo].[database_info]
(
[owner_code] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__database___owner__703EA55A] DEFAULT ('TC'),
[major_revnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[minor_revnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_touch_date] [datetime] NOT NULL CONSTRAINT [DF__database___last___7132C993] DEFAULT (getdate()),
[data_source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[usage] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[script_reference] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[database_info_instrg]
on [dbo].[database_info]
for insert
as
declare @num_rows    int,
        @hostname    nchar(128)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/*
   delete dbo.dbupgrade_log 
   where year(upgrade_date) < year(getdate()) - 1
*/

   select @hostname = hostname
   from master.dbo.sysprocesses
   where spid = @@spid
   
   insert into dbo.dbupgrade_log 
      (owner_code, 
       major_revnum,
       minor_revnum,
       last_touch_date,
       data_source,
       usage,
       script_reference,
       note,
       upgrade_date,
       upgraded_by,
       hostname,
       opcode)
   select 
      owner_code, 
      major_revnum,
      minor_revnum,
      last_touch_date,
      data_source,
      usage,
      script_reference,
      note, 
      getdate(),
      suser_name(),
      @hostname,
      'I'
   from inserted

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[database_info_updtrg]
on [dbo].[database_info]
for update
as
declare @num_rows         int,
        @hostname         nchar(128)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   select @hostname = hostname
   from master.dbo.sysprocesses
   where spid = @@spid
   
   insert into dbo.dbupgrade_log 
      (owner_code, 
       major_revnum,
       minor_revnum,
       last_touch_date,
       data_source,
       usage,
       script_reference,
       note,
       upgrade_date,
       upgraded_by,
       hostname,
       opcode)
   select 
      owner_code, 
      major_revnum,
      minor_revnum,
      last_touch_date,
      data_source,
      usage,
      script_reference,
      note, 
      getdate(),
      suser_name(),
      @hostname,
      'U'
   from deleted

return
GO
ALTER TABLE [dbo].[database_info] ADD CONSTRAINT [database_info_pk] PRIMARY KEY CLUSTERED  ([owner_code]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[database_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'database_info', NULL, NULL
GO

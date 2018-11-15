CREATE TABLE [dbo].[icts_timezones]
(
[oid] [int] NOT NULL IDENTITY(1, 1),
[tz_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tz_utc_offset_hr] [int] NULL,
[tz_utc_offset_mm] [int] NULL,
[trans_id] [int] NULL,
[tz_abbvr] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_timezones_deltrg]  
on [dbo].[icts_timezones]  
for delete  
as  
declare @num_rows    int,  
        @errmsg      varchar(255),  
        @atrans_id   int  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
/* AUDIT_CODE_BEGIN */  
select @atrans_id = max(trans_id)  
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)  
where spid = @@spid and  
      tran_date >= (select top 1 login_time  
                    from master.dbo.sysprocesses (nolock)  
                    where spid = @@spid)  
  
if @atrans_id is null  
begin  
   select @errmsg = '(icts_timezones) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                     program_name like 'Microsoft SQL Server Management Studio%') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg,10,1) 
   rollback tran  
   return  
end  

insert dbo.aud_icts_timezones  
(
	 oid,
	 tz_name,
	 tz_utc_offset_hr,
	 tz_utc_offset_mm,
	 tz_abbvr, 
	 trans_id,
	 resp_trans_id
)  
select
	 d.oid,
	 d.tz_name,
	 d.tz_utc_offset_hr,
	 d.tz_utc_offset_mm,
	 d.tz_abbvr,
	 d.trans_id,
	 @atrans_id
from deleted d   
  
/* AUDIT_CODE_END */  

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[icts_timezones_updtrg]  
on [dbo].[icts_timezones] 
for update  
as  
declare @num_rows         int,  
        @count_num_rows   int,  
        @dummy_update     int,  
        @errmsg           varchar(255)  
  
select @num_rows = @@rowcount  
if @num_rows = 0  
   return  
  
select @dummy_update = 0  
  
/* RECORD_STAMP_BEGIN */  
if not update(trans_id)   
begin  
   raiserror ('(icts_timezones) The change needs to be attached with a new trans_id',10,1)  
   rollback tran  
   return  
end  
  
/* added by Peter Lo  Sep-4-2002 */  
if exists (select 1  
           from master.dbo.sysprocesses  
           where spid = @@spid and  
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                 program_name like 'Microsoft SQL Server Management Studio%') )  
begin  
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0  
   begin  
      select @errmsg = '(icts_timezones) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg, 10, 1)
      rollback tran  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d 
			     where i.trans_id < d.trans_id and 
			           i.oid = d.oid)  
begin  
   raiserror ('(icts_timezones) new trans_id must not be older than current trans_id.',10,1)  
   rollback tran  
   return  
end  
  
/* RECORD_STAMP_END */
  
if update(oid) 
begin  
   select @count_num_rows = (select count(*) from inserted i, deleted d where i.oid = d.oid )
					
   if (@count_num_rows = @num_rows)  
   begin  
      select @dummy_update = 1  
   end  
   else  
   begin  
      raiserror ('(icts_timezones) primary key can not be changed.',10,1)  
      rollback tran  
      return  
   end  
end  

/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
insert dbo.aud_icts_timezones  
(
	 oid,
	 tz_name,
	 tz_utc_offset_hr,
	 tz_utc_offset_mm,
	 tz_abbvr,
	 trans_id,
	 resp_trans_id
)  
select
	 d.oid,
	 d.tz_name,
	 d.tz_utc_offset_hr,
	 d.tz_utc_offset_mm,
	 d.tz_abbvr,
	 d.trans_id,
	 i.trans_id
from deleted d, inserted i
where i.oid = d.oid
	  
/* AUDIT_CODE_END */  

return
GO
ALTER TABLE [dbo].[icts_timezones] ADD CONSTRAINT [icts_timezones_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[icts_timezones] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[icts_timezones] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[icts_timezones] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[icts_timezones] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'icts_timezones', NULL, NULL
GO

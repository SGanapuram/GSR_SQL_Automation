CREATE TABLE [dbo].[cargo_condition]
(
[cargo_cond_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cargo_cond_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cargo_cond_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[active_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[cargo_condition_deltrg]
on [dbo].[cargo_condition]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint
 
set @num_rows = @@rowcount
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
   set @errmsg = '(cargo_condition) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   if @@trancount > 0 rollback tran
 
   return
end

insert into dbo.aud_cargo_condition
   (
    cargo_cond_code,			
    cargo_cond_full_name,	
    cargo_cond_short_name,	
    active_ind,				
    trans_id,				
    resp_trans_id
   )			
select
   d.cargo_cond_code,			
   d.cargo_cond_full_name,	
   d.cargo_cond_short_name,	
   d.active_ind,				
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
 
create trigger [dbo].[cargo_condition_updtrg]
on [dbo].[cargo_condition]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)
 
set @num_rows = @@rowcount
if @num_rows = 0
   return
 
set @dummy_update = 0
 
/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(cargo_condition) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran
 
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
      set @errmsg = '(cargo_condition) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran
 
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cargo_cond_code = d.cargo_cond_code)
begin
   raiserror ('(cargo_condition) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran
 
   return
end
 
/* RECORD_STAMP_END */
 
if update(cargo_cond_code) 
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.cargo_cond_code = d.cargo_cond_code)
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror ('(cargo_condition) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran
 
      return
   end
end
 
/* AUDIT_CODE_BEGIN */
 
if @dummy_update = 0
   insert into dbo.aud_cargo_condition
      (
	   cargo_cond_code,			
       cargo_cond_full_name,	
       cargo_cond_short_name,
       active_ind,				
       trans_id,				
       resp_trans_id
	  )			
   select
	  d.cargo_cond_code,			
      d.cargo_cond_full_name,	
      d.cargo_cond_short_name,	
      d.active_ind,				
      d.trans_id,				
      i.trans_id			
   from deleted d, inserted i
   where d.cargo_cond_code = i.cargo_cond_code
   
/* AUDIT_CODE_END */
 
return
GO
ALTER TABLE [dbo].[cargo_condition] ADD CONSTRAINT [cargo_condition_pk] PRIMARY KEY CLUSTERED  ([cargo_cond_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cargo_condition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cargo_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cargo_condition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cargo_condition] TO [next_usr]
GO

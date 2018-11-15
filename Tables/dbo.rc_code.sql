CREATE TABLE [dbo].[rc_code]
(
[rc_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rc_code_desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rc_code_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__rc_code__rc_code__0CA7708C] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[rc_code_deltrg] 
on [dbo].[rc_code] 
for delete 
as 
declare @num_rows int, 
 @errmsg varchar(255), 
 @atrans_id int 
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
 select @errmsg = '(rc_code) Failed to obtain a valid responsible trans_id.' 
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
insert dbo.aud_rc_code 
 ( 
	rc_code,
	rc_code_desc,
	rc_code_status,
	trans_id,
	resp_trans_id
   ) 
select 
	d.rc_code,
	d.rc_code_desc,
	d.rc_code_status,
	d.trans_id,
	@atrans_id

from deleted d 
/* AUDIT_CODE_END */ 
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rc_code_updtrg] 
on [dbo].[rc_code] 
for update 
as 
declare @num_rows int, 
 @count_num_rows int, 
 @dummy_update int, 
 @errmsg varchar(255) 
 
select @num_rows = @@rowcount 
if @num_rows = 0 
 return 
 
select @dummy_update = 0 

/* RECORD_STAMP_BEGIN */ 
if not update(trans_id) 
	begin 
	 raiserror ('(rc_code) The change needs to be attached with a new trans_id',10,1) 
	 rollback tran 
	 return 
	end 
/* added by Peter Lo Sep-4-2002 */ 
if exists (select 1 
 from master.dbo.sysprocesses 
 where spid = @@spid and 
 (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR 
 program_name like 'Microsoft SQL Server Management Studio%') ) 
	begin 
	 if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0 
	 begin 
		 select @errmsg = '(rc_code) New trans_id must be larger than original trans_id.' 
		 select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.' 
		 raiserror (@errmsg,10,1) 
		 rollback tran 
		 return 
	 end 
	end 
if exists (select * from inserted i, deleted d 
 where i.trans_id < d.trans_id and 
 i.rc_code = d.rc_code ) 
	begin 
		 raiserror ('(rc_code) new trans_id must not be older than current trans_id.',10,1) 
		 rollback tran 
		 return 
	end 
/* RECORD_STAMP_END */ 
if update(rc_code) 
	begin 
		 select @count_num_rows = (select count(*) from inserted i, deleted d 
		 where i.rc_code = d.rc_code ) 
		 if (@count_num_rows = @num_rows) 
		 begin 
		 select @dummy_update = 1 
	 end 
 else 
	 begin 
		 raiserror ('(rc_code) primary key can not be changed.',10,1) 
		 rollback tran 
		 return 
	 end 
end 
/* AUDIT_CODE_BEGIN */ 
if @dummy_update = 0 
 insert dbo.aud_rc_code 
 ( 
	rc_code,
	rc_code_desc,
	rc_code_status,
	trans_id,
	resp_trans_id
  ) 
select 
	d.rc_code,
	d.rc_code_desc,
	d.rc_code_status,
	d.trans_id,
	i.trans_id

 from deleted d, inserted i 
 where d.rc_code = i.rc_code 
/* AUDIT_CODE_END */ 
GO
ALTER TABLE [dbo].[rc_code] ADD CONSTRAINT [CK__rc_code__rc_code__0D9B94C5] CHECK (([rc_code_status]='I' OR [rc_code_status]='A'))
GO
ALTER TABLE [dbo].[rc_code] ADD CONSTRAINT [rc_code_pk] PRIMARY KEY CLUSTERED  ([rc_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rc_code] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rc_code] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rc_code] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rc_code] TO [next_usr]
GO

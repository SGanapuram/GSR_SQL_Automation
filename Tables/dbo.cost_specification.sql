CREATE TABLE [dbo].[cost_specification]
(
[cost_num] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_val] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_specification_deltrg]
on [dbo].[cost_specification]
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
   set @errmsg = '(cost_specification) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cost_specification
   (
    cost_num,
	spec_code,
	spec_val,
	trans_id,
	resp_trans_id
   )
select
	d.cost_num,
	d.spec_code,
	d.spec_val,
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

create trigger [dbo].[cost_specification_updtrg]
on [dbo].[cost_specification]
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
   raiserror('(cost_specification) The change needs to be attached with a new trans_id', 16, 1)
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
      set @errmsg = '(cost_specification) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 16, 1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.spec_code = d.spec_code )
begin
   raiserror('(cost_specification) new trans_id must not be older than current trans_id.', 16, 1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(spec_code) 
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.spec_code = d.spec_code )
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror('(cost_specification) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_specification
      (
		cost_num,
		spec_code,
		spec_val,
		trans_id,
		resp_trans_id
	  )	
   select
		d.cost_num,
		d.spec_code,
		d.spec_val,
		d.trans_id,
		i.trans_id
   from deleted d, inserted i
   where d.spec_code = i.spec_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_specification] ADD CONSTRAINT [cost_specification_PK] PRIMARY KEY CLUSTERED  ([cost_num], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_specification] ADD CONSTRAINT [cost_specification_fk1] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[cost_specification] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_specification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_specification] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_specification] TO [next_usr]
GO

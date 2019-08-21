CREATE TABLE [dbo].[commodity_group]
(
[parent_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_group_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_group_deltrg]
on [dbo].[commodity_group]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(commodity_group) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_commodity_group
   (parent_cmdty_code,
    cmdty_code,
    cmdty_group_type_code,
    trans_id,
    resp_trans_id)
select
   d.parent_cmdty_code,
   d.cmdty_code,
   d.cmdty_group_type_code,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_group_instrg]
on [dbo].[commodity_group]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

if exists (select 1
	         from inserted
	         where cmdty_group_type_code = 'FOREX') 
begin
   declare @ex_type_code   int

   select @ex_type_code = null
   begin try
     select @ex_type_code = max(convert(int, exposure_type_code)) 
     from dbo.fx_exposure_type 
     where substring(exposure_type_code, 1, 1) like '[0-9]'
   end try
   begin catch
     print '(commodity_group) Failed to obtain a numeric value from the ''exposure_type_code'' column in the ''fx_exposure_type'' table!'
     print '=> ERROR: ' + ERROR_MESSAGE()
     if @@trancount > 0 rollback tran

     return
   end catch

   if @ex_type_code is null
      select @ex_type_code = 0
         
   begin try
	   insert into dbo.fx_exposure_type
	        (exposure_type_code, exposure_type_desc, trans_id)
	      select cast((@ex_type_code + a.rownum) as varchar), 
	             a.parent_cmdty_code, 
	             1
	      from (select (ROW_NUMBER() OVER (ORDER BY i.parent_cmdty_code)) as rownum, 
	                   i.parent_cmdty_code
	            from (select distinct parent_cmdty_code
	                  from inserted i
	                  where cmdty_group_type_code = 'FOREX' and
	                        not exists (select 1
	                                    from dbo.fx_exposure_type exp
	                                    where i.parent_cmdty_code = exp.exposure_type_desc)
	                 ) i
	           ) a
   end try
   begin catch
     print '(commodity_group) Failed to add new record(s) into the ''fx_exposure_type'' table due to the following error:'
     print '=> ERROR: ' + ERROR_MESSAGE()
     if @@trancount > 0 rollback tran

     return
   end catch
end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_group_updtrg]
on [dbo].[commodity_group]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(commodity_group) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(commodity_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.parent_cmdty_code = d.parent_cmdty_code and 
                 i.cmdty_code = d.cmdty_code and 
                 i.cmdty_group_type_code = d.cmdty_group_type_code )
begin
   raiserror ('(commodity_group) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(parent_cmdty_code) or  
   update(cmdty_code) or  
   update(cmdty_group_type_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.parent_cmdty_code = d.parent_cmdty_code and 
                                   i.cmdty_code = d.cmdty_code and 
                                   i.cmdty_group_type_code = d.cmdty_group_type_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commodity_group) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_commodity_group
      (parent_cmdty_code,
       cmdty_code,
       cmdty_group_type_code,
       trans_id,
       resp_trans_id)
   select
      d.parent_cmdty_code,
      d.cmdty_code,
      d.cmdty_group_type_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.parent_cmdty_code = i.parent_cmdty_code and
         d.cmdty_code = i.cmdty_code and
         d.cmdty_group_type_code = i.cmdty_group_type_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[commodity_group] ADD CONSTRAINT [commodity_group_pk] PRIMARY KEY CLUSTERED  ([parent_cmdty_code], [cmdty_code], [cmdty_group_type_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_group_POSGRID_idx1] ON [dbo].[commodity_group] ([cmdty_group_type_code], [cmdty_code]) INCLUDE ([parent_cmdty_code]) ON [PRIMARY]
GO
CREATE STATISTICS [commodity_group_POSGRID_stat1] ON [dbo].[commodity_group] ([cmdty_code], [cmdty_group_type_code])
GO
ALTER TABLE [dbo].[commodity_group] ADD CONSTRAINT [commodity_group_fk1] FOREIGN KEY ([parent_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_group] ADD CONSTRAINT [commodity_group_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_group] ADD CONSTRAINT [commodity_group_fk3] FOREIGN KEY ([cmdty_group_type_code]) REFERENCES [dbo].[commodity_group_type] ([cmdty_group_type_code])
GO
GRANT DELETE ON  [dbo].[commodity_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_group] TO [next_usr]
GO

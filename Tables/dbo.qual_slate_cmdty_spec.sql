CREATE TABLE [dbo].[qual_slate_cmdty_spec]
(
[oid] [int] NOT NULL,
[quality_slate_id] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_spec_min_val] [numeric] (20, 8) NULL,
[cmdty_spec_max_val] [numeric] (20, 8) NULL,
[cmdty_spec_typical_val] [numeric] (20, 8) NULL,
[mandatory_ind] [bit] NOT NULL CONSTRAINT [DF__qual_slat__manda__40457975] DEFAULT ((0)),
[trans_id] [int] NOT NULL,
[typical_string_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[qual_slate_cmdty_spec_deltrg]
on [dbo].[qual_slate_cmdty_spec]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(qual_slate_cmdty_spec) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_qual_slate_cmdty_spec
(  
   oid,
   quality_slate_id,
   cmdty_code,
   spec_code,
   cmdty_spec_min_val,
   cmdty_spec_max_val,
   cmdty_spec_typical_val,
   mandatory_ind,
   typical_string_value,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.quality_slate_id,
   d.cmdty_code,
   d.spec_code,
   d.cmdty_spec_min_val,
   d.cmdty_spec_max_val,
   d.cmdty_spec_typical_val,
   d.mandatory_ind,
   d.typical_string_value,
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

create trigger [dbo].[qual_slate_cmdty_spec_updtrg]
on [dbo].[qual_slate_cmdty_spec]
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
   raiserror ('(qual_slate_cmdty_spec) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(qual_slate_cmdty_spec) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(qual_slate_cmdty_spec) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (''' + i.oid + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(qual_slate_cmdty_spec) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_qual_slate_cmdty_spec
   (
      oid,
      quality_slate_id,
      cmdty_code,
      spec_code,
      cmdty_spec_min_val,
      cmdty_spec_max_val,
      cmdty_spec_typical_val,
      mandatory_ind,
      typical_string_value,
      trans_id,
      resp_trans_id
   )
   select
      d.oid,
      d.quality_slate_id,
      d.cmdty_code,
      d.spec_code,
      d.cmdty_spec_min_val,
      d.cmdty_spec_max_val,
      d.cmdty_spec_typical_val,      
      d.mandatory_ind,
      d.typical_string_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[qual_slate_cmdty_spec] ADD CONSTRAINT [qual_slate_cmdty_spec_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qual_slate_cmdty_spec] ADD CONSTRAINT [qual_slate_cmdty_spec_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[qual_slate_cmdty_spec] ADD CONSTRAINT [qual_slate_cmdty_spec_fk3] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[qual_slate_cmdty_spec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qual_slate_cmdty_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qual_slate_cmdty_spec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qual_slate_cmdty_spec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'qual_slate_cmdty_spec', NULL, NULL
GO

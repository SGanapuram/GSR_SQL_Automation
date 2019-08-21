CREATE TABLE [dbo].[portfolio_alias]
(
[port_num] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_alias_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_alias_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_alias_deltrg]
on [dbo].[portfolio_alias]
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
   select @errmsg = '(portfolio_alias) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_portfolio_alias
   (port_num,
    alias_source_code,
    port_alias_name,
    port_alias_desc,
    trans_id,
    resp_trans_id)
select
   d.port_num,
   d.alias_source_code,
   d.port_alias_name,
   d.port_alias_desc,
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

create trigger [dbo].[portfolio_alias_updtrg]
on [dbo].[portfolio_alias]
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
   raiserror ('(portfolio_alias) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(portfolio_alias) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.port_num = d.port_num and 
                 i.alias_source_code = d.alias_source_code )
begin
   raiserror ('(portfolio_alias) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(port_num) or  
   update(alias_source_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.port_num = d.port_num and 
                                   i.alias_source_code = d.alias_source_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_alias) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_alias
      (port_num,
       alias_source_code,
       port_alias_name,
       port_alias_desc,
       trans_id,
       resp_trans_id)
   select
      d.port_num,
      d.alias_source_code,
      d.port_alias_name,
      d.port_alias_desc,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.port_num = i.port_num and
         d.alias_source_code = i.alias_source_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[portfolio_alias] ADD CONSTRAINT [portfolio_alias_pk] PRIMARY KEY CLUSTERED  ([port_num], [alias_source_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[portfolio_alias] ADD CONSTRAINT [portfolio_alias_fk1] FOREIGN KEY ([alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
GRANT DELETE ON  [dbo].[portfolio_alias] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_alias] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_alias] TO [next_usr]
GO

CREATE TABLE [dbo].[portfolio_group]
(
[parent_port_num] [int] NOT NULL,
[port_num] [int] NOT NULL,
[is_link_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_group_deltrg]
on [dbo].[portfolio_group]
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
   select @errmsg = '(portfolio_group) Failed to obtain a valid responsible trans_id.'
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'PortfolioGroup',
       'DIRECT',
       convert(varchar(40), d.parent_port_num),
       convert(varchar(40), d.port_num),
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

/* AUDIT_CODE_BEGIN */

insert dbo.aud_portfolio_group
   (parent_port_num,
    port_num,
    is_link_ind,
    trans_id,
    resp_trans_id)
select
   d.parent_port_num,
   d.port_num,
   d.is_link_ind,
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

create trigger [dbo].[portfolio_group_instrg]
on [dbo].[portfolio_group]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'PortfolioGroup',
          'DIRECT',
          convert(varchar(40), i.parent_port_num),
          convert(varchar(40), i.port_num),
          null,
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'
 
   /* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_group_updtrg]
on [dbo].[portfolio_group]
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
   raiserror ('(portfolio_group) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(portfolio_group) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.parent_port_num = d.parent_port_num and 
                 i.port_num = d.port_num )
begin
   raiserror ('(portfolio_group) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(parent_port_num) or  
   update(port_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.parent_port_num = d.parent_port_num and 
                                   i.port_num = d.port_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_group) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'PortfolioGroup',
       'DIRECT',
       convert(varchar(40), i.parent_port_num),
       convert(varchar(40), i.port_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_group
      (parent_port_num,
       port_num,
       is_link_ind,
       trans_id,
       resp_trans_id)
   select
      d.parent_port_num,
      d.port_num,
      d.is_link_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.parent_port_num = i.parent_port_num and
         d.port_num = i.port_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[portfolio_group] ADD CONSTRAINT [portfolio_group_pk] PRIMARY KEY CLUSTERED  ([parent_port_num], [port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_group_idx1] ON [dbo].[portfolio_group] ([is_link_ind], [port_num], [parent_port_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_group] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_group] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_group] TO [next_usr]
GO

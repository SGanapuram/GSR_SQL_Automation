CREATE TABLE [dbo].[portfolio_tag_option]
(
[tag_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_option] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_option_desc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tag_option_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__portfolio__tag_o__729BEF18] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_option_deltrg]
on [dbo].[portfolio_tag_option]
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
   select @errmsg = '(portfolio_tag_option) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   rollback tran
   return
end


insert dbo.aud_portfolio_tag_option
   (tag_name,
    tag_option,
    tag_option_desc,
    tag_option_status,
    trans_id,
    resp_trans_id)
select
   d.tag_name,
   d.tag_option,
   d.tag_option_desc,
   d.tag_option_status,
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

create trigger [dbo].[portfolio_tag_option_updtrg]
on [dbo].[portfolio_tag_option]
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
   raiserror('(portfolio_tag_option) The change needs to be attached with a new trans_id', 16, 1)
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
      select @errmsg = '(portfolio_tag_option) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 16, 1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.tag_name = d.tag_name and
                 i.tag_option = d.tag_option)
begin
   raiserror('(portfolio_tag_option) new trans_id must not be older than current trans_id.', 16, 1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(tag_name) or
   update(tag_option)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.tag_name = d.tag_name and
                                   i.tag_option = d.tag_option)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror('(portfolio_tag_option) primary key can not be changed.', 16, 1)
      rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_tag_option
      (tag_name,
       tag_option,
       tag_option_desc,
       tag_option_status,
       trans_id,
       resp_trans_id)
   select
      d.tag_name,
      d.tag_option,
      d.tag_option_desc,
      d.tag_option_status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.tag_name = i.tag_name and
         d.tag_option = i.tag_option

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[portfolio_tag_option] ADD CONSTRAINT [CK__portfolio__tag_o__73901351] CHECK (([tag_option_status]='I' OR [tag_option_status]='A'))
GO
ALTER TABLE [dbo].[portfolio_tag_option] ADD CONSTRAINT [portfolio_tag_option_pk] PRIMARY KEY CLUSTERED  ([tag_name], [tag_option]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_tag_option_POSGRID_idx1] ON [dbo].[portfolio_tag_option] ([tag_name], [tag_option]) INCLUDE ([tag_option_desc]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO

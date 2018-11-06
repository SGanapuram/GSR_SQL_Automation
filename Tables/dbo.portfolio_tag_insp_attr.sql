CREATE TABLE [dbo].[portfolio_tag_insp_attr]
(
[tag_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_insp_attr_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_insp_attr_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__portfolio__ref_i__0EAE1DE1] DEFAULT ('S'),
[ref_insp_attr_value] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_insp_attr_deltrg]
on [dbo].[portfolio_tag_insp_attr]
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
   select @errmsg = '(portfolio_tag_insp_attr) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_portfolio_tag_insp_attr
   (tag_name,
    ref_insp_attr_name,
    ref_insp_attr_type_ind,
    ref_insp_attr_value,
    trans_id,
    resp_trans_id)
select
   d.tag_name,
   d.ref_insp_attr_name,
   d.ref_insp_attr_type_ind,
   d.ref_insp_attr_value,
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

create trigger [dbo].[portfolio_tag_insp_attr_updtrg]
on [dbo].[portfolio_tag_insp_attr]
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
   raiserror ('(portfolio_tag_insp_attr) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(portfolio_tag_insp_attr) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.tag_name = d.tag_name and
                 i.ref_insp_attr_name = d.ref_insp_attr_name)
begin
   raiserror ('(portfolio_tag_insp_attr) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(tag_name) or
   update(ref_insp_attr_name)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.tag_name = d.tag_name and
                                   i.ref_insp_attr_name = d.ref_insp_attr_name)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_tag_insp_attr) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_tag_insp_attr
      (tag_name,
       ref_insp_attr_name,
       ref_insp_attr_type_ind,
       ref_insp_attr_value,
       trans_id,
       resp_trans_id)
   select
      d.tag_name,
      d.ref_insp_attr_name,
      d.ref_insp_attr_type_ind,
      d.ref_insp_attr_value,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.tag_name = i.tag_name and
         d.ref_insp_attr_name = i.ref_insp_attr_name

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[portfolio_tag_insp_attr] ADD CONSTRAINT [CK__portfolio__ref_i__0FA2421A] CHECK (([ref_insp_attr_type_ind]='D' OR [ref_insp_attr_type_ind]='N' OR [ref_insp_attr_type_ind]='S'))
GO
ALTER TABLE [dbo].[portfolio_tag_insp_attr] ADD CONSTRAINT [portfolio_tag_insp_attr_pk] PRIMARY KEY CLUSTERED  ([tag_name], [ref_insp_attr_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_tag_insp_attr', NULL, NULL
GO

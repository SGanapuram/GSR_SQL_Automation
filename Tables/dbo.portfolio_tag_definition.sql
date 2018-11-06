CREATE TABLE [dbo].[portfolio_tag_definition]
(
[tag_name] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tag_desc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_insp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_insp_formatter_key] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[value_entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[value_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__portfolio__value__070CFC19] DEFAULT ('S'),
[value_attribute] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tag_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__portfolio__tag_s__08F5448B] DEFAULT ('A'),
[tag_required_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__portfolio__tag_r__0ADD8CFD] DEFAULT ('N'),
[foreign_key_table] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[foreign_key_field] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_def_deltrg]
on [dbo].[portfolio_tag_definition]
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
   select @errmsg = '(portfolio_tag_definition) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_portfolio_tag_definition
   (tag_name,
    tag_desc,
    ref_insp_name,
    ref_insp_formatter_key,
    value_entity_name,
    value_type_ind,
    value_attribute,
    tag_status,
    tag_required_ind,
    foreign_key_table,
    foreign_key_field,
    trans_id,
    resp_trans_id)
select
   d.tag_name,
   d.tag_desc,
   d.ref_insp_name,
   d.ref_insp_formatter_key,
   d.value_entity_name,
   d.value_type_ind,
   d.value_attribute,
   d.tag_status,
   d.tag_required_ind,
   d.foreign_key_table,
   d.foreign_key_field,
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

create trigger [dbo].[portfolio_tag_def_updtrg]
on [dbo].[portfolio_tag_definition]
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
   raiserror ('(portfolio_tag_definition) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(portfolio_tag_definition) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.tag_name = d.tag_name)
begin
   raiserror ('(portfolio_tag_definition) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(tag_name) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.tag_name = d.tag_name)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(portfolio_tag_definition) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_portfolio_tag_definition
      (tag_name,
       tag_desc,
       ref_insp_name,
       ref_insp_formatter_key,
       value_entity_name,
       value_type_ind,
       value_attribute,
       tag_status,
       tag_required_ind,
       foreign_key_table,
       foreign_key_field,
       trans_id,
       resp_trans_id)
   select
      d.tag_name,
      d.tag_desc,
      d.ref_insp_name,
      d.ref_insp_formatter_key,
      d.value_entity_name,
      d.value_type_ind,
      d.value_attribute,
      d.tag_status,
      d.tag_required_ind,
      d.foreign_key_table,
      d.foreign_key_field,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.tag_name = i.tag_name 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[portfolio_tag_definition] ADD CONSTRAINT [CK__portfolio__tag_r__0BD1B136] CHECK (([tag_required_ind]='N' OR [tag_required_ind]='Y'))
GO
ALTER TABLE [dbo].[portfolio_tag_definition] ADD CONSTRAINT [CK__portfolio__tag_s__09E968C4] CHECK (([tag_status]='S' OR [tag_status]='I' OR [tag_status]='A'))
GO
ALTER TABLE [dbo].[portfolio_tag_definition] ADD CONSTRAINT [CK__portfolio__value__08012052] CHECK (([value_type_ind]='D' OR [value_type_ind]='N' OR [value_type_ind]='S'))
GO
ALTER TABLE [dbo].[portfolio_tag_definition] ADD CONSTRAINT [portfolio_tag_definition_pk] PRIMARY KEY CLUSTERED  ([tag_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'portfolio_tag_definition', NULL, NULL
GO

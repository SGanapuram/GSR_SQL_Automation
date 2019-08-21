CREATE TABLE [dbo].[uom]
(
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[uom_convert_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conv_factor] [numeric] (20, 8) NULL,
[spec_code_adj1] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj1_mult_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_code_adj2] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[adj2_mult_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[uom_deltrg]
on [dbo].[uom]
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
   select @errmsg = '(uom) Failed to obtain a valid responsible trans_id.'
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
       'Uom',
       'DIRECT',
       convert(varchar(40), d.uom_code),
       null,
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

insert dbo.aud_uom
   (uom_code,
    uom_type,
    uom_status,
    uom_short_name,
    uom_full_name,
    uom_num,
    trans_id,
    resp_trans_id)
select
   d.uom_code,
   d.uom_type,
   d.uom_status,
   d.uom_short_name,
   d.uom_full_name,
   d.uom_num,
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

create trigger [dbo].[uom_instrg]
on [dbo].[uom]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'Uom',
          'DIRECT',
          convert(varchar(40), i.uom_code),
          null,
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

create trigger [dbo].[uom_updtrg]
on [dbo].[uom]
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
   raiserror ('(uom) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(uom) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.uom_code = d.uom_code )
begin
   raiserror ('(uom) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(uom_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.uom_code = d.uom_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(uom) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_END */

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_uom
      (uom_code,
       uom_type,
       uom_status,
       uom_short_name,
       uom_full_name,
       uom_num,
       trans_id,
       resp_trans_id)
   select
      d.uom_code,
      d.uom_type,
      d.uom_status,
      d.uom_short_name,
      d.uom_full_name,
      d.uom_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.uom_code = i.uom_code 

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Uom',
       'DIRECT',
       convert(varchar(40), i.uom_code),
       null,
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
ALTER TABLE [dbo].[uom] ADD CONSTRAINT [uom_pk] PRIMARY KEY CLUSTERED  ([uom_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[uom] ADD CONSTRAINT [uom_fk1] FOREIGN KEY ([uom_convert_to]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[uom] ADD CONSTRAINT [uom_fk2] FOREIGN KEY ([spec_code_adj1]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[uom] ADD CONSTRAINT [uom_fk3] FOREIGN KEY ([spec_code_adj2]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[uom] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[uom] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[uom] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[uom] TO [next_usr]
GO

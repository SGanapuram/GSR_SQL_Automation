CREATE TABLE [dbo].[fiscal_classification]
(
[fiscal_class_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fiscal_class_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fiscal_class_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__fiscal_cl__fisca__2E06CDA9] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fiscal_classification_deltrg]
on [dbo].[fiscal_classification]
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
   select @errmsg = '(fiscal_classification) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fiscal_classification
(  
   fiscal_class_code,
   fiscal_class_desc,
   fiscal_class_status,
   trans_id,
   resp_trans_id
)
select
   d.fiscal_class_code,
   d.fiscal_class_desc,
   d.fiscal_class_status,
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

create trigger [dbo].[fiscal_classification_updtrg]
on [dbo].[fiscal_classification]
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
   raiserror ('(fiscal_classification) The change needs to be attached with a new trans_id',10,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fiscal_class_code = d.fiscal_class_code)
begin
   raiserror ('(fiscal_classification) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(fiscal_class_code)
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.fiscal_class_code = d.fiscal_class_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(fiscal_classification) primary key can not be changed.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fiscal_classification
   (
      fiscal_class_code,
      fiscal_class_desc,
      fiscal_class_status,
      trans_id,
      resp_trans_id
   )
   select
      d.fiscal_class_code,
      d.fiscal_class_desc,
      d.fiscal_class_status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.fiscal_class_code = i.fiscal_class_code

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[fiscal_classification] ADD CONSTRAINT [CK__fiscal_cl__fisca__2EFAF1E2] CHECK (([fiscal_class_status]='I' OR [fiscal_class_status]='A'))
GO
ALTER TABLE [dbo].[fiscal_classification] ADD CONSTRAINT [fiscal_classification_pk] PRIMARY KEY CLUSTERED  ([fiscal_class_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fiscal_classification] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fiscal_classification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fiscal_classification] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fiscal_classification] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'fiscal_classification', NULL, NULL
GO

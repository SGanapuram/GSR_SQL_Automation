CREATE TABLE [dbo].[cost_code]
(
[cost_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_code_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_code_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__cost_code__cost___0B27A5C0] DEFAULT ('M'),
[cost_code_order_num] [smallint] NULL,
[pl_implication] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__cost_code__pl_im__0D0FEE32] DEFAULT ('OPEN'),
[trans_id] [int] NOT NULL,
[cost_code_long_name] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_code_deltrg]
on [dbo].[cost_code]
instead of delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

delete dbo.cost_code 
from deleted d
where cost_code.cost_code = d.cost_code


/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(cost_code) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_cost_code
   (cost_code,
    cost_code_desc,
    cost_code_type_ind,
    cost_code_order_num,
    pl_implication,
    cost_code_long_name,
    trans_id,
    resp_trans_id)
select
   d.cost_code,
   d.cost_code_desc,
   d.cost_code_type_ind,
   d.cost_code_order_num,
   d.pl_implication,
   d.cost_code_long_name,
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

create trigger [dbo].[cost_code_updtrg]
on [dbo].[cost_code]
instead of update
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
   raiserror ('(cost_code) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(cost_code) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_code = d.cost_code )
begin
   raiserror ('(cost_code) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_code = d.cost_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_code) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

update dbo.cost_code
set cost_code = i.cost_code,
    cost_code_desc = i.cost_code_desc,
    cost_code_type_ind = i.cost_code_type_ind,
    cost_code_order_num = i.cost_code_order_num,
    pl_implication = i.pl_implication,
    cost_code_long_name = i.cost_code_long_name,
    trans_id = i.trans_id
from deleted d, inserted i
where cost_code.cost_code = d.cost_code and
      d.cost_code = i.cost_code

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_code
      (cost_code,
       cost_code_desc,
       cost_code_type_ind,
       cost_code_order_num,
       pl_implication,
       cost_code_long_name,
       trans_id,
       resp_trans_id)
   select
      d.cost_code,
      d.cost_code_desc,
      d.cost_code_type_ind,
      d.cost_code_order_num,
      d.pl_implication,
      d.cost_code_long_name,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.cost_code = i.cost_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_code] ADD CONSTRAINT [CK__cost_code__cost___0C1BC9F9] CHECK (([cost_code_type_ind]='N' OR [cost_code_type_ind]='I' OR [cost_code_type_ind]='M'))
GO
ALTER TABLE [dbo].[cost_code] ADD CONSTRAINT [CK__cost_code__pl_im__0E04126B] CHECK (([pl_implication]='NO_EFFECT' OR [pl_implication]='INVENTORY' OR [pl_implication]='CLOSED' OR [pl_implication]='OPEN'))
GO
ALTER TABLE [dbo].[cost_code] ADD CONSTRAINT [cost_code_pk] PRIMARY KEY CLUSTERED  ([cost_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cost_code] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_code] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_code] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_code] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost_code', NULL, NULL
GO

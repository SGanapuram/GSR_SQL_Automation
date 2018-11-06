CREATE TABLE [dbo].[qty_adj_rule]
(
[qty_adj_rule_num] [int] NOT NULL,
[qty_adj_rule_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_adj_rule_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_code1] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code2] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rule_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__qty_adj_r__rule___3B80C458] DEFAULT ('Two Spec'),
[price_precision] [tinyint] NOT NULL CONSTRAINT [DF__qty_adj_r__price__3D690CCA] DEFAULT ((3)),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[qty_adj_rule_deltrg]
on [dbo].[qty_adj_rule]
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
   select @errmsg = '(qty_adj_rule) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_qty_adj_rule
   (qty_adj_rule_num,
    qty_adj_rule_name, 
    qty_adj_rule_desc, 
    spec_code1,
    spec_code2,
    rule_type,
    price_precision,
    trans_id,
    resp_trans_id)
select
   d.qty_adj_rule_num,
   d.qty_adj_rule_name, 
   d.qty_adj_rule_desc, 
   d.spec_code1,
   d.spec_code2,
   d.rule_type,
   d.price_precision,
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

create trigger [dbo].[qty_adj_rule_updtrg]
on [dbo].[qty_adj_rule]
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
   raiserror ('(qty_adj_rule) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(qty_adj_rule) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.qty_adj_rule_num = d.qty_adj_rule_num )
begin
   raiserror ('(qty_adj_rule) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(qty_adj_rule_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.qty_adj_rule_num = d.qty_adj_rule_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(qty_adj_rule) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_qty_adj_rule
      (qty_adj_rule_num,
       qty_adj_rule_name, 
       qty_adj_rule_desc, 
       spec_code1,
       spec_code2,
       rule_type,
       price_precision,
       trans_id,
       resp_trans_id)
   select
      d.qty_adj_rule_num,
      d.qty_adj_rule_name, 
      d.qty_adj_rule_desc, 
      d.spec_code1,
      d.spec_code2,
      d.rule_type,
      d.price_precision,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.qty_adj_rule_num = i.qty_adj_rule_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[qty_adj_rule] ADD CONSTRAINT [qar_rule_type] CHECK (([rule_type]='One Spec' OR [rule_type]='Two Spec'))
GO
ALTER TABLE [dbo].[qty_adj_rule] ADD CONSTRAINT [qty_adj_rule_pk] PRIMARY KEY CLUSTERED  ([qty_adj_rule_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[qty_adj_rule] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qty_adj_rule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qty_adj_rule] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qty_adj_rule] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'qty_adj_rule', NULL, NULL
GO

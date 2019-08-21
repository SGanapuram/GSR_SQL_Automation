CREATE TABLE [dbo].[trade_term_info]
(
[trade_num] [int] NOT NULL,
[contr_start_date] [datetime] NULL,
[contr_end_date] [datetime] NULL,
[contr_ren_term_date] [datetime] NULL,
[warning_start_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[sap_contract_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_contract_item_num] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_term_info_deltrg]
on [dbo].[trade_term_info]
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
   select @errmsg = '(trade_term_info) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   rollback tran
   return
end


insert dbo.aud_trade_term_info
   (trade_num,
    contr_start_date,
    contr_end_date,
    contr_ren_term_date,
    warning_start_date,
    sap_contract_num,
    sap_contract_item_num,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.contr_start_date,
   d.contr_end_date,
   d.contr_ren_term_date,
   d.warning_start_date,
   d.sap_contract_num,
   d.sap_contract_item_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'TradeTermInfo',
       'DIRECT',
       convert(varchar(40), d.trade_num),
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

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_term_info_instrg]
on [dbo].[trade_term_info]
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
          'TradeTermInfo',
          'DIRECT',
          convert(varchar(40), i.trade_num),
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

create trigger [dbo].[trade_term_info_updtrg]
on [dbo].[trade_term_info]
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
   raiserror ('(trade_term_info) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(trade_term_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num)
begin
   raiserror ('(trade_term_info) new trans_id must not be older than current trans_id.',16,1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(trade_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror  ('(trade_term_info) primary key can not be changed.',16,1)
      rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_term_info
      (trade_num,
       contr_start_date,
       contr_end_date,
       contr_ren_term_date,
       warning_start_date,
       sap_contract_num,
       sap_contract_item_num,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.contr_start_date,
      d.contr_end_date,
      d.contr_ren_term_date,
      d.warning_start_date,
      d.sap_contract_num,
      d.sap_contract_item_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where i.trade_num = d.trade_num

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'TradeTermInfo',
       'DIRECT',
       convert(varchar(40), i.trade_num),
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
ALTER TABLE [dbo].[trade_term_info] ADD CONSTRAINT [trade_term_info_pk] PRIMARY KEY CLUSTERED  ([trade_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trade_term_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_term_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_term_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_term_info] TO [next_usr]
GO

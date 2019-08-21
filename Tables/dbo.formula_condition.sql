CREATE TABLE [dbo].[formula_condition]
(
[formula_num] [int] NOT NULL,
[formula_cond_num] [smallint] NOT NULL,
[formula_cond_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[formula_cond_date] [datetime] NULL,
[formula_cond_quote_range] [tinyint] NULL,
[formula_cond_last_next_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[src_commkt_key] [int] NULL,
[src_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[src_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[src_val_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[basis_commkt_key] [int] NULL,
[basis_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[basis_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[basis_val_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_condition_deltrg]
on [dbo].[formula_condition]
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
   select @errmsg = '(formula_condition) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_formula_condition
   (formula_num,
    formula_cond_num,
    formula_cond_type,
    formula_cond_date,
    formula_cond_quote_range,
    formula_cond_last_next_ind,
    src_commkt_key,
    src_trading_prd,
    src_price_source_code,
    src_val_type,
    basis_commkt_key,
    basis_trading_prd,
    basis_price_source_code,
    basis_val_type,
    trans_id,
    resp_trans_id)
select
   d.formula_num,
   d.formula_cond_num,
   d.formula_cond_type,
   d.formula_cond_date,
   d.formula_cond_quote_range,
   d.formula_cond_last_next_ind,
   d.src_commkt_key,
   d.src_trading_prd,
   d.src_price_source_code,
   d.src_val_type,
   d.basis_commkt_key,
   d.basis_trading_prd,
   d.basis_price_source_code,
   d.basis_val_type,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FormulaCondition',
       'DIRECT',
       convert(varchar(40), d.formula_num),
       convert(varchar(40), d.formula_cond_num),
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from dbo.icts_transaction it,
     deleted d
where it.trans_id = @atrans_id and
      it.type != 'E'
      
/* END_TRANSACTION_TOUCH */
      
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_condition_instrg]
on [dbo].[formula_condition]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'INSERT',
       'FormulaCondition',
       'DIRECT',
       convert(varchar(40), formula_num),
       convert(varchar(40), formula_cond_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, 
     dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_condition_updtrg]
on [dbo].[formula_condition]
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
   raiserror ('(formula_condition) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(formula_condition) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.formula_num = d.formula_num and 
                 i.formula_cond_num = d.formula_cond_num )
begin
   select @errmsg = '(formula_condition) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.formula_num) + ',' + 
                                        convert(varchar, i.formula_cond_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(formula_num) or  
   update(formula_cond_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.formula_num = d.formula_num and 
                                   i.formula_cond_num = d.formula_cond_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(formula_condition) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_formula_condition
      (formula_num,
       formula_cond_num,
       formula_cond_type,
       formula_cond_date,
       formula_cond_quote_range,
       formula_cond_last_next_ind,
       src_commkt_key,
       src_trading_prd,
       src_price_source_code,
       src_val_type,
       basis_commkt_key,
       basis_trading_prd,
       basis_price_source_code,
       basis_val_type,
       trans_id,
       resp_trans_id)
   select
      d.formula_num,
      d.formula_cond_num,
      d.formula_cond_type,
      d.formula_cond_date,
      d.formula_cond_quote_range,
      d.formula_cond_last_next_ind,
      d.src_commkt_key,
      d.src_trading_prd,
      d.src_price_source_code,
      d.src_val_type,
      d.basis_commkt_key,
      d.basis_trading_prd,
      d.basis_price_source_code,
      d.basis_val_type,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.formula_num = i.formula_num and
         d.formula_cond_num = i.formula_cond_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FormulaCondition',
       'DIRECT',
       convert(varchar(40), formula_num),
       convert(varchar(40), formula_cond_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from dbo.icts_transaction it,
     inserted i
where i.trans_id = it.trans_id and
      it.type != 'E'
            
/* END_TRANSACTION_TOUCH */
      
return
GO
ALTER TABLE [dbo].[formula_condition] ADD CONSTRAINT [formula_condition_pk] PRIMARY KEY CLUSTERED  ([formula_num], [formula_cond_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula_condition] ADD CONSTRAINT [formula_condition_fk2] FOREIGN KEY ([src_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[formula_condition] ADD CONSTRAINT [formula_condition_fk3] FOREIGN KEY ([basis_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[formula_condition] ADD CONSTRAINT [formula_condition_fk4] FOREIGN KEY ([src_commkt_key], [src_trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[formula_condition] ADD CONSTRAINT [formula_condition_fk5] FOREIGN KEY ([basis_commkt_key], [basis_trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
GRANT DELETE ON  [dbo].[formula_condition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_condition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_condition] TO [next_usr]
GO

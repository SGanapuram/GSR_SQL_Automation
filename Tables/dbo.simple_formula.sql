CREATE TABLE [dbo].[simple_formula]
(
[simple_formula_num] [int] NOT NULL,
[quote_commkt_key] [int] NOT NULL,
[quote_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_diff] [float] NULL,
[quote_diff_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quote_diff_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[simple_formula_deltrg]
on [dbo].[simple_formula]
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
   select @errmsg = '(simple_formula) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_simple_formula
   (simple_formula_num,
    quote_commkt_key,
    quote_trading_prd,
    quote_price_source_code,
    quote_price_type,
    quote_diff,
    quote_diff_curr_code,
    quote_diff_uom_code,
    trans_id,
    resp_trans_id)
select
   d.simple_formula_num,
   d.quote_commkt_key,
   d.quote_trading_prd,
   d.quote_price_source_code,
   d.quote_price_type,
   d.quote_diff,
   d.quote_diff_curr_code,
   d.quote_diff_uom_code,
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

create trigger [dbo].[simple_formula_updtrg]
on [dbo].[simple_formula]
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
   raiserror ('(simple_formula) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(simple_formula) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.simple_formula_num = d.simple_formula_num )
begin
   raiserror ('(simple_formula) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(simple_formula_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.simple_formula_num = d.simple_formula_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(simple_formula) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_simple_formula
      (simple_formula_num,
       quote_commkt_key,
       quote_trading_prd,
       quote_price_source_code,
       quote_price_type,
       quote_diff,
       quote_diff_curr_code,
       quote_diff_uom_code,
       trans_id,
       resp_trans_id)
   select
      d.simple_formula_num,
      d.quote_commkt_key,
      d.quote_trading_prd,
      d.quote_price_source_code,
      d.quote_price_type,
      d.quote_diff,
      d.quote_diff_curr_code,
      d.quote_diff_uom_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.simple_formula_num = i.simple_formula_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[simple_formula] ADD CONSTRAINT [simple_formula_pk] PRIMARY KEY CLUSTERED  ([simple_formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [simple_formula_idx1] ON [dbo].[simple_formula] ([quote_commkt_key], [quote_trading_prd]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [simple_formula_POSGRID_idx1] ON [dbo].[simple_formula] ([simple_formula_num], [quote_commkt_key]) INCLUDE ([quote_diff], [quote_price_source_code], [quote_price_type], [quote_trading_prd]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[simple_formula] ADD CONSTRAINT [simple_formula_fk1] FOREIGN KEY ([quote_diff_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[simple_formula] ADD CONSTRAINT [simple_formula_fk2] FOREIGN KEY ([quote_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[simple_formula] ADD CONSTRAINT [simple_formula_fk3] FOREIGN KEY ([quote_commkt_key], [quote_trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[simple_formula] ADD CONSTRAINT [simple_formula_fk4] FOREIGN KEY ([quote_diff_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[simple_formula] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[simple_formula] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[simple_formula] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[simple_formula] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'simple_formula', NULL, NULL
GO

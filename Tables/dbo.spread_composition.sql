CREATE TABLE [dbo].[spread_composition]
(
[spread_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[comp_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd_offset] [int] NOT NULL,
[long_short_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spread_qty_factor] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[product_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[spread_composition_deltrg]
on [dbo].[spread_composition]
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
   select @errmsg = '(spread_composition) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_spread_composition
   (spread_cmdty_code,
    comp_cmdty_code,
    trading_prd_offset,
    long_short_ind,
    spread_qty_factor,
    product_id,
    trans_id,
    resp_trans_id)
select
   d.spread_cmdty_code,
   d.comp_cmdty_code,
   d.trading_prd_offset,
   d.long_short_ind,
   d.spread_qty_factor,
   d.product_id,
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

create trigger [dbo].[spread_composition_updtrg]
on [dbo].[spread_composition]
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
   raiserror ('(spread_composition) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(spread_composition) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.spread_cmdty_code = d.spread_cmdty_code and
                 i.comp_cmdty_code = d.comp_cmdty_code and
                 i.trading_prd_offset = d.trading_prd_offset)
begin
   raiserror ('(spread_composition) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(spread_cmdty_code) or 
   update(comp_cmdty_code) or 
   update(trading_prd_offset)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.spread_cmdty_code = d.spread_cmdty_code and
                                   i.comp_cmdty_code = d.comp_cmdty_code and
                                   i.trading_prd_offset = d.trading_prd_offset )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(spread_composition) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_spread_composition
      (spread_cmdty_code,
       comp_cmdty_code,
       trading_prd_offset,
       long_short_ind,
       spread_qty_factor,
       product_id,
       trans_id,
       resp_trans_id)
   select
      d.spread_cmdty_code,
      d.comp_cmdty_code,
      d.trading_prd_offset,
      d.long_short_ind,
      d.spread_qty_factor,
      d.product_id,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.spread_cmdty_code = i.spread_cmdty_code and
         d.comp_cmdty_code = i.comp_cmdty_code and
         d.trading_prd_offset = i.trading_prd_offset

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[spread_composition] ADD CONSTRAINT [CK__spread_co__long___4999D985] CHECK (([long_short_ind]='S' OR [long_short_ind]='L'))
GO
ALTER TABLE [dbo].[spread_composition] ADD CONSTRAINT [CK__spread_co__sprea__4A8DFDBE] CHECK (([spread_qty_factor]>(0)))
GO
ALTER TABLE [dbo].[spread_composition] ADD CONSTRAINT [spread_composition_pk] PRIMARY KEY CLUSTERED  ([spread_cmdty_code], [comp_cmdty_code], [trading_prd_offset]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[spread_composition] ADD CONSTRAINT [spread_composition_fk3] FOREIGN KEY ([product_id]) REFERENCES [dbo].[icts_product] ([product_id])
GO
GRANT DELETE ON  [dbo].[spread_composition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[spread_composition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[spread_composition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[spread_composition] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'spread_composition', NULL, NULL
GO

CREATE TABLE [dbo].[bunker_pur_price_lookup]
(
[oid] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[del_date_from] [datetime] NOT NULL,
[del_date_to] [datetime] NOT NULL,
[storage_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_amt] [float] NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[bunker_pur_price_lookup_deltrg]
on [dbo].[bunker_pur_price_lookup]
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
   select @errmsg = '(bunker_pur_price_lookup) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_bunker_pur_price_lookup
   (oid,
    cmdty_code,
    del_date_from,
    del_date_to,
    storage_loc_code,
    formula_ind,	
    formula_name,	
    price_amt,
    price_uom_code,
    price_curr_code,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.cmdty_code,
   d.del_date_from,
   d.del_date_to,
   d.storage_loc_code,
   d.formula_ind,	
   d.formula_name,	
   d.price_amt,
   d.price_uom_code,
   d.price_curr_code,
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

create trigger [dbo].[bunker_pur_price_lookup_updtrg]
on [dbo].[bunker_pur_price_lookup]
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
   raiserror ('(bunker_pur_price_lookup) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(bunker_pur_price_lookup) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(bunker_pur_price_lookup) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(bunker_pur_price_lookup) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_bunker_pur_price_lookup
      (oid,
       cmdty_code,
       del_date_from,
       del_date_to,
       storage_loc_code,
       formula_ind,	
       formula_name,	
       price_amt,
       price_uom_code,
       price_curr_code,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.cmdty_code,
      d.del_date_from,
      d.del_date_to,
      d.storage_loc_code,
      d.formula_ind,	
      d.formula_name,	
      d.price_amt,
      d.price_uom_code,
      d.price_curr_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[bunker_pur_price_lookup] ADD CONSTRAINT [bunker_pur_price_lookup_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bunker_pur_price_lookup] ADD CONSTRAINT [bunker_pur_price_lookup_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[bunker_pur_price_lookup] ADD CONSTRAINT [bunker_pur_price_lookup_fk2] FOREIGN KEY ([storage_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[bunker_pur_price_lookup] ADD CONSTRAINT [bunker_pur_price_lookup_fk3] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[bunker_pur_price_lookup] ADD CONSTRAINT [bunker_pur_price_lookup_fk4] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[bunker_pur_price_lookup] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[bunker_pur_price_lookup] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[bunker_pur_price_lookup] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[bunker_pur_price_lookup] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'bunker_pur_price_lookup', NULL, NULL
GO

CREATE TABLE [dbo].[external_position]
(
[ext_pos_num] [int] NOT NULL,
[clr_brkr_num] [int] NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[strike_price] [decimal] (20, 8) NULL,
[quantity] [decimal] (20, 8) NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[external_position_deltrg]
on [dbo].[external_position]
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
   select @errmsg = '(external_position) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_external_position
(  
   ext_pos_num,
   clr_brkr_num,
   commkt_key,
   trading_prd,
   item_type,
   put_call_ind,
   strike_price,
   quantity,
   qty_uom_code,
   trans_id,
   resp_trans_id
)
select
   d.ext_pos_num,
   d.clr_brkr_num,
   d.commkt_key,
   d.trading_prd,
   d.item_type,
   d.put_call_ind,
   d.strike_price,
   d.quantity,
   d.qty_uom_code,
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

create trigger [dbo].[external_position_updtrg]
on [dbo].[external_position]
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
   raiserror ('(external_position) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(external_position) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.ext_pos_num = d.ext_pos_num)
begin
   select @errmsg = '(external_position) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.ext_pos_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(ext_pos_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.ext_pos_num = d.ext_pos_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(external_position) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_external_position
 	    (ext_pos_num,
       clr_brkr_num,
       commkt_key,
       trading_prd,
       item_type,
       put_call_ind,
       strike_price,
       quantity,
       qty_uom_code,
       trans_id,
       resp_trans_id)
   select
      d.ext_pos_num,
      d.clr_brkr_num,
      d.commkt_key,
      d.trading_prd,
      d.item_type,
      d.put_call_ind,
      d.strike_price,
      d.quantity,
      d.qty_uom_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.ext_pos_num = i.ext_pos_num 

return
GO
ALTER TABLE [dbo].[external_position] ADD CONSTRAINT [external_position_pk] PRIMARY KEY CLUSTERED  ([ext_pos_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_position] ADD CONSTRAINT [external_position_fk1] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[external_position] ADD CONSTRAINT [external_position_fk2] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[external_position] ADD CONSTRAINT [external_position_fk3] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
GRANT DELETE ON  [dbo].[external_position] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[external_position] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[external_position] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[external_position] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'external_position', NULL, NULL
GO

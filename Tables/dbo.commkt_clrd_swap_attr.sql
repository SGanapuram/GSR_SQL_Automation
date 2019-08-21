CREATE TABLE [dbo].[commkt_clrd_swap_attr]
(
[commkt_key] [int] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_commkt_clrd_swap_attr_status] DEFAULT ('A'),
[commkt_lot_size] [decimal] (20, 8) NOT NULL,
[commkt_lot_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_settlement_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_commkt_clrd_swap_attr_commkt_settlement_ind] DEFAULT ('C'),
[commkt_trading_mth_ind] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_nearby_mask] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_num_mth_out] [smallint] NOT NULL,
[comp_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd_offset] [int] NOT NULL,
[long_short_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_commkt_clrd_swap_attr_long_short_ind] DEFAULT ('L'),
[spread_qty_factor] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[margin_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_commkt_clrd_swap_attr_margin_type] DEFAULT ('P')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commkt_clrd_swap_attr_deltrg]
on [dbo].[commkt_clrd_swap_attr]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(commkt_clrd_swap_attr) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_commkt_clrd_swap_attr
(  
   commkt_key,
   status,
   commkt_lot_size,
   commkt_lot_uom_code,
   commkt_price_uom_code,
   commkt_curr_code,
   commkt_settlement_ind,
   commkt_trading_mth_ind,
   commkt_nearby_mask,
   commkt_num_mth_out,
   comp_cmdty_code,
   trading_prd_offset,
   long_short_ind,
   spread_qty_factor,
   trans_id,
   resp_trans_id
)
select
   d.commkt_key,
   d.status,
   d.commkt_lot_size,
   d.commkt_lot_uom_code,
   d.commkt_price_uom_code,
   d.commkt_curr_code,
   d.commkt_settlement_ind,
   d.commkt_trading_mth_ind,
   d.commkt_nearby_mask,
   d.commkt_num_mth_out,
   d.comp_cmdty_code,
   d.trading_prd_offset,
   d.long_short_ind,
   d.spread_qty_factor,
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

create trigger [dbo].[commkt_clrd_swap_attr_updtrg]
on [dbo].[commkt_clrd_swap_attr]
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
   raiserror ('(commkt_clrd_swap_attr) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(commkt_clrd_swap_attr) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key)
begin
   select @errmsg = '(commkt_clrd_swap_attr) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.commkt_key) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(commkt_key)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commkt_clrd_swap_attr) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_commkt_clrd_swap_attr
 	    (commkt_key,
       status,
       commkt_lot_size,
       commkt_lot_uom_code,
       commkt_price_uom_code,
       commkt_curr_code,
       commkt_settlement_ind,
       commkt_trading_mth_ind,
       commkt_nearby_mask,
       commkt_num_mth_out,
       comp_cmdty_code,
       trading_prd_offset,
       long_short_ind,
       spread_qty_factor,
       trans_id,
       resp_trans_id)
   select
 	    d.commkt_key,
      d.status,
      d.commkt_lot_size,
      d.commkt_lot_uom_code,
      d.commkt_price_uom_code,
      d.commkt_curr_code,
      d.commkt_settlement_ind,
      d.commkt_trading_mth_ind,
      d.commkt_nearby_mask,
      d.commkt_num_mth_out,
      d.comp_cmdty_code,
      d.trading_prd_offset,
      d.long_short_ind,
      d.spread_qty_factor,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key 

return
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [chk_commkt_clrd_swap_attr_commkt_settlement_ind] CHECK (([commkt_settlement_ind]='P' OR [commkt_settlement_ind]='C'))
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [chk_commkt_clrd_swap_attr_long_short_ind] CHECK (([long_short_ind]='S' OR [long_short_ind]='L'))
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [chk_commkt_clrd_swap_attr_margin_type] CHECK (([margin_type]='F' OR [margin_type]='P'))
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [chk_commkt_clrd_swap_attr_status] CHECK (([status]='I' OR [status]='A'))
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [commkt_clrd_swap_attr_pk] PRIMARY KEY CLUSTERED  ([commkt_key]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [commkt_clrd_swap_attr_fk1] FOREIGN KEY ([commkt_lot_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [commkt_clrd_swap_attr_fk2] FOREIGN KEY ([commkt_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [commkt_clrd_swap_attr_fk3] FOREIGN KEY ([commkt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [commkt_clrd_swap_attr_fk4] FOREIGN KEY ([comp_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commkt_clrd_swap_attr] ADD CONSTRAINT [commkt_clrd_swap_attr_fk5] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
GRANT DELETE ON  [dbo].[commkt_clrd_swap_attr] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commkt_clrd_swap_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commkt_clrd_swap_attr] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commkt_clrd_swap_attr] TO [next_usr]
GO

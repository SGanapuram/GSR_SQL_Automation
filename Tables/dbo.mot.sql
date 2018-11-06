CREATE TABLE [dbo].[mot]
(
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ppl_basis_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_loss_allowance] [float] NULL,
[ppl_cycle_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_num_of_cycles] [tinyint] NULL,
[ppl_split_cycle_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[ppl_tariff_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_enforce_loc_seq_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transport_trade_num] [int] NULL,
[transport_order_num] [smallint] NULL,
[transport_item_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[mot_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__mot__mot_status__01892CED] DEFAULT ('A'),
[ship_reg] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imo_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mot_deltrg]
on [dbo].[mot]
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
   select @errmsg = '(mot) Failed to obtain a valid responsible trans_id.'
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


/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'Mot',
       'DIRECT',
       convert(varchar(40), d.mot_code),
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


/* AUDIT_CODE_BEGIN */

insert dbo.aud_mot
   (mot_code,
    mot_type_code,
    mot_short_name,
    mot_full_name,
    ppl_basis_loc_code,
    ppl_loss_allowance,
    ppl_cycle_freq,
    ppl_num_of_cycles,
    ppl_split_cycle_ind,
    acct_num,
    ppl_tariff_type,
    ppl_enforce_loc_seq_ind,
    transport_trade_num,
    transport_order_num,
    transport_item_num,
    mot_status,
    ship_reg,
    imo_num,
    trans_id,
    resp_trans_id)
select
   d.mot_code,
   d.mot_type_code,
   d.mot_short_name,
   d.mot_full_name,
   d.ppl_basis_loc_code,
   d.ppl_loss_allowance,
   d.ppl_cycle_freq,
   d.ppl_num_of_cycles,
   d.ppl_split_cycle_ind,
   d.acct_num,
   d.ppl_tariff_type,
   d.ppl_enforce_loc_seq_ind,
   d.transport_trade_num,
   d.transport_order_num,
   d.transport_item_num,
   d.mot_status,
   d.ship_reg,
   d.imo_num,
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

create trigger [dbo].[mot_instrg]
on [dbo].[mot]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'Mot',
          'DIRECT',
          convert(varchar(40), i.mot_code),
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

create trigger [dbo].[mot_updtrg]
on [dbo].[mot]
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
   raiserror ('(mot) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(mot) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mot_code = d.mot_code )
begin
   raiserror ('(mot) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mot_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.mot_code = d.mot_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(mot) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Mot',
       'DIRECT',
       convert(varchar(40), i.mot_code),
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


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_mot
      (mot_code,
       mot_type_code,
       mot_short_name,
       mot_full_name,
       ppl_basis_loc_code,
       ppl_loss_allowance,
       ppl_cycle_freq,
       ppl_num_of_cycles,
       ppl_split_cycle_ind,
       acct_num,
       ppl_tariff_type,
       ppl_enforce_loc_seq_ind,
       transport_trade_num,
       transport_order_num,
       transport_item_num,
       mot_status,
       ship_reg,
       imo_num,
       trans_id,
       resp_trans_id)
   select
      d.mot_code,
      d.mot_type_code,
      d.mot_short_name,
      d.mot_full_name,
      d.ppl_basis_loc_code,
      d.ppl_loss_allowance,
      d.ppl_cycle_freq,
      d.ppl_num_of_cycles,
      d.ppl_split_cycle_ind,
      d.acct_num,
      d.ppl_tariff_type,
      d.ppl_enforce_loc_seq_ind,
      d.transport_trade_num,
      d.transport_order_num,
      d.transport_item_num,
      d.mot_status,
      d.ship_reg,
      d.imo_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.mot_code = i.mot_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[mot] ADD CONSTRAINT [CK__mot__mot_status__027D5126] CHECK (([mot_status]='I' OR [mot_status]='A'))
GO
ALTER TABLE [dbo].[mot] ADD CONSTRAINT [mot_pk] PRIMARY KEY CLUSTERED  ([mot_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mot] ADD CONSTRAINT [mot_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[mot] ADD CONSTRAINT [mot_fk2] FOREIGN KEY ([ppl_basis_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[mot] ADD CONSTRAINT [mot_fk3] FOREIGN KEY ([mot_type_code]) REFERENCES [dbo].[mot_type] ([mot_type_code])
GO
GRANT DELETE ON  [dbo].[mot] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[mot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[mot] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[mot] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'mot', NULL, NULL
GO

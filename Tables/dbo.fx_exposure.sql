CREATE TABLE [dbo].[fx_exposure]
(
[oid] [int] NOT NULL,
[fx_exp_curr_oid] [int] NOT NULL,
[fx_trading_prd] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fx_exposure_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NULL,
[open_rate_amt] [numeric] (20, 8) NULL,
[fixed_rate_amt] [numeric] (20, 8) NULL,
[linked_rate_amt] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[fx_exp_sub_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_column4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_exposure_deltrg]
on [dbo].[fx_exposure]
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
   select @errmsg = '(fx_exposure) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fx_exposure
   (oid,
    fx_exp_curr_oid,
    fx_trading_prd,
    fx_exposure_type,
    real_port_num,
    open_rate_amt,
    fixed_rate_amt,
    linked_rate_amt,
    fx_exp_sub_type,
    status,
    custom_column1,
    custom_column2,
    custom_column3,
    custom_column4,
    trans_id,
    resp_trans_id)
select
    d.oid,
    d.fx_exp_curr_oid,
    d.fx_trading_prd,
    d.fx_exposure_type,
    d.real_port_num,
    d.open_rate_amt,
    d.fixed_rate_amt,
    d.linked_rate_amt,
    d.fx_exp_sub_type,
    d.status,
    d.custom_column1,
    d.custom_column2,
    d.custom_column3,
    d.custom_column4,
    d.trans_id,
    @atrans_id
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FxExposure',
       'DIRECT',
       convert(varchar(40), d.oid),
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

create trigger [dbo].[fx_exposure_instrg]
on [dbo].[fx_exposure]
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
       'FxExposure',
       'DIRECT',
       convert(varchar(40), i.oid),
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

create trigger [dbo].[fx_exposure_updtrg]
on [dbo].[fx_exposure]
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
   raiserror ('(fx_exposure) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(fx_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(fx_exposure) new trans_id must not be older than current trans_id.',16,1)
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
      raiserror ('(fx_exposure) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fx_exposure
      (oid,
       fx_exp_curr_oid,
       fx_trading_prd,
       fx_exposure_type,
       real_port_num,
       open_rate_amt,
       fixed_rate_amt,
       linked_rate_amt,
       fx_exp_sub_type,
       status,
       custom_column1,
       custom_column2,
       custom_column3,
       custom_column4,
       trans_id,
       resp_trans_id)
   select
       d.oid,
       d.fx_exp_curr_oid,
       d.fx_trading_prd,
       d.fx_exposure_type,
       d.real_port_num,
       d.open_rate_amt,
       d.fixed_rate_amt,
       d.linked_rate_amt,
       d.fx_exp_sub_type,
       d.status,
       d.custom_column1,
       d.custom_column2,
       d.custom_column3,
       d.custom_column4,
       d.trans_id,
       i.trans_id 
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FxExposure',
       'DIRECT',
       convert(varchar(40), i.oid),
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
ALTER TABLE [dbo].[fx_exposure] ADD CONSTRAINT [fx_exposure_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fx_exposure_idx2] ON [dbo].[fx_exposure] ([fx_exp_curr_oid]) INCLUDE ([fx_exposure_type], [fx_trading_prd], [oid], [open_rate_amt], [real_port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fx_exposure_idx1] ON [dbo].[fx_exposure] ([real_port_num]) INCLUDE ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_exposure] ADD CONSTRAINT [fx_exposure_fk3] FOREIGN KEY ([fx_exposure_type]) REFERENCES [dbo].[fx_exposure_type] ([exposure_type_code])
GO
GRANT DELETE ON  [dbo].[fx_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_exposure] TO [next_usr]
GO

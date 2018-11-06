CREATE TABLE [dbo].[exposure_detail]
(
[cost_num] [int] NOT NULL,
[exposure_num] [int] NOT NULL,
[cash_exp_amt] [float] NULL,
[mtm_pl] [float] NULL,
[mtm_from_date] [datetime] NULL,
[mtm_end_date] [datetime] NULL,
[cash_from_date] [datetime] NULL,
[cash_to_date] [datetime] NULL,
[shift_exposure_num] [int] NULL,
[trans_id] [int] NOT NULL,
[credit_exposure_oid] [int] NULL,
[cost_amt] [numeric] (20, 8) NULL,
[cost_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[exposure_detail_deltrg]
on [dbo].[exposure_detail]
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
   select @errmsg = '(exposure_detail) Failed to obtain a valid responsible trans_id.'
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
       'ExposureDetail',
       'DIRECT',
       convert(varchar(40), d.cost_num),
       convert(varchar(40), d.exposure_num),
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

insert dbo.aud_exposure_detail
   (cost_num,
    exposure_num,	
    cash_exp_amt,		  
    mtm_pl,		  					
    mtm_from_date,
    mtm_end_date,		  
    cash_from_date,	   
    cash_to_date,
    shift_exposure_num,	
    credit_exposure_oid,  		  
    cost_amt,
    cost_price_curr_code,
    lc_type_code,
    trans_id,
    resp_trans_id)
select
   d.cost_num,
   d.exposure_num,	
   d.cash_exp_amt,		  
   d.mtm_pl,		  					
   d.mtm_from_date,
   d.mtm_end_date,		  
   d.cash_from_date,	   
   d.cash_to_date,		  
   d.shift_exposure_num,	
   d.credit_exposure_oid,  		  
   d.cost_amt,
   d.cost_price_curr_code,
   d.lc_type_code,
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

create trigger [dbo].[exposure_detail_instrg]
on [dbo].[exposure_detail]
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
          'ExposureDetail',
          'DIRECT',
          convert(varchar(40), i.cost_num),
          convert(varchar(40), i.exposure_num),
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

create trigger [dbo].[exposure_detail_updtrg]
on [dbo].[exposure_detail]
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
   raiserror ('(exposure_detail) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(exposure_detail) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num and
		 i.exposure_num = d.exposure_num )
begin
   raiserror ('(exposure_detail) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_num) or
   update(exposure_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_num = d.cost_num and
			           i.exposure_num = d.exposure_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(exposure_detail) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'ExposureDetail',
       'DIRECT',
       convert(varchar(40), i.cost_num),
       convert(varchar(40), i.exposure_num),
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
ALTER TABLE [dbo].[exposure_detail] ADD CONSTRAINT [exposure_detail_pk] PRIMARY KEY CLUSTERED  ([cost_num], [exposure_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [exposure_detail_idx1] ON [dbo].[exposure_detail] ([exposure_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exposure_detail] ADD CONSTRAINT [exposure_detail_fk4] FOREIGN KEY ([lc_type_code]) REFERENCES [dbo].[lc_type] ([lc_type_code])
GO
GRANT DELETE ON  [dbo].[exposure_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[exposure_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[exposure_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[exposure_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'exposure_detail', NULL, NULL
GO

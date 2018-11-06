CREATE TABLE [dbo].[cost_credit_exposure]
(
[oid] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[booking_comp_num] [int] NOT NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exposure_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[asset_cost_amount] [numeric] (20, 8) NOT NULL,
[lib_cost_amount] [numeric] (20, 8) NOT NULL,
[lc_ils_amount] [numeric] (20, 8) NOT NULL,
[lc_ild_amount] [numeric] (20, 8) NOT NULL,
[lc_ilb_amount] [numeric] (20, 8) NOT NULL,
[lc_ilo_amount] [numeric] (20, 8) NOT NULL,
[lc_els_amount] [numeric] (20, 8) NOT NULL,
[lc_eld_amount] [numeric] (20, 8) NOT NULL,
[lc_elb_amount] [numeric] (20, 8) NOT NULL,
[lc_elo_amount] [numeric] (20, 8) NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_credit_exposure_deltrg]
on [dbo].[cost_credit_exposure]
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
   select @errmsg = '(cost_credit_exposure) Failed to obtain a valid responsible trans_id.'
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

   insert dbo.aud_cost_credit_exposure
      (oid,
       acct_num,	
       booking_comp_num,	 
       curr_code,	
       exposure_type,	  
       asset_cost_amount,	
       lib_cost_amount,	
       lc_ils_amount,	
       lc_ild_amount,	
       lc_ilb_amount,	
       lc_ilo_amount,	
       lc_els_amount,	
       lc_eld_amount,	
       lc_elb_amount,	
       lc_elo_amount,	
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.acct_num,	
      d.booking_comp_num,	 
      d.curr_code,	
      d.exposure_type,	  
      d.asset_cost_amount,	
      d.lib_cost_amount,	
      d.lc_ils_amount,	
      d.lc_ild_amount,	
      d.lc_ilb_amount,	
      d.lc_ilo_amount,	
      d.lc_els_amount,	
      d.lc_eld_amount,	
      d.lc_elb_amount,	
      d.lc_elo_amount,	
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

create trigger [dbo].[cost_credit_exposure_updtrg]
on [dbo].[cost_credit_exposure]
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
   raiserror ('(cost_credit_exposure) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(cost_credit_exposure) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(cost_credit_exposure) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_credit_exposure) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_credit_exposure
      (oid,
       acct_num,	
       booking_comp_num,	 
       curr_code,	
       exposure_type,	  
       asset_cost_amount,	
       lib_cost_amount,	
       lc_ils_amount,	
       lc_ild_amount,	
       lc_ilb_amount,	
       lc_ilo_amount,	
       lc_els_amount,	
       lc_eld_amount,	
       lc_elb_amount,	
       lc_elo_amount,	
       trans_id,
       resp_trans_id)
    select
       d.oid,
       d.acct_num,	
       d.booking_comp_num,	 
       d.curr_code,	
       d.exposure_type,	  
       d.asset_cost_amount,	
       d.lib_cost_amount,	
       d.lc_ils_amount,	
       d.lc_ild_amount,	
       d.lc_ilb_amount,	
       d.lc_ilo_amount,	
       d.lc_els_amount,	
       d.lc_eld_amount,	
       d.lc_elb_amount,	
       d.lc_elo_amount,	
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.oid = i.oid

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_credit_exposure] ADD CONSTRAINT [cost_credit_exposure_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_credit_exposure] ADD CONSTRAINT [cost_credit_exposure_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost_credit_exposure] ADD CONSTRAINT [cost_credit_exposure_fk2] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost_credit_exposure] ADD CONSTRAINT [cost_credit_exposure_fk3] FOREIGN KEY ([curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[cost_credit_exposure] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_credit_exposure] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_credit_exposure] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_credit_exposure] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'cost_credit_exposure', NULL, NULL
GO

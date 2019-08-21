CREATE TABLE [dbo].[commodity_specification]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_spec_min_val] [numeric] (20, 8) NULL,
[cmdty_spec_max_val] [numeric] (20, 8) NULL,
[cmdty_spec_typical_val] [numeric] (20, 8) NULL,
[spec_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[typical_string_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_spec_test_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[standard_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_commodity_specification_standard_ind] DEFAULT ('Y'),
[equiv_pay_deduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_del_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_del_dflt_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[typical_spec_opt_val] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_paydeduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_paydeduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[regulatory_value] [float] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_specification_deltrg]
on [dbo].[commodity_specification]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   bigint

set @num_rows = @@rowcount
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
   set @errmsg = '(commodity_specification) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 16, 1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_commodity_specification
   (
    cmdty_code,
    spec_code,
    cmdty_spec_min_val,
    cmdty_spec_max_val,
    cmdty_spec_typical_val,
    spec_type,
    trans_id,
    resp_trans_id,
    typical_string_value,
    dflt_spec_test_code,
    standard_ind,
	equiv_pay_deduct_ind,
	equiv_del_cmdty_code,
	equiv_del_dflt_mkt_code,
	typical_spec_opt_val,
    prim_paydeduct_ind,
    sec_paydeduct_ind,
    regulatory_value	
   )
select
   d.cmdty_code,
   d.spec_code,
   d.cmdty_spec_min_val,
   d.cmdty_spec_max_val,
   d.cmdty_spec_typical_val,
   d.spec_type,
   d.trans_id,
   @atrans_id,
   d.typical_string_value,
   d.dflt_spec_test_code,
   d.standard_ind,
   d.equiv_pay_deduct_ind,
   d.equiv_del_cmdty_code,
   d.equiv_del_dflt_mkt_code,
   d.typical_spec_opt_val,
   d.prim_paydeduct_ind,
   d.sec_paydeduct_ind,
   d.regulatory_value	
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_specification_updtrg]
on [dbo].[commodity_specification]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

set @num_rows = @@rowcount
if @num_rows = 0
   return

set @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror('(commodity_specification) The change needs to be attached with a new trans_id', 16, 1)
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
      select @errmsg = '(commodity_specification) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 16, 1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cmdty_code = d.cmdty_code and 
                 i.spec_code = d.spec_code)
begin
   raiserror('(commodity_specification) new trans_id must not be older than current trans_id.', 16, 1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cmdty_code) or  
   update(spec_code) 
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.cmdty_code = d.cmdty_code and 
                                i.spec_code = d.spec_code )
   if (@count_num_rows = @num_rows)
      set @dummy_update = 1
   else
   begin
      raiserror ('(commodity_specification) primary key can not be changed.', 16, 1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_commodity_specification
      (
	   cmdty_code,
       spec_code,
       cmdty_spec_min_val,
       cmdty_spec_max_val,
       cmdty_spec_typical_val,
       spec_type,
       trans_id,
       resp_trans_id,
       typical_string_value,
       dflt_spec_test_code,
       standard_ind,
	   equiv_pay_deduct_ind,
	   equiv_del_cmdty_code,
	   equiv_del_dflt_mkt_code,
	   typical_spec_opt_val,
	   prim_paydeduct_ind,
	   sec_paydeduct_ind   	   
      )
   select
      d.cmdty_code,
      d.spec_code,
      d.cmdty_spec_min_val,
      d.cmdty_spec_max_val,
      d.cmdty_spec_typical_val,
      d.spec_type,
      d.trans_id,
      i.trans_id,
      d.typical_string_value,
      d.dflt_spec_test_code,
      d.standard_ind,
	  d.equiv_pay_deduct_ind,
	  d.equiv_del_cmdty_code,
	  d.equiv_del_dflt_mkt_code,
	  d.typical_spec_opt_val,
	  d.prim_paydeduct_ind,
	  d.sec_paydeduct_ind
   from deleted d, inserted i
   where d.cmdty_code = i.cmdty_code and
         d.spec_code = i.spec_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[commodity_specification] ADD CONSTRAINT [chk_commodity_specification_standard_ind] CHECK (([standard_ind]='N' OR [standard_ind]='Y'))
GO
ALTER TABLE [dbo].[commodity_specification] ADD CONSTRAINT [commodity_specification_pk] PRIMARY KEY CLUSTERED  ([cmdty_code], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_specification] ADD CONSTRAINT [commodity_specification_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_specification] ADD CONSTRAINT [commodity_specification_fk2] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[commodity_specification] ADD CONSTRAINT [commodity_specification_fk4] FOREIGN KEY ([equiv_del_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[commodity_specification] ADD CONSTRAINT [commodity_specification_fk5] FOREIGN KEY ([equiv_del_dflt_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
GRANT DELETE ON  [dbo].[commodity_specification] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_specification] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_specification] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_specification] TO [next_usr]
GO

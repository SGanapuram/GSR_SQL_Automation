CREATE TABLE [dbo].[account_credit_info]
(
[acct_num] [int] NOT NULL,
[cr_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dflt_cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[primary_sic_num] [smallint] NULL,
[acct_bus_desc] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[first_trade_date] [datetime] NULL,
[doing_bus_since_date] [datetime] NULL,
[acct_cr_info_source] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fiscal_year_end_date] [datetime] NULL,
[last_fin_doc_date] [datetime] NULL,
[acct_fin_rep_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confident_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confident_sign_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_audit_code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_date] [datetime] NULL,
[invoice_formula] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_telex_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bus_restriction_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dflt_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pvt_ind_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bank_telex_cap_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pei_guarantee_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[broker_pns_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[exposure_priority_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[prim_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_cr_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_agency_acct_num] [int] NULL,
[credit_rating] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[country_risk] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pvt_public_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_dflt_cr_info] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_account_credit_info_use_dflt_cr_info] DEFAULT ('N'),
[sector_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bus_desc1] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_bus_desc2] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[margin_doc_email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[minimum_transfer_amt] [numeric] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[account_credit_info_deltrg]
on [dbo].[account_credit_info]
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
   select @errmsg = '(account_credit_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_account_credit_info
   (acct_num,
    cr_status,
    dflt_cr_anly_init,
    primary_sic_num,
    acct_bus_desc,
    first_trade_date,
    doing_bus_since_date,
    acct_cr_info_source,
    fiscal_year_end_date,
    last_fin_doc_date,
    acct_fin_rep_freq,
    confident_ind,
    confident_sign_name,
    acct_audit_code,
    invoice_freq,
    invoice_date,
    invoice_formula,
    dflt_telex_hold_ind,
    bus_restriction_type,
    dflt_cr_term_code,
    country_code,
    pvt_ind_code,
    bank_telex_cap_ind,
    pei_guarantee_ind,
    broker_pns_type,
    cmnt_num,
    exposure_priority_code,
    prim_cr_term_code,
    sec_cr_term_code,
    credit_agency_acct_num,
    credit_rating,
    country_risk,
    pvt_public_desc,
    use_dflt_cr_info,
    sector_code,
    acct_bus_desc1, 
    acct_bus_desc2,
    margin_doc_email,
    minimum_transfer_amt,           
    trans_id,
    resp_trans_id)
select
   d.acct_num,
   d.cr_status,
   d.dflt_cr_anly_init,
   d.primary_sic_num,
   d.acct_bus_desc,
   d.first_trade_date,
   d.doing_bus_since_date,
   d.acct_cr_info_source,
   d.fiscal_year_end_date,
   d.last_fin_doc_date,
   d.acct_fin_rep_freq,
   d.confident_ind,
   d.confident_sign_name,
   d.acct_audit_code,
   d.invoice_freq,
   d.invoice_date,
   d.invoice_formula,
   d.dflt_telex_hold_ind,
   d.bus_restriction_type,
   d.dflt_cr_term_code,
   d.country_code,
   d.pvt_ind_code,
   d.bank_telex_cap_ind,
   d.pei_guarantee_ind,
   d.broker_pns_type,
   d.cmnt_num,
   d.exposure_priority_code,
   d.prim_cr_term_code,
   d.sec_cr_term_code,
   d.credit_agency_acct_num,
   d.credit_rating,
   d.country_risk,
   d.pvt_public_desc,
   d.use_dflt_cr_info,
   d.sector_code,
   d.acct_bus_desc1, 
   d.acct_bus_desc2,
   d.margin_doc_email,
   d.minimum_transfer_amt,           
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

create trigger [dbo].[account_credit_info_updtrg]
on [dbo].[account_credit_info]
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
   raiserror ('(account_credit_info) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(account_credit_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_num = d.acct_num )
begin
   raiserror ('(account_credit_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(acct_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_num = d.acct_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(account_credit_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_account_credit_info
      (acct_num,
       cr_status,
       dflt_cr_anly_init,
       primary_sic_num,
       acct_bus_desc,
       first_trade_date,
       doing_bus_since_date,
       acct_cr_info_source,
       fiscal_year_end_date,
       last_fin_doc_date,
       acct_fin_rep_freq,
       confident_ind,
       confident_sign_name,
       acct_audit_code,
       invoice_freq,
       invoice_date,
       invoice_formula,
       dflt_telex_hold_ind,
       bus_restriction_type,
       dflt_cr_term_code,
       country_code,
       pvt_ind_code,
       bank_telex_cap_ind,
       pei_guarantee_ind,
       broker_pns_type,
       cmnt_num,
       exposure_priority_code,
       prim_cr_term_code,
       sec_cr_term_code,
       credit_agency_acct_num,
       credit_rating,
       country_risk,
       pvt_public_desc,
       use_dflt_cr_info,
       sector_code,
       acct_bus_desc1, 
       acct_bus_desc2,
       margin_doc_email,
       minimum_transfer_amt,           
       trans_id,
       resp_trans_id)
   select
      d.acct_num,
      d.cr_status,
      d.dflt_cr_anly_init,
      d.primary_sic_num,
      d.acct_bus_desc,
      d.first_trade_date,
      d.doing_bus_since_date,
      d.acct_cr_info_source,
      d.fiscal_year_end_date,
      d.last_fin_doc_date,
      d.acct_fin_rep_freq,
      d.confident_ind,
      d.confident_sign_name,
      d.acct_audit_code,
      d.invoice_freq,
      d.invoice_date,
      d.invoice_formula,
      d.dflt_telex_hold_ind,
      d.bus_restriction_type,
      d.dflt_cr_term_code,
      d.country_code,
      d.pvt_ind_code,
      d.bank_telex_cap_ind,
      d.pei_guarantee_ind,
      d.broker_pns_type,
      d.cmnt_num,
      d.exposure_priority_code,
      d.prim_cr_term_code,
      d.sec_cr_term_code,
      d.credit_agency_acct_num,
      d.credit_rating,
      d.country_risk,
      d.pvt_public_desc,
      d.use_dflt_cr_info,
      d.sector_code,
      d.acct_bus_desc1, 
      d.acct_bus_desc2,
      d.margin_doc_email,
      d.minimum_transfer_amt,           
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_num = i.acct_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [chk_account_credit_info_use_dflt_cr_info] CHECK (([use_dflt_cr_info]='N' OR [use_dflt_cr_info]='Y'))
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_pk] PRIMARY KEY CLUSTERED  ([acct_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk10] FOREIGN KEY ([sector_code]) REFERENCES [dbo].[credit_sector] ([sector_code])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk2] FOREIGN KEY ([credit_agency_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk4] FOREIGN KEY ([country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk5] FOREIGN KEY ([dflt_cr_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk6] FOREIGN KEY ([prim_cr_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk7] FOREIGN KEY ([sec_cr_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk8] FOREIGN KEY ([dflt_cr_anly_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[account_credit_info] ADD CONSTRAINT [account_credit_info_fk9] FOREIGN KEY ([country_risk]) REFERENCES [dbo].[country] ([country_code])
GO
GRANT DELETE ON  [dbo].[account_credit_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[account_credit_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[account_credit_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[account_credit_info] TO [next_usr]
GO

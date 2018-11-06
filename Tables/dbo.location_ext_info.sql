CREATE TABLE [dbo].[location_ext_info]
(
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[accountant_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scheduler_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trader_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[county_code] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[city_code] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[permit_holder_acct_num] [int] NULL,
[excise_warehouse_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bonded_warehouse_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[postal_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_legal_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_lsd_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[oper_govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[oper_legal_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[location_ext_info_deltrg]
on [dbo].[location_ext_info]
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
   select @errmsg = '(location_ext_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_location_ext_info
   (loc_code,
    accountant_id,
    scheduler_id,
    trader_id,
    country_code,
    state_code,
    county_code,
    city_code,
    dflt_mot_code,
    permit_holder_acct_num,              
    excise_warehouse_loc_ind,
    bonded_warehouse_loc_ind,
    postal_code,
    facility_govt_code,
    facility_legal_desc,
    facility_lsd_code,
    oper_govt_code,
    oper_legal_desc,
    trans_id,
    resp_trans_id)
select
   d.loc_code,
   d.accountant_id,
   d.scheduler_id,
   d.trader_id,
   d.country_code,
   d.state_code,
   d.county_code,
   d.city_code,
   d.dflt_mot_code,
   d.permit_holder_acct_num,              
   d.excise_warehouse_loc_ind,
   d.bonded_warehouse_loc_ind,
   d.postal_code,
   d.facility_govt_code,
   d.facility_legal_desc,
   d.facility_lsd_code,
   d.oper_govt_code,
   d.oper_legal_desc,
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

create trigger [dbo].[location_ext_info_updtrg]
on [dbo].[location_ext_info]
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
   raiserror ('(location_ext_info) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(location_ext_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.loc_code = d.loc_code )
begin
   raiserror ('(location_ext_info) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(loc_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.loc_code = d.loc_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(location_ext_info) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_location_ext_info
      (loc_code,
       accountant_id,
       scheduler_id,
       trader_id,
       country_code,
       state_code,
       county_code,
       city_code,
       dflt_mot_code,
       permit_holder_acct_num,              
       excise_warehouse_loc_ind,
       bonded_warehouse_loc_ind,
       postal_code,
       facility_govt_code,
       facility_legal_desc,
       facility_lsd_code,
       oper_govt_code,
       oper_legal_desc,
       trans_id,
       resp_trans_id)
   select
      d.loc_code,
      d.accountant_id,
      d.scheduler_id,
      d.trader_id,
      d.country_code,
      d.state_code,
      d.county_code,
      d.city_code,
      d.dflt_mot_code,
      d.permit_holder_acct_num,              
      d.excise_warehouse_loc_ind,
      d.bonded_warehouse_loc_ind,
      d.postal_code,
      d.facility_govt_code,
      d.facility_legal_desc,
      d.facility_lsd_code,
      d.oper_govt_code,
      d.oper_legal_desc,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.loc_code = i.loc_code

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_pk] PRIMARY KEY CLUSTERED  ([loc_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk1] FOREIGN KEY ([country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk2] FOREIGN KEY ([accountant_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk3] FOREIGN KEY ([scheduler_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk4] FOREIGN KEY ([trader_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk5] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk6] FOREIGN KEY ([dflt_mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk7] FOREIGN KEY ([state_code]) REFERENCES [dbo].[state] ([state_code])
GO
ALTER TABLE [dbo].[location_ext_info] ADD CONSTRAINT [location_ext_info_fk8] FOREIGN KEY ([permit_holder_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[location_ext_info] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[location_ext_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[location_ext_info] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[location_ext_info] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[location_ext_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[location_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[location_ext_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[location_ext_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'location_ext_info', NULL, NULL
GO

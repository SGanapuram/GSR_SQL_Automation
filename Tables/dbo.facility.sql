CREATE TABLE [dbo].[facility]
(
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[facility_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[facility_short_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_long_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[stock_location_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__facility__stock___5FD33367] DEFAULT ('Y'),
[facility_owner_acct_num] [int] NULL,
[facility_owner_addr_num] [smallint] NULL,
[facility_owner_cont_num] [int] NULL,
[facility_oper_instr_num] [smallint] NULL,
[tax_jurisdiction_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[capacity] [decimal] (20, 8) NULL,
[capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[facility_deltrg]
on [dbo].[facility]
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
   select @errmsg = '(facility) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_facility
(  
   facility_code,
   facility_type_code,
   facility_short_name,
   facility_long_name,
   facility_loc_code,
   stock_location_ind,
   facility_owner_acct_num,
   facility_owner_addr_num,
   facility_owner_cont_num,
   facility_oper_instr_num,
   tax_jurisdiction_code,
   capacity,
   capacity_uom_code,
   trans_id,
   resp_trans_id
)
select
   d.facility_code,
   d.facility_type_code,
   d.facility_short_name,
   d.facility_long_name,
   d.facility_loc_code,
   d.stock_location_ind,
   d.facility_owner_acct_num,
   d.facility_owner_addr_num,
   d.facility_owner_cont_num,
   d.facility_oper_instr_num,
   d.tax_jurisdiction_code,
   d.capacity,
   d.capacity_uom_code,
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

create trigger [dbo].[facility_updtrg]
on [dbo].[facility]
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
   raiserror ('(facility) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(facility) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.facility_code = d.facility_code)
begin
   select @errmsg = '(facility) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.facility_code) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(facility_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.facility_code = d.facility_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(facility) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_facility
 	    (facility_code,
       facility_type_code,
       facility_short_name,
       facility_long_name,
       facility_loc_code,
       stock_location_ind,
       facility_owner_acct_num,
       facility_owner_addr_num,
       facility_owner_cont_num,
       facility_oper_instr_num,
       tax_jurisdiction_code,
       capacity,
       capacity_uom_code,
       trans_id,
       resp_trans_id)
   select
 	    d.facility_code,
      d.facility_type_code,
      d.facility_short_name,
      d.facility_long_name,
      d.facility_loc_code,
      d.stock_location_ind,
      d.facility_owner_acct_num,
      d.facility_owner_addr_num,
      d.facility_owner_cont_num,
      d.facility_oper_instr_num,
      d.tax_jurisdiction_code,
      d.capacity,
      d.capacity_uom_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.facility_code = i.facility_code 

return
GO
ALTER TABLE [dbo].[facility] ADD CONSTRAINT [CK__facility__stock___60C757A0] CHECK (([stock_location_ind]='N' OR [stock_location_ind]='Y'))
GO
ALTER TABLE [dbo].[facility] ADD CONSTRAINT [facility_pk] PRIMARY KEY CLUSTERED  ([facility_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[facility] ADD CONSTRAINT [facility_fk3] FOREIGN KEY ([facility_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[facility] ADD CONSTRAINT [facility_fk4] FOREIGN KEY ([facility_owner_acct_num], [facility_owner_addr_num]) REFERENCES [dbo].[account_address] ([acct_num], [acct_addr_num])
GO
ALTER TABLE [dbo].[facility] ADD CONSTRAINT [facility_fk5] FOREIGN KEY ([facility_owner_acct_num], [facility_owner_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[facility] ADD CONSTRAINT [facility_fk6] FOREIGN KEY ([facility_owner_acct_num], [facility_oper_instr_num]) REFERENCES [dbo].[account_instruction] ([acct_num], [acct_instr_num])
GO
ALTER TABLE [dbo].[facility] ADD CONSTRAINT [facility_fk7] FOREIGN KEY ([capacity_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[facility] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[facility] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[facility] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[facility] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'facility', NULL, NULL
GO

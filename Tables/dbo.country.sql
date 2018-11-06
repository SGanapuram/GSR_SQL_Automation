CREATE TABLE [dbo].[country]
(
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[no_bus_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__country__no_bus___46486B8E] DEFAULT ('Y'),
[country_num] [smallint] NOT NULL,
[country_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[int_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ext_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_limit_amt] [float] NOT NULL,
[country_limit_util_amt] [float] NULL,
[cmnt_num] [int] NULL,
[exposure_priority_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[iso_country_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[country_deltrg]
on [dbo].[country]
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
   select @errmsg = '(country) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_country
   (country_code,
    country_name,
    no_bus_ind,
    country_num,
    country_status,
    calendar_code,
    int_curr_code,
    ext_curr_code,
    country_limit_amt,
    country_limit_util_amt,
    cmnt_num,
    exposure_priority_code,
    iso_country_code,
    trans_id,
    resp_trans_id)
select
   d.country_code,
   d.country_name,
   d.no_bus_ind,
   d.country_num,
   d.country_status,
   d.calendar_code,
   d.int_curr_code,
   d.ext_curr_code,
   d.country_limit_amt,
   d.country_limit_util_amt,
   d.cmnt_num,
   d.exposure_priority_code,
   d.iso_country_code,
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

create trigger [dbo].[country_updtrg]
on [dbo].[country]
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
   raiserror ('(country) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(country) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.country_code = d.country_code )
begin
   raiserror ('(country) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(country_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.country_code = d.country_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(country) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_country
      (country_code,
       country_name,
       no_bus_ind,
       country_num,
       country_status,
       calendar_code,
       int_curr_code,
       ext_curr_code,
       country_limit_amt,
       country_limit_util_amt,
       cmnt_num,
       exposure_priority_code,
       iso_country_code,
       trans_id,
       resp_trans_id)
   select
      d.country_code,
      d.country_name,
      d.no_bus_ind,
      d.country_num,
      d.country_status,
      d.calendar_code,
      d.int_curr_code,
      d.ext_curr_code,
      d.country_limit_amt,
      d.country_limit_util_amt,
      d.cmnt_num,
      d.exposure_priority_code,
      d.iso_country_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.country_code = i.country_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[country] ADD CONSTRAINT [CK__country__no_bus___473C8FC7] CHECK (([no_bus_ind]='N' OR [no_bus_ind]='Y'))
GO
ALTER TABLE [dbo].[country] ADD CONSTRAINT [country_pk] PRIMARY KEY CLUSTERED  ([country_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[country] ADD CONSTRAINT [country_fk1] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
GRANT DELETE ON  [dbo].[country] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[country] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[country] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[country] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'country', NULL, NULL
GO

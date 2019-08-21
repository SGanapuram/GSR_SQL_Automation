CREATE TABLE [dbo].[commkt_src_alias_info]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calc_avg_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_load_start] [int] NULL,
[price_load_freq] [int] NULL,
[price_load_duration] [int] NULL,
[commkt_generate_spot_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[commkt_coded_as_spot_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commkt_src_alias_info_deltrg]
on [dbo].[commkt_src_alias_info]
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
   select @errmsg = '(commkt_src_alias_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_commkt_src_alias_info
   (commkt_key,
    price_source_code,
    alias_source_code,
    price_uom_code,
    calc_avg_price_ind,
    price_load_start,
    price_load_freq,
    price_load_duration,
    commkt_generate_spot_ind,
    commkt_coded_as_spot_ind,
    trans_id,
    resp_trans_id)
select
   d.commkt_key,
   d.price_source_code,
   d.alias_source_code,
   d.price_uom_code,
   d.calc_avg_price_ind,
   d.price_load_start,
   d.price_load_freq,
   d.price_load_duration,
   d.commkt_generate_spot_ind,
   d.commkt_coded_as_spot_ind,
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

create trigger [dbo].[commkt_src_alias_info_updtrg]
on [dbo].[commkt_src_alias_info]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(commkt_src_alias_info) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(commkt_src_alias_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and 
                 i.price_source_code = d.price_source_code and 
                 i.alias_source_code = d.alias_source_code )
begin
   raiserror ('(commkt_src_alias_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or  
   update(price_source_code) or  
   update(alias_source_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and 
                                   i.price_source_code = d.price_source_code and 
                                   i.alias_source_code = d.alias_source_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commkt_src_alias_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_commkt_src_alias_info
      (commkt_key,
       price_source_code,
       alias_source_code,
       price_uom_code,
       calc_avg_price_ind,
       price_load_start,
       price_load_freq,
       price_load_duration,
       commkt_generate_spot_ind,
       commkt_coded_as_spot_ind,
       trans_id,
       resp_trans_id)
   select
      d.commkt_key,
      d.price_source_code,
      d.alias_source_code,
      d.price_uom_code,
      d.calc_avg_price_ind,
      d.price_load_start,
      d.price_load_freq,
      d.price_load_duration,
      d.commkt_generate_spot_ind,
      d.commkt_coded_as_spot_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key and
         d.price_source_code = i.price_source_code and
         d.alias_source_code = i.alias_source_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[commkt_src_alias_info] ADD CONSTRAINT [commkt_src_alias_info_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [price_source_code], [alias_source_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commkt_src_alias_info] ADD CONSTRAINT [commkt_src_alias_info_fk1] FOREIGN KEY ([commkt_key], [price_source_code], [alias_source_code]) REFERENCES [dbo].[commkt_source_alias] ([commkt_key], [price_source_code], [alias_source_code])
GO
ALTER TABLE [dbo].[commkt_src_alias_info] ADD CONSTRAINT [commkt_src_alias_info_fk2] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[commkt_src_alias_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commkt_src_alias_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commkt_src_alias_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commkt_src_alias_info] TO [next_usr]
GO

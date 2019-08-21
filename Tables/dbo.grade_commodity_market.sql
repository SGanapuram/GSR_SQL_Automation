CREATE TABLE [dbo].[grade_commodity_market]
(
[commkt_key] [int] NOT NULL,
[curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[grade_commodity_market_deltrg]
on [dbo].[grade_commodity_market]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(grade_commodity_market) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_grade_commodity_market
(  
   commkt_key,
   curr_code,
   uom_code,
   trans_id,
   resp_trans_id
)
select
   d.commkt_key,
   d.curr_code,
   d.uom_code,
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

create trigger [dbo].[grade_commodity_market_updtrg]
on [dbo].[grade_commodity_market]
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
   raiserror ('(grade_commodity_market) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(grade_commodity_market) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and
                 i.curr_code = d.curr_code and
                 i.uom_code = d.uom_code)
begin
   select @errmsg = '(grade_commodity_market) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.commkt_key) + ',''' +
                           i.curr_code + ''',''' + i.uom_code + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or
   update(curr_code) or
   update(uom_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and
                                   i.curr_code = d.curr_code and
                                   i.uom_code = d.uom_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(grade_commodity_market) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_grade_commodity_market
   (
      commkt_key,
      curr_code,
      uom_code,
      trans_id,
      resp_trans_id
   )
   select
      d.commkt_key,
      d.curr_code,
      d.uom_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key and
         d.curr_code = i.curr_code and
         d.uom_code = i.uom_code

return
GO
ALTER TABLE [dbo].[grade_commodity_market] ADD CONSTRAINT [grade_commodity_market_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [curr_code], [uom_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[grade_commodity_market] ADD CONSTRAINT [grade_commodity_market_fk1] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[grade_commodity_market] ADD CONSTRAINT [grade_commodity_market_fk2] FOREIGN KEY ([curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[grade_commodity_market] ADD CONSTRAINT [grade_commodity_market_fk3] FOREIGN KEY ([uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[grade_commodity_market] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[grade_commodity_market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[grade_commodity_market] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[grade_commodity_market] TO [next_usr]
GO

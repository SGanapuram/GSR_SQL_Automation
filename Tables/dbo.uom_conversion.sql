CREATE TABLE [dbo].[uom_conversion]
(
[uom_conv_num] [int] NOT NULL,
[uom_code_conv_from] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[uom_code_conv_to] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_api_val] [float] NULL,
[uom_gravity_val] [float] NULL,
[uom_conv_rate] [float] NOT NULL,
[uom_conv_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[uom_conversion_deltrg]
on [dbo].[uom_conversion]
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
   select @errmsg = '(uom_conversion) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_uom_conversion
   (uom_conv_num,
    uom_code_conv_from,
    uom_code_conv_to,
    cmdty_code,
    uom_api_val,
    uom_gravity_val,
    uom_conv_rate,
    uom_conv_oper,
    trans_id,
    resp_trans_id)
select
   d.uom_conv_num,
   d.uom_code_conv_from,
   d.uom_code_conv_to,
   d.cmdty_code,
   d.uom_api_val,
   d.uom_gravity_val,
   d.uom_conv_rate,
   d.uom_conv_oper,
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

create trigger [dbo].[uom_conversion_instrg]
on [dbo].[uom_conversion]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   if exists (select * from inserted
              where cmdty_code != NULL and
                    NOT cmdty_code IN (select cmdty_code from dbo.commodity) )
   begin
      select @errmsg = '(uom_conversion) new record can not be added because it uses a cmdty_code which does not exist in the commodity table.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end

   if exists (select * from inserted
              where NOT uom_code_conv_from IN (select uom_code from dbo.uom) )
   begin
      select @errmsg = '(uom_conversion) new record can not be added because the uom_code_conv_from does not exist in the uom table.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end

   if exists (select * from inserted
              where NOT uom_code_conv_to IN (select uom_code from dbo.uom) )
   begin
      select @errmsg = '(uom_conversion) new record can not be added because the uom_code_conv_to does not exist in the uom table.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[uom_conversion_updtrg]
on [dbo].[uom_conversion]
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
   raiserror ('(uom_conversion) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(uom_conversion) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.uom_conv_num = d.uom_conv_num )
begin
   raiserror ('(uom_conversion) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(uom_conv_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.uom_conv_num = d.uom_conv_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(uom_conversion) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if update(cmdty_code)
begin
   if exists (select 1 from inserted
              where cmdty_code IS NOT NULL and
                    NOT cmdty_code IN (select cmdty_code from dbo.commodity) )
   begin
      select @errmsg = '(uom_conversion) the changes can not be saved because it uses a cmdty_code which does not exist in the commodity table.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if update(uom_code_conv_from)
begin
   if exists (select 1 from inserted
              where NOT uom_code_conv_from IN (select uom_code from dbo.uom) )
   begin
      select @errmsg = '(uom_conversion) the changes can not be saved because the uom_code_conv_from does not exist in the uom table.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end 

if update(uom_code_conv_to)
begin
   if exists (select 1 from inserted
              where NOT uom_code_conv_to IN (select uom_code from dbo.uom) )
   begin
      select @errmsg = '(uom_conversion) the changes can not be saved because the uom_code_conv_to does not exist in the uom table.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end 


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_uom_conversion
      (uom_conv_num,
       uom_code_conv_from,
       uom_code_conv_to,
       cmdty_code,
       uom_api_val,
       uom_gravity_val,
       uom_conv_rate,
       uom_conv_oper,
       trans_id,
       resp_trans_id)
   select
      d.uom_conv_num,
      d.uom_code_conv_from,
      d.uom_code_conv_to,
      d.cmdty_code,
      d.uom_api_val,
      d.uom_gravity_val,
      d.uom_conv_rate,
      d.uom_conv_oper,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.uom_conv_num = i.uom_conv_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[uom_conversion] ADD CONSTRAINT [uom_conversion_pk] PRIMARY KEY CLUSTERED  ([uom_conv_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[uom_conversion] ADD CONSTRAINT [uom_conversion_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[uom_conversion] ADD CONSTRAINT [uom_conversion_fk2] FOREIGN KEY ([uom_code_conv_from]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[uom_conversion] ADD CONSTRAINT [uom_conversion_fk3] FOREIGN KEY ([uom_code_conv_to]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[uom_conversion] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[uom_conversion] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[uom_conversion] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[uom_conversion] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'uom_conversion', NULL, NULL
GO

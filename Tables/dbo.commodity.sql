CREATE TABLE [dbo].[commodity]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_tradeable_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_loc_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_curr_conv_rate] [float] NULL,
[prim_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_category_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[grade] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[movements_require_specific_actuals] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_composite] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_deltrg]
on [dbo].[commodity]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id   bigint,
        @tablename varchar(32)

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
   select @errmsg = '(commodity) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   rollback tran
   return
end

delete dbo.cost_code
where exists (select 1
              from deleted c
              where cost_code.cost_code = c.cmdty_code and
                    c.cmdty_type = 'O')
                    
/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'Commodity',
       'DIRECT',
       convert(varchar(40), d.cmdty_code),
       null,
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


/* AUDIT_CODE_BEGIN */
insert dbo.aud_commodity
   (cmdty_code,
    cmdty_tradeable_ind,
    cmdty_type,
    cmdty_status,
    cmdty_short_name,
    cmdty_full_name,
    country_code,
    cmdty_loc_desc,
    prim_curr_code,
    prim_curr_conv_rate,
    prim_uom_code,
    sec_uom_code,
    cmdty_category_code,
    grade,
    trans_id,
    resp_trans_id,
	  movements_require_specific_actuals,
	  is_composite)
select
   d.cmdty_code,
   d.cmdty_tradeable_ind,
   d.cmdty_type,
   d.cmdty_status,
   d.cmdty_short_name,
   d.cmdty_full_name,
   d.country_code,
   d.cmdty_loc_desc,
   d.prim_curr_code,
   d.prim_curr_conv_rate,
   d.prim_uom_code,
   d.sec_uom_code,
   d.cmdty_category_code,
   d.grade,
   d.trans_id,
   @atrans_id,
   d.movements_require_specific_actuals,
   d.is_composite
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_instrg]
on [dbo].[commodity]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

insert into dbo.cost_code
    (cost_code, cost_code_desc, cost_code_type_ind, pl_implication, trans_id)
select cmdty_code, cmdty_full_name, 'M', 'OPEN', trans_id
from inserted i
where i.cmdty_type = 'O' and
      not exists (select 1
                  from dbo.cost_code c
                  where c.cost_code = i.cmdty_code)

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'Commodity',
          'DIRECT',
          convert(varchar(40), i.cmdty_code),
          null,
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

create trigger [dbo].[commodity_updtrg]
on [dbo].[commodity]
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
   raiserror ( '(commodity) The change needs to be attached with a new trans_id',16,1)
   rollback tran
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
      select @errmsg = '(commodity) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror ( @errmsg,16,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cmdty_code = d.cmdty_code )
begin
   raiserror ( '(commodity) new trans_id must not be older than current trans_id.',16,1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(cmdty_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cmdty_code = d.cmdty_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ( '(commodity) primary key can not be changed.',16,1)
      rollback tran
      return
   end
end

if update(cmdty_full_name) 
begin
   update dbo.cost_code
   set cost_code_desc = i.cmdty_full_name,
       trans_id = i.trans_id
   from inserted i
   where cost_code.cost_code = i.cmdty_code and
         i.cmdty_type = 'O'
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Commodity',
       'DIRECT',
       convert(varchar(40), i.cmdty_code),
       null,
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

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_commodity
      (cmdty_code,
       cmdty_tradeable_ind,
       cmdty_type,
       cmdty_status,
       cmdty_short_name,
       cmdty_full_name,
       country_code,
       cmdty_loc_desc,
       prim_curr_code,
       prim_curr_conv_rate,
       prim_uom_code,
       sec_uom_code,
       cmdty_category_code,
       grade,
       trans_id,
       resp_trans_id,
	     movements_require_specific_actuals,
	     is_composite)
   select
      d.cmdty_code,
      d.cmdty_tradeable_ind,
      d.cmdty_type,
      d.cmdty_status,
      d.cmdty_short_name,
      d.cmdty_full_name,
      d.country_code,
      d.cmdty_loc_desc,
      d.prim_curr_code,
      d.prim_curr_conv_rate,
      d.prim_uom_code,
      d.sec_uom_code,
      d.cmdty_category_code,
      d.grade,
      d.trans_id,
      i.trans_id,
	    d.movements_require_specific_actuals,
	    d.is_composite
   from deleted d, inserted i
   where d.cmdty_code = i.cmdty_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[commodity] ADD CONSTRAINT [commodity_pk] PRIMARY KEY CLUSTERED  ([cmdty_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_POSGRID_idx1] ON [dbo].[commodity] ([cmdty_code]) INCLUDE ([cmdty_short_name], [cmdty_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_idx2] ON [dbo].[commodity] ([cmdty_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity] ADD CONSTRAINT [commodity_fk1] FOREIGN KEY ([cmdty_type]) REFERENCES [dbo].[commodity_type] ([cmdty_type_code])
GO
ALTER TABLE [dbo].[commodity] ADD CONSTRAINT [commodity_fk2] FOREIGN KEY ([country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[commodity] ADD CONSTRAINT [commodity_fk3] FOREIGN KEY ([prim_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[commodity] ADD CONSTRAINT [commodity_fk4] FOREIGN KEY ([sec_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[commodity] ADD CONSTRAINT [commodity_fk5] FOREIGN KEY ([cmdty_category_code]) REFERENCES [dbo].[commodity_category] ([cmdty_category_code])
GO
ALTER TABLE [dbo].[commodity] ADD CONSTRAINT [commodity_fk6] FOREIGN KEY ([prim_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[commodity] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity] TO [next_usr]
GO

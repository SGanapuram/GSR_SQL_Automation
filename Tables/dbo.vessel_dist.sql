CREATE TABLE [dbo].[vessel_dist]
(
[oid] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_qty] [numeric] (20, 8) NOT NULL,
[alloc_qty] [numeric] (20, 8) NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[avg_price] [numeric] (20, 8) NOT NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NOT NULL,
[pos_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[vessel_dist_deltrg]
on [dbo].[vessel_dist]
for delete
as
declare @num_rows      int,
        @errmsg        varchar(255),
        @atrans_id     int,
        @create_audit  int

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
   select @errmsg = '(vessel_dist) Failed to obtain a valid responsible trans_id.'
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

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'VesselDist',
       'DIRECT',
       convert(varchar(40), d.oid),
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
where it.trans_id = @atrans_id

/* END_TRANSACTION_TOUCH */

/* AUDIT_CODE_BEGIN */

insert dbo.aud_vessel_dist
   (oid,
    commkt_key,
    trading_prd,
    key1,
    key2,
    key3,
    p_s_ind,
    dist_type,
    dist_status,
    dist_qty,
    alloc_qty,
    qty_uom_code,
    avg_price,
    price_uom_code,
    price_curr_code,
    real_port_num,
    pos_num,
    trans_id,
    resp_trans_id)
select
   d.oid,
   d.commkt_key,
   d.trading_prd,
   d.key1,
   d.key2,
   d.key3,
   d.p_s_ind,
   d.dist_type,
   d.dist_status,
   d.dist_qty,
   d.alloc_qty,
   d.qty_uom_code,
   d.avg_price,
   d.price_uom_code,
   d.price_curr_code,
   d.real_port_num,
   d.pos_num,
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

create trigger [dbo].[vessel_dist_instrg]
on [dbo].[vessel_dist]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return
   
declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'VesselDist'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */
      insert into dbo.als_run_touch
          (als_module_group_id, operation, entity_name,key1,key2,
           key3,key4,key5,key6,key7,key8,trans_id,sequence)
       select a.als_module_group_id,
              'I',
              @the_entity_name,
              convert(varchar(40), oid),
              null,
              null,
              null,
              null,
              null,
              null,
              null,
              i.trans_id,
              @the_sequence
       from dbo.als_module_entity a,
            dbo.server_config sc,
            inserted i
       where a.als_module_group_id = sc.als_module_group_id AND
             ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
               ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
               ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
               ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
               ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
               ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
             ) AND
             (a.operation_type_mask & 1) = 1 AND
             a.entity_name = @the_entity_name

       /* END_ALS_RUN_TOUCH */

       /* BEGIN_TRANSACTION_TOUCH */
       if @the_tran_type <> 'E'
       begin
          insert dbo.transaction_touch
          select 'INSERT',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), oid),
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 i.trans_id,
                 @the_sequence
          from inserted i
       end

       /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch
           (als_module_group_id, operation, entity_name,key1,key2,
            key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
             a.entity_name = @the_entity_name AND
             i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'
      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[vessel_dist_updtrg]
on [dbo].[vessel_dist]
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
   raiserror ('(vessel_dist) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(vessel_dist) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(vessel_dist) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
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
      raiserror ('(vessel_dist) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_vessel_dist
      (oid,
       commkt_key,
       trading_prd,
       key1,
       key2,
       key3,
       p_s_ind,
       dist_type,
       dist_status,
       dist_qty,
       alloc_qty,
       qty_uom_code,
       avg_price,
       price_uom_code,
       price_curr_code,
       real_port_num,
       pos_num,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.commkt_key,
      d.trading_prd,
      d.key1,
      d.key2,
      d.key3,
      d.p_s_ind,
      d.dist_type,
      d.dist_status,
      d.dist_qty,
      d.alloc_qty,
      d.qty_uom_code,
      d.avg_price,
      d.price_uom_code,
      d.price_curr_code,
      d.real_port_num,
      d.pos_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'VesselDist'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */
      insert into dbo.als_run_touch
          (als_module_group_id, operation, entity_name,key1,key2,
           key3,key4,key5,key6,key7,key8,trans_id,sequence)
       select a.als_module_group_id,
              'U',
              @the_entity_name,
              convert(varchar(40), oid),
              null,
              null,
              null,
              null,
              null,
              null,
              null,
              i.trans_id,
              @the_sequence
       from dbo.als_module_entity a,
            dbo.server_config sc,
            inserted i
       where a.als_module_group_id = sc.als_module_group_id AND
             ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
               ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
               ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
               ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
               ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
               ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
             ) AND
             (a.operation_type_mask & 2) = 2 AND
             a.entity_name = @the_entity_name

       /* END_ALS_RUN_TOUCH */

       /* BEGIN_TRANSACTION_TOUCH */
       if @the_tran_type <> 'E'
       begin
          insert dbo.transaction_touch
          select 'UPDATE',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), oid),
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 i.trans_id,
                 @the_sequence
          from inserted i
       end

       /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch
           (als_module_group_id, operation, entity_name,key1,key2,
            key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
             a.entity_name = @the_entity_name AND
             i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), oid),
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'
      /* END_TRANSACTION_TOUCH */
   end

return
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [CK__vessel_di__dist___5D36BDDE] CHECK (([dist_status]='E' OR [dist_status]='F' OR [dist_status]='U'))
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [CK__vessel_di__dist___5C4299A5] CHECK (([dist_type]='B' OR [dist_type]='V'))
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [CK__vessel_di__p_s_i__5B4E756C] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [vessel_dist_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [vessel_dist_fk1] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [vessel_dist_fk2] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [vessel_dist_fk3] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [vessel_dist_fk4] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [vessel_dist_fk5] FOREIGN KEY ([real_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [vessel_dist_fk6] FOREIGN KEY ([pos_num]) REFERENCES [dbo].[position] ([pos_num])
GO
GRANT DELETE ON  [dbo].[vessel_dist] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[vessel_dist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[vessel_dist] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[vessel_dist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'vessel_dist', NULL, NULL
GO

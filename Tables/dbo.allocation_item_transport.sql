CREATE TABLE [dbo].[allocation_item_transport]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parcel_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[x_transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[barge_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fsc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lay_days_start_date] [datetime] NULL,
[lay_days_end_date] [datetime] NULL,
[eta_date] [datetime] NULL,
[bl_date] [datetime] NULL,
[nor_date] [datetime] NULL,
[load_cmnc_date] [datetime] NULL,
[load_compl_date] [datetime] NULL,
[disch_cmnc_date] [datetime] NULL,
[disch_compl_date] [datetime] NULL,
[bl_qty] [float] NULL,
[bl_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bl_qty_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_qty] [float] NULL,
[load_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_qty_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_qty] [float] NULL,
[disch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_qty_gross_net_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pump_on_date] [datetime] NULL,
[pump_off_date] [datetime] NULL,
[bl_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bl_ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_disch_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_disch_ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_disch_date] [datetime] NULL,
[hoses_disconnected_date] [datetime] NULL,
[bl_sec_qty] [float] NULL,
[load_sec_qty] [float] NULL,
[disch_sec_qty] [float] NULL,
[bl_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_input_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__allocatio__manua__2CF2ADDF] DEFAULT ('N'),
[load_net_qty] [float] NULL,
[disch_net_qty] [float] NULL,
[bl_net_qty] [float] NULL,
[load_sec_net_qty] [float] NULL,
[disch_sec_net_qty] [float] NULL,
[bl_sec_net_qty] [float] NULL,
[trans_id] [int] NOT NULL,
[customs_imp_exp_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[declaration_date] [datetime] NULL,
[tank_num] [int] NULL,
[transport_arrival_date] [datetime] NULL,
[transport_depart_date] [datetime] NULL,
[hoses_connected_date] [datetime] NULL,
[negotiated_date] [datetime] NULL,
[nor_accp_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_item_transpo_deltrg]
on [dbo].[allocation_item_transport]
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
   select @errmsg = '(allocation_item_transport) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   rollback tran
   return
end


insert dbo.aud_allocation_item_transport
   (alloc_num,
    alloc_item_num,
    transportation,
    parcel_num,
    x_transportation,
    barge_name,
    fsc_ind,
    lay_days_start_date,
    lay_days_end_date,
    eta_date,
    bl_date,
    nor_date,
    load_cmnc_date,
    load_compl_date,
    disch_cmnc_date,
    disch_compl_date,
    bl_qty,
    bl_qty_uom_code,
    bl_qty_gross_net_ind,
    load_qty,
    load_qty_uom_code,
    load_qty_gross_net_ind,
    disch_qty,
    disch_qty_uom_code,
    disch_qty_gross_net_ind,
    pump_on_date,
    pump_off_date,
    bl_actual_ind,
    bl_ticket_num,
    load_disch_actual_ind,
    load_disch_ticket_num,
    load_disch_date,
    hoses_disconnected_date,
    bl_sec_qty,
    load_sec_qty,
    disch_sec_qty,
    bl_sec_qty_uom_code,
    load_sec_qty_uom_code,
    disch_sec_qty_uom_code,
    origin_country_code,
    manual_input_sec_ind,
    load_net_qty,
    disch_net_qty,
    bl_net_qty,
    load_sec_net_qty,
    disch_sec_net_qty,
    bl_sec_net_qty,
    customs_imp_exp_num,
    declaration_date,
    tank_num,
    transport_arrival_date,
    transport_depart_date,
    hoses_connected_date,
    negotiated_date,
	nor_accp_date,
    trans_id,
    resp_trans_id)
select
   d.alloc_num,
   d.alloc_item_num,
   d.transportation,
   d.parcel_num,
   d.x_transportation,
   d.barge_name,
   d.fsc_ind,
   d.lay_days_start_date,
   d.lay_days_end_date,
   d.eta_date,
   d.bl_date,
   d.nor_date,
   d.load_cmnc_date,
   d.load_compl_date,
   d.disch_cmnc_date,
   d.disch_compl_date,
   d.bl_qty,
   d.bl_qty_uom_code,
   d.bl_qty_gross_net_ind,
   d.load_qty,
   d.load_qty_uom_code,
   d.load_qty_gross_net_ind,
   d.disch_qty,
   d.disch_qty_uom_code,
   d.disch_qty_gross_net_ind,
   d.pump_on_date,
   d.pump_off_date,
   d.bl_actual_ind,
   d.bl_ticket_num,
   d.load_disch_actual_ind,
   d.load_disch_ticket_num,
   d.load_disch_date,
   d.hoses_disconnected_date,
   d.bl_sec_qty,
   d.load_sec_qty,
   d.disch_sec_qty,
   d.bl_sec_qty_uom_code,
   d.load_sec_qty_uom_code,
   d.disch_sec_qty_uom_code,
   d.origin_country_code,
   d.manual_input_sec_ind,
   d.load_net_qty,
   d.disch_net_qty,
   d.bl_net_qty,
   d.load_sec_net_qty,
   d.disch_sec_net_qty,
   d.bl_sec_net_qty,
   d.customs_imp_exp_num,
   d.declaration_date,
   d.tank_num,
   d.transport_arrival_date,
   d.transport_depart_date,
   d.hoses_connected_date,
   d.negotiated_date,
   d.nor_accp_date,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'AllocationItemTransport'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK)
      where it.trans_id = @atrans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.alloc_num),
             convert(varchar(40), d.alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           deleted d
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.alloc_num),
             convert(varchar(40), d.alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from deleted d

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.alloc_num),
             convert(varchar(40), d.alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           deleted d,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name AND
            it.trans_id = @atrans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.alloc_num),
             convert(varchar(40), d.alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           deleted d
      where it.trans_id = @atrans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_item_transpo_instrg]
on [dbo].[allocation_item_transport]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'AllocationItemTransport'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'INSERT',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),alloc_num),
                convert(varchar(40),alloc_item_num),
                null,
                null,
                null,
                null,
                null,
                null,
                i.trans_id,
                @the_sequence
         from inserted i

         /* END_TRANSACTION_TOUCH */
      end
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
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

create trigger [dbo].[allocation_item_transpo_updtrg]
on [dbo].[allocation_item_transport]
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
   raiserror ('(allocation_item_transport) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(allocation_item_transport) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and 
                 i.alloc_item_num = d.alloc_item_num )
begin
   raiserror ('(allocation_item_transport) new trans_id must not be older than current trans_id.',10,1)
   rollback tran
   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or  
   update(alloc_item_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and 
                                   i.alloc_item_num = d.alloc_item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(allocation_item_transport) primary key can not be changed.',10,1)
      rollback tran
      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation_item_transport
      (alloc_num,
       alloc_item_num,
       transportation,
       parcel_num,
       x_transportation,
       barge_name,
       fsc_ind,
       lay_days_start_date,
       lay_days_end_date,
       eta_date,
       bl_date,
       nor_date,
       load_cmnc_date,
       load_compl_date,
       disch_cmnc_date,
       disch_compl_date,
       bl_qty,
       bl_qty_uom_code,
       bl_qty_gross_net_ind,
       load_qty,
       load_qty_uom_code,
       load_qty_gross_net_ind,
       disch_qty,
       disch_qty_uom_code,
       disch_qty_gross_net_ind,
       pump_on_date,
       pump_off_date,
       bl_actual_ind,
       bl_ticket_num,
       load_disch_actual_ind,
       load_disch_ticket_num,
       load_disch_date,
       hoses_disconnected_date,
       bl_sec_qty,
       load_sec_qty,
       disch_sec_qty,
       bl_sec_qty_uom_code,
       load_sec_qty_uom_code,
       disch_sec_qty_uom_code,
       origin_country_code,
       manual_input_sec_ind,
       load_net_qty,
       disch_net_qty,
       bl_net_qty,
       load_sec_net_qty,
       disch_sec_net_qty,
       bl_sec_net_qty,
       customs_imp_exp_num,
       declaration_date,
       tank_num,
       transport_arrival_date,
       transport_depart_date,
       hoses_connected_date,
       negotiated_date,
	   nor_accp_date,
       trans_id,
       resp_trans_id)
   select
      d.alloc_num,
      d.alloc_item_num,
      d.transportation,
      d.parcel_num,
      d.x_transportation,
      d.barge_name,
      d.fsc_ind,
      d.lay_days_start_date,
      d.lay_days_end_date,
      d.eta_date,
      d.bl_date,
      d.nor_date,
      d.load_cmnc_date,
      d.load_compl_date,
      d.disch_cmnc_date,
      d.disch_compl_date,
      d.bl_qty,
      d.bl_qty_uom_code,
      d.bl_qty_gross_net_ind,
      d.load_qty,
      d.load_qty_uom_code,
      d.load_qty_gross_net_ind,
      d.disch_qty,
      d.disch_qty_uom_code,
      d.disch_qty_gross_net_ind,
      d.pump_on_date,
      d.pump_off_date,
      d.bl_actual_ind,
      d.bl_ticket_num,
      d.load_disch_actual_ind,
      d.load_disch_ticket_num,
      d.load_disch_date,
      d.hoses_disconnected_date,
      d.bl_sec_qty,
      d.load_sec_qty,
      d.disch_sec_qty,
      d.bl_sec_qty_uom_code,
      d.load_sec_qty_uom_code,
      d.disch_sec_qty_uom_code,
      d.origin_country_code,
      d.manual_input_sec_ind,
      d.load_net_qty,
      d.disch_net_qty,
      d.bl_net_qty,
      d.load_sec_net_qty,
      d.disch_sec_net_qty,
      d.bl_sec_net_qty,
      d.customs_imp_exp_num,
      d.declaration_date,
      d.tank_num,
      d.transport_arrival_date,
      d.transport_depart_date,
      d.hoses_connected_date,
      d.negotiated_date,
	  d.nor_accp_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.alloc_num = i.alloc_num and
         d.alloc_item_num = i.alloc_item_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'AllocationItemTransport'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'UPDATE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),alloc_num),
                convert(varchar(40),alloc_item_num),
                null,
                null,
                null,
                null,
                null,
                null,
                i.trans_id,
                @the_sequence
         from inserted i

         /* END_TRANSACTION_TOUCH */
      end
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end


return
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk2] FOREIGN KEY ([origin_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk3] FOREIGN KEY ([bl_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk4] FOREIGN KEY ([load_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk5] FOREIGN KEY ([disch_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk6] FOREIGN KEY ([bl_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk7] FOREIGN KEY ([load_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk8] FOREIGN KEY ([disch_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item_transport] ADD CONSTRAINT [allocation_item_transport_fk9] FOREIGN KEY ([tank_num]) REFERENCES [dbo].[location_tank_info] ([tank_num])
GO
GRANT DELETE ON  [dbo].[allocation_item_transport] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_item_transport] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_item_transport] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_item_transport] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'allocation_item_transport', NULL, NULL
GO

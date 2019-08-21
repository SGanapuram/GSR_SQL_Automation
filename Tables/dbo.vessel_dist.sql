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
        @atrans_id     bigint,
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
   raiserror (@errmsg,16,1)
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
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [chk_vessel_dist_dist_status] CHECK (([dist_status]='E' OR [dist_status]='F' OR [dist_status]='U'))
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [chk_vessel_dist_dist_type] CHECK (([dist_type]='B' OR [dist_type]='V'))
GO
ALTER TABLE [dbo].[vessel_dist] ADD CONSTRAINT [chk_vessel_dist_p_s_ind] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
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

CREATE TABLE [dbo].[aud_edpl_event]
(
[oid] [int] NOT NULL,
[status] [tinyint] NOT NULL,
[event_trans_id] [int] NOT NULL,
[app_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_id] [int] NULL,
[key1] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[cost_num] [int] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_num] [smallint] NULL,
[inv_num] [int] NULL,
[real_port_num] [int] NULL,
[pos_num] [int] NULL,
[event_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[related_event_ids] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_edpl_event] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_edpl_event] TO [next_usr]
GO

CREATE TABLE [dbo].[aud_eipp_task]
(
[oid] [int] NOT NULL,
[creation_date] [datetime] NOT NULL,
[eipp_entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[eipp_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[eipp_substatus] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[task_name_oid] [int] NOT NULL,
[task_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[op_trans_id] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[substatus_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_eipp_task] ON [dbo].[aud_eipp_task] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_eipp_task_idx1] ON [dbo].[aud_eipp_task] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_eipp_task] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_eipp_task] TO [next_usr]
GO

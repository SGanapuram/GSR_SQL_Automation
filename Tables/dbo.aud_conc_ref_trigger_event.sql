CREATE TABLE [dbo].[aud_conc_ref_trigger_event]
(
[oid] [int] NOT NULL,
[trigger_event] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event_desc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_trigger_event] ON [dbo].[aud_conc_ref_trigger_event] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_trigger_event_idx1] ON [dbo].[aud_conc_ref_trigger_event] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_ref_trigger_event] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_ref_trigger_event] TO [next_usr]
GO

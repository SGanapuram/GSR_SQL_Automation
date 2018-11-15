CREATE TABLE [dbo].[aud_exec_logistics_details]
(
[oid] [int] NOT NULL,
[group_num] [int] NULL,
[line_num] [int] NULL,
[conc_exec_weight_oid] [int] NULL,
[conc_ref_result_type_oid] [int] NULL,
[from_date] [datetime] NULL,
[from_date_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[to_date] [datetime] NULL,
[to_date_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transporter_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_passage_date] [datetime] NULL,
[title_date_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[contract_exec_oid] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exec_logistics_details] ON [dbo].[aud_exec_logistics_details] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_exec_logistics_details_idx1] ON [dbo].[aud_exec_logistics_details] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_exec_logistics_details] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_exec_logistics_details] TO [next_usr]
GO

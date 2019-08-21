CREATE TABLE [dbo].[aud_idms_department_mapping]
(
[idms_dept_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[idms_dept_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[newsgrazer_dept_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_idms_department_mapping] ON [dbo].[aud_idms_department_mapping] ([idms_dept_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_idms_department_mapp_idx1] ON [dbo].[aud_idms_department_mapping] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_idms_department_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_idms_department_mapping] TO [next_usr]
GO

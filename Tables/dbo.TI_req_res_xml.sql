CREATE TABLE [dbo].[TI_req_res_xml]
(
[oid] [int] NOT NULL,
[request_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[response_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inbound_data_oid] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_req_res_xml] ADD CONSTRAINT [TI_req_res_xml_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TI_req_res_xml] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_req_res_xml] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_req_res_xml] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_req_res_xml] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_req_res_xml', NULL, NULL
GO

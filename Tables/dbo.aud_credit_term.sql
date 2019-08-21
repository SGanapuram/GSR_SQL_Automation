CREATE TABLE [dbo].[aud_credit_term]
(
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[credit_term_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[credit_term_contr_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_secure_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_term] ON [dbo].[aud_credit_term] ([credit_term_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_term_idx1] ON [dbo].[aud_credit_term] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_credit_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_term] TO [next_usr]
GO

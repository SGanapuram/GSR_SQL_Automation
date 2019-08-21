CREATE TABLE [dbo].[aud_account_instruction]
(
[acct_num] [int] NOT NULL,
[acct_instr_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_instr_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_addr_num] [smallint] NOT NULL,
[acct_cont_num] [int] NOT NULL,
[bank_acct_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[num_of_doc_copies] [tinyint] NULL,
[send_doc_by_media] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[instr_analyst_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confirm_template_oid] [int] NULL,
[confirm_method_oid] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_instruction] ON [dbo].[aud_account_instruction] ([acct_num], [acct_instr_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_instruction_idx1] ON [dbo].[aud_account_instruction] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_instruction] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_instruction] TO [next_usr]
GO

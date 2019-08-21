CREATE TABLE [dbo].[contract_execution]
(
[oid] [int] NOT NULL,
[exec_purch_sale_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parent_exec_id] [int] NULL,
[pcnt_factor] [float] NULL,
[exec_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[custom_exec_num] [int] NULL,
[conc_contract_oid] [int] NULL,
[prorated_flat_amt] [float] NULL,
[flat_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract_execution] ADD CONSTRAINT [contract_execution_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contract_execution] ADD CONSTRAINT [contract_execution_fk1] FOREIGN KEY ([parent_exec_id]) REFERENCES [dbo].[contract_execution] ([oid])
GO
ALTER TABLE [dbo].[contract_execution] ADD CONSTRAINT [contract_execution_fk2] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[contract_execution] ADD CONSTRAINT [contract_execution_fk3] FOREIGN KEY ([flat_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[contract_execution] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[contract_execution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[contract_execution] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[contract_execution] TO [next_usr]
GO

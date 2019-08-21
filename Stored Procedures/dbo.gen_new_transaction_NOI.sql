SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[gen_new_transaction_NOI]
(
   @app_name    VARCHAR(80) = 'osql',
   @trans_type  CHAR(1) = 'U'
)
AS
set nocount on
set xact_abort on
declare @rowcount  int
declare @loginame  varchar(30)
declare @init      char(3)
declare @status    int
declare @workstation_name varchar(20) 
   IF @app_name = ''
   BEGIN
      print 'You must give a NON-EMPTY string for the argument @app_name'
      return 1
   END
   IF @trans_type NOT IN ('U', 'E', 'S', 'A', 'I')
   BEGIN
      PRINT 'You must give a valid code for the argument @trans_type'
      RETURN 1
   END
   SELECT @init = NULL
   SELECT @loginame = SUBSTRING(loginame,CHARINDEX('\',loginame)+1,30),
          @workstation_name = RTRIM(hostname)
   FROM master..sysprocesses WHERE spid = @@spid
   SELECT @init = user_init 
   FROM dbo.icts_user 
   WHERE user_logon_id = @loginame
   IF @init IS NULL  SELECT @init = @loginame
   BEGIN TRY
   BEGIN TRAN
   EXEC @status = dbo.get_new_num_NOI 'trans_id', 0
   IF @status = 0
   BEGIN
      INSERT INTO dbo.icts_transaction 
           (trans_id, type, user_init, tran_date,
            app_name, app_revision, spid, workstation_id)
      SELECT last_num, @trans_type, @init, GETDATE(), @app_name, NULL, @@spid, @workstation_name
      FROM dbo.icts_trans_sequence    
      WHERE oid = 1
      SELECT @rowcount = @@rowcount
      IF @rowcount = 1
         SELECT @status = 0
      ELSE
         SELECT @status = 1
   END
   IF @status = 0
   BEGIN
      IF @@trancount > 0
         COMMIT TRAN
   END
   ELSE
   BEGIN
      IF @@trancount > 0
         ROLLBACK TRAN
   END
   END TRY
   BEGIN CATCH
   END CATCH
   RETURN @status
GO
GRANT EXECUTE ON  [dbo].[gen_new_transaction_NOI] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[gen_new_transaction_NOI] TO [next_usr]
GO

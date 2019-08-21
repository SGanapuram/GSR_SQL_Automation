SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[ALS_RUN_to_skip]

(

   @als_name          varchar(40),

   @sequence          int

)

AS

set nocount on

set xact_abort on

declare @als_module_group_id   int,

        @smsg                  varchar(512),

        @rows_affected         int



   IF @als_name IS NULL

   BEGIN

      set @smsg = 'Please specify an ALS NAME as input. Ex: MainALS/ExtendedALS..'

      goto report_usage

   END



   select @als_module_group_id = als_module_group_id 

   from dbo.server_config with (nolock)

   where als_module_group_desc = @als_name

      

   IF @als_module_group_id IS NULL 

   BEGIN

      set @smsg = 'Could not find the given ALS NAME, please specify a proper ALS NAME as input..'

      goto report_usage

   END



   IF @sequence IS NULL

   BEGIN

      set @smsg = 'Please specify a sequence number to skip/reprocess for an ALS module ID..'

      goto report_usage

   END



   -- UPDATE als_run_status_id to 3 - FAILED (it means to SKIP)                                          

   BEGIN TRAN

   BEGIN TRY

	   UPDATE dbo.als_run 

	   SET als_run_status_id = 3    /* FAILED */

		 WHERE sequence = @sequence AND 

			     als_module_group_id = @als_module_group_id

     set @rows_affected = @@rowcount

   END TRY

   BEGIN CATCH

	   PRINT '=> Failed to update the als_run table due to the error:'

	   PRINT '==> ERROR: ' + ERROR_MESSAGE()

	   IF @@TRANCOUNT > 0

	      ROLLBACK TRAN

	   RETURN 1

   END CATCH

   COMMIT TRAN

   if @rows_affected > 0

	    print '=> The status of the als ''' + @als_name + ''' was set to ''FAILED'' (for skip)!'

	 else

	    print '=> The status of the als ''' + @als_name + ''' was not reset to ''FAILED''???'

   return 0	



report_usage:

print @smsg

print 'Usage: exec @status = dbo.ALS_RUN_to_skip'

print '                               @als_name = ''?'','

print '                               @sequence = ?'

return 2

GO
GRANT EXECUTE ON  [dbo].[ALS_RUN_to_skip] TO [next_usr]
GO

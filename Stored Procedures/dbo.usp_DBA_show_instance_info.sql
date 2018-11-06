SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_DBA_show_instance_info]
as
set nocount on
declare @collation              varchar(50),
        @edition                varchar(50),
        @instance_name          varchar(50),
        @failover_clustered     varchar(50),
        @full_text_installation varchar(50),
        @security               varchar(50),
        @single_user            varchar(50),
        @license_type           varchar(50),
        @machine_name           varchar(50),
        @number_of_licenses     varchar(50),
        @process_ID             varchar(50),
        @product_version        varchar(50),
        @product_level          varchar(50),
        @server_name            varchar(50)


SELECT @collation = CONVERT(varchar, SERVERPROPERTY('COLLATION')),
       @edition = CONVERT(varchar, SERVERPROPERTY('EDITION')),
       @instance_name = 
          CASE WHEN CONVERT(varchar, SERVERPROPERTY('InstanceName')) IS NULL
                  THEN 'DEFAULT INSTANCE'
               ELSE CONVERT(varchar, SERVERPROPERTY('InstanceName'))
          END,
       @failover_clustered = 
          CASE WHEN CONVERT(varchar, SERVERPROPERTY('ISClustered')) = 1
                  THEN 'CLUSTERED'
               WHEN CONVERT(varchar, SERVERPROPERTY('ISClustered')) = 0
                  THEN 'NOT CLUSTERED'
               ELSE 'INVALID INPUT/ERROR'
          END,	
       @full_text_installation = 
          CASE WHEN CONVERT(varchar, SERVERPROPERTY('ISFullTextInstalled')) = 1
                  THEN 'Full Text - Installed'
               WHEN CONVERT(varchar, SERVERPROPERTY('ISFulltextInstalled')) = 0
                  THEN 'Full Text - NOT Installed'
               ELSE 'INVALID INPUT/ERROR'
          END,
       @security = 	
          CASE WHEN CONVERT(varchar, SERVERPROPERTY('ISIntegratedSecurityOnly')) = 1
                  THEN 'Integrated Security'
               WHEN CONVERT(varchar, SERVERPROPERTY('ISIntegratedSecurityOnly')) = 0
                  THEN 'SQL Server Security'
               ELSE 'INVALID INPUT/ERROR'
          END,
        @single_user =
          CASE WHEN CONVERT(varchar, SERVERPROPERTY('ISSingleUser')) = 1
                  THEN 'Single User'
               WHEN CONVERT(varchar, SERVERPROPERTY('ISSingleUser')) = 0
                  THEN 'Multi User'
               ELSE 'INVALID INPUT/ERROR'
          END,
        @license_type =
          CASE WHEN CONVERT(varchar, SERVERPROPERTY('LicenseType')) = 'PER_SEAT'
                  THEN 'Per Seat Mode'
               WHEN CONVERT(varchar, SERVERPROPERTY('LicenseType')) = 'PER_PROCESSOR'
                  THEN 'Per Processor Mode'
               ELSE 'Disabled'
          END,
        @machine_name = CONVERT(varchar, SERVERPROPERTY('MachineName')),
        @number_of_licenses = CONVERT(varchar, SERVERPROPERTY('NumLicenses')),

        /* To identify which sqlservr.exe belongs to this instance */
        @process_ID = CONVERT(varchar, SERVERPROPERTY('ProcessID')), 
        /* The version of SQL Server instance in the form: major.minor.build */	
        @product_version = CONVERT(varchar, SERVERPROPERTY('ProductVersion')),
        /* Level of the version of SQL Server Instance */
        @product_level = CONVERT(varchar, SERVERPROPERTY('ProductLevel')),
        @server_name = CONVERT(varchar, SERVERPROPERTY('ServerName'))

print ' '
print 'COLLATION              : ' + @collation
print 'EDITION                : ' + @edition
print 'INSTANCE NAME          : ' + @instance_name
print 'FAILOVER CLUSTERED     : ' + @failover_clustered
print 'FULL TEXT INSTALLATION : ' + @full_text_installation
print 'SECURITY               : ' + @security
print 'SINGLE USER?           : ' + @single_user
print 'LICENSE TYPE           : ' + @license_type
print 'MACHINE HOSTNAME       : ' + @machine_name
print '# of LICENSES          : ' + @number_of_licenses
print 'PID for sqlservr.exe   : ' + @process_ID
print 'PRODUCT VERSION        : ' + @product_version
print 'PRODUCT LEVEL          : ' + @product_level
print 'SERVER NAME            : ' + @server_name
GO
GRANT EXECUTE ON  [dbo].[usp_DBA_show_instance_info] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_DBA_show_instance_info', NULL, NULL
GO

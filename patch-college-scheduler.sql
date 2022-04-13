--
SET LINESIZE 120
SET PAGESIZE 50000
SET ECHO ON
--
spool patch-college-scheduler.log
--
-- FILE NAME..: patch-college-scheduler.sql
-- OBJECT NAME: csched
-- PRODUCT....: College Scheduler
-- USAGE......: The College Scheduler Package provides a sign-on interface to
--              the College Scheduler host and a data service that fulfills
--              requests for Banner data.
--
-- *****  Civitas Learning Support Helpdesk:  support@civitaslearning.com  *****
--
-- DESCRIPTION:
--
-- College Scheduler by Civitas Learning offers a web based class scheduling
-- system for student use at colleges and universities. Students can build
-- optimized class schedules that take into account their personal needs (work,
-- athletics, leisure, etc.)
-- https://www.civitaslearning.com/
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--
-- CSCHED was created for College Scheduler by
-- Daniel L. DeBower, Senior Software Engineer + Banner Specialist
-- College Scheduler by Civitas Learning, Inc.
-- 1501 South MoPac Expressway, Suite 100, Austin, TX  78746
-- dan.debower@civitaslearning.com
-- https://www.linkedin.com/in/daniel-debower-bb885121
--
-- Customer agrees that it shall not, without the express written consent of
-- Civitas Learning, decompile, disassemble, or reverse engineer the enclosed
-- Software, or modify, enhance, or otherwise change or supplement enclosed
-- Software, in whole or in part.  Customer agrees that it shall not sublicense
-- the enclosed Software or any alterations thereto, derivative works thereof,
-- or related materials provided by Civitas Learning to Customer hereunder.
-- Customer agrees that it shall not install, use, reproduce, market, promote,
-- sell, display, or otherwise provide the enclosed Software or any alterations
-- thereto, derivative works thereof, or related materials provided by Civitas
-- Learning to Customer hereunder to any third party for any other purpose than
-- is permitted by this License.
--
-- v8.0.3.1                October 21, 2015          DLD  Initial Release
-- v8.0.3.2                January 05, 2017          DLD  Revisions
-- v8.0.4                    April 07, 2017          DLD  Revisions
-- v8.0.4.1d               October 06, 2017          DLD  Revisions
-- v8.0.4.1i               October 21, 2021          DLD  Revisions
--
WHENEVER SQLERROR CONTINUE
--
SET ECHO OFF
--
prompt
prompt *************************************************************************************
prompt ** Patch Table CSCHED_SETTINGS                        07-csched_settings-patch.sql **
prompt *************************************************************************************
prompt
@07-csched_settings-patch.sql
prompt
prompt *************************************************************************************
prompt ** Patch Table CSCHED_USER_LOGIN                    13-csched_user_login-patch.sql **
prompt *************************************************************************************
prompt
@13-csched_user_login-patch.sql
prompt
prompt *************************************************************************************
prompt ** Recreate Package Spec CSCHED                                 18-csched-spec.sql **
prompt *************************************************************************************
prompt
@18-csched-spec.sql
prompt
show errors
prompt
prompt *************************************************************************************
prompt ** Recreate Package Body CSCHED                                 19-csched-body.sql **
prompt *************************************************************************************
prompt
@19-csched-body.sql
prompt
show errors
prompt
prompt *************************************************************************************
prompt ** WebTailor Inserts                                 23-csched-webtailor-patch.sql **
prompt *************************************************************************************
prompt
@23-csched-webtailor-patch.sql
prompt
prompt *************************************************************************************
prompt ** All CSCHED Objects                                                              **
prompt *************************************************************************************
--
column OWNER                format A30
column OBJECT_NAME          format A30
column OBJECT_TYPE          format A23
column STATUS               format A7
column NLS_LENGTH_SEMANTICS format A20
--
select a.owner, a.object_name, a.object_type, a.status, b.nls_length_semantics
  from all_plsql_object_settings b, all_objects a
 where b.owner(+)    =  a.owner
   and b.name(+)     =  a.object_name
   and b.type(+)     =  a.object_type
   and a.object_name like '%CSCHED%'
 order by a.owner, a.object_type, a.object_name;
--
prompt *************************************************************************************
prompt ** NOTE:  All objects must be owned by CSCHED or PUBLIC (synonyms).                **
prompt **        All PL/SQL objects must be compiled with the CHAR semantic (NOT BYTE).   **
prompt *************************************************************************************
spool off
--
SET ECHO ON
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--

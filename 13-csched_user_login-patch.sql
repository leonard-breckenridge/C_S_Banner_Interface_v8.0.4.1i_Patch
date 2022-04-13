--
alter session set nls_length_semantics = char;
--
-- FILE NAME..: 13-csched_user_login-patch.sql
-- OBJECT NAME: csched_user_login
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
-- v8.0.3                  October 19, 2015          DLD  Initial Release
-- v8.0.4.1d               October 06, 2017          DLD  Revisions
--   Added ADVISORID.
--   Added TRANSACTIONTYPE.
-- v8.0.4.1i               October 21, 2021          DLD  Revisions
--   Added alter session set nls_length_semantics = char.
--
alter table csched_user_login
   add (advisorid  varchar2(255));
--
comment on column csched_user_login.advisorid  is
   'AdvisorId';
--
alter table csched_user_login
   add (transactiontype  varchar2(255));
--
comment on column csched_user_login.transactiontype  is
   'TransactionType';
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--

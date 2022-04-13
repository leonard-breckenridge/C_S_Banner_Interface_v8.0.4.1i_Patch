--
-- FILE NAME..: 00-csched-schema-grants-patch
-- OBJECT NAME: CSCHED schema
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
-- v8.0.3.1                October 21, 2015          DLD  Revisions
--   Added tables SPRHOLD and STVHLDD supporting Hold Details.
-- v8.0.3.2                January 05, 2017          DLD  Revisions
--   Added tables SCRGMOD and STVGMOD supporting Course Grade Modes.
--   Added F_FORMAT_NAME supporting the Instructor Name Format.
-- v8.0.4                    April 07, 2017          DLD  Revisions
--   Added packages BWKLOSTM and BWLKOIDS supporting Advisor Mode.
-- v8.0.4.1e               October 30, 2017          DLD  Revisions
--   Added ten Course Restriction tables.
--   Added table SORWDSP, the SSB Web Indicator table.
-- v8.0.4.1h               October 25, 2018          DLD  Revisions
--   Added table SSBOVRR, the Section Override table.
-- v8.0.4.1i               October 21, 2021          DLD  Revisions
--   Added CREATE SESSION system privilege.
--   Added ALTER SESSION system privilege.
--
grant CREATE SESSION to CSCHED;
grant ALTER SESSION to CSCHED;
--
-- v8.0.3.1 
grant SELECT on SATURN.sprhold to CSCHED;
grant SELECT on SATURN.stvhldd to CSCHED;
--
-- v8.0.3.2
grant SELECT on SATURN.scrgmod to CSCHED;
grant SELECT on SATURN.stvgmod to CSCHED;
grant EXECUTE on BANINST1.f_format_name to CSCHED;
--
-- v8.0.4
grant EXECUTE on BANINST1.bwlkoids to CSCHED;
grant EXECUTE on BANINST1.bwlkostm to CSCHED;
--
-- v8.0.4.1e
grant SELECT on SATURN.ssrratt to CSCHED;
grant SELECT on SATURN.ssrrchr to CSCHED;
grant SELECT on SATURN.ssrrcls to CSCHED;
grant SELECT on SATURN.ssrrcmp to CSCHED;
grant SELECT on SATURN.ssrrcol to CSCHED;
grant SELECT on SATURN.ssrrdeg to CSCHED;
grant SELECT on SATURN.ssrrdep to CSCHED;
grant SELECT on SATURN.ssrrlvl to CSCHED;
grant SELECT on SATURN.ssrrmaj to CSCHED;
grant SELECT on SATURN.ssrrprg to CSCHED;
grant SELECT on SATURN.sorwdsp to CSCHED;
--
-- v8.0.4.1h
grant SELECT on SATURN.ssbovrr to CSCHED;
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--

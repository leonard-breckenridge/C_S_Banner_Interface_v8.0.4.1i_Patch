--
alter session set nls_length_semantics = char;
--
-- FILE NAME..: 07-csched_settings-patch.sql
-- OBJECT NAME: csched_settings
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
-- v8.0   (STUDENT v8.5.2)   March 11, 2013          DLD  Initial Release
-- v8.0.1 (STUDENT v8.5.2)    June 07, 2013          DLD  Revisions
--   Extended CSCHED_VALID_IP to 4000 characters to support comma delimited list.
--   Added SOAP_ACTION for validation.
--   Added ID Mode Indicator - ID, PIDM, or Obfuscated ID.
--   Added ID Obfuscation Key - 256bit.
--   Added Negotiated encryption Key - 256bit.
--   Added Add to Worksheet Indicator.
--   Added ACTIVITY_DATE.
-- v8.0.1.2r5                  May 10, 2014          DLD  Revisions
--   Added SIGN_ON_FUNCTION.
-- v8.0.2                    March 17, 2015          DLD  Revisions
--   Added SCHEDULE_FORMAT.
-- v8.0.3                  October 19, 2015          DLD  Revisions
--   Added OVERRIDE_IND.
--   Added CURRICULA_IND.
--   Added STUATTR_IND.
--   Added COHORT_IND.
--   Added SCHEDULE_FUNCTION.
--   Added STATISTICS_OPT_IN.
--   Update SCHEDULE_FORMAT to turn on compression.
--     SCHEDULE_FORMAT = '2'
-- v8.0.3.1                October 21, 2015          DLD  Revisions
--   Added HOLD_DETAIL_IND.
-- v8.0.3.2                January 05, 2017          DLD  Revisions
--   Added INSTRUCTOR_NAME_FORMAT.
--   Added AUTHENTICATION_URL.
--   Update SCHEDULE_FORMAT to enable compression, format '2'.
-- v8.0.4.1f              February 12, 2018          DLD  Revisions
--   Added URL_LOGOUT_GUEST.
--   Added URL_LOGOUT_ADVISOR.
--   Update URL_LOGOUT_GUEST with default Faculty menu.
--   Update URL_LOGOUT_ADVISOR with default Faculty menu.
-- v8.0.4.1i               October 21, 2021          DLD  Revisions
--   Added alter session set nls_length_semantics = char.
--   Marked CSCHED_VALID_IP Obsolete, set to null.
--
-- v8.0.3.1
alter table csched_settings
   add (hold_detail_ind        varchar2(1));
--
alter table csched_settings
   add constraint cc12_csched_hold_detail_ind
   check (hold_detail_ind in ('Y','N'));
--
comment on column csched_settings.hold_detail_ind is 'Hold Detail Indicator - NULL/Y/N';
--
-- v8.0.3.2
alter table csched_settings
   add (instructor_name_format  varchar2(7));
--
alter table csched_settings
   add constraint cc13_csched_instructor_name_fo
   check (instructor_name_format in
      ('LFMI','LF','LFM','FML','FMIL','FL','LF30','FL30','L30','L60','LFIMI30'));
--
comment on column csched_settings.instructor_name_format is
   'Instructor Name Format - NULL/LFMI/LF/LFM/FML/FMIL/FL/LF30/FL30/L30/L60/LFIMI30';
--
alter table csched_settings
   add (authentication_url  varchar2(4000));
--
comment on column csched_settings.authentication_url is
   'Single Sign On Authentication URL Override';
--
update csched_settings
   set schedule_format = '2';
COMMIT;
--
-- v8.0.4.1f
alter table csched_settings
   add (url_logout_guest  varchar2(4000));
--
comment on column csched_settings.url_logout_guest is
   'Forwarding URL, Logged Out of College Scheduler as GUEST';
--
alter table csched_settings
   add (url_logout_advisor  varchar2(4000));
--
comment on column csched_settings.url_logout_advisor is
   'Forwarding URL, Logged Out of College Scheduler as ADVISOR';
--
update csched_settings
   set url_logout_guest = 'twbkwbis.P_GenMenu?name=bmenu.P_FacMainMnu'
 where url_logout_guest is null;
COMMIT;
--
update csched_settings
   set url_logout_advisor = 'twbkwbis.P_GenMenu?name=bmenu.P_FacMainMnu'
 where url_logout_advisor is null;
COMMIT;
--
-- v8.0.4.1i
comment on column csched_settings.csched_valid_ip is
   'Obsolete';
--
update csched_settings
   set csched_valid_ip = null;
COMMIT;
--
alter table csched_settings
   add (student_name_format  varchar2(7));
--
alter table csched_settings
   add constraint cc14_csched_student_name_forma
   check (student_name_format in
      ('LFMI','LF','LFM','FML','FMIL','FL','LF30','FL30','L30','L60','LFIMI30'));
--
comment on column csched_settings.student_name_format is
   'Student Name Format - NULL/LFMI/LF/LFM/FML/FMIL/FL/LF30/FL30/L30/L60/LFIMI30';
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--

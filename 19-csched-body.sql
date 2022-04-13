--
alter session set nls_length_semantics = char;
--
create or replace 
PACKAGE BODY    csched
AS
--
-- FILE NAME..: 19-csched-body.sql
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
-- v8.0   (STUDENT v8.5.2)   March 11, 2013          DLD  Initial Release
-- v8.0.1 (STUDENT v8.5.2)    June 07, 2013          DLD  Revisions
--   Extended CSCHED_SETTINGS.CSCHED_VALID_IP to 4000 characters to support
--     comma delimited list.
--   Added CSCHED_SETTINGS.SOAP_ACTION for validation.
--   Removed BWCKFRMT.F_ANCHOR_FOCUS to avoid Banner defect 1-12HF37K.
--   Added Course Levels to the Schedule job with CSCHED.F_FLAT_LEVELS.
--   Added Registration Begin and End dates to the Schedule job.
--   Added specific error messages if no terms are active in CSCHED_TERMS.
--   Added Special Approval/Permits/Overrides to the SignOnPacket.
--   Added SignOnPacket XML to Verbose Error Mode in CSCHED.P_REDIRECT.
--   Added Special Approval code to the Schedule Job.
--   Replaced BWCKCOMS.P_ADDFROMSEARCH with BWSKFREG.P_ALTPIN1 to fully
--     support Alternate PIN processing.
--   Added ID Obfuscation with CSCHED.F_ENCRYPT_ID and CSCHED.F_DECRYPT_ID.
--   Added Section Attributes to the Schedule job with CSCHED.F_FLAT_SECTION_ATTR.
--   Added Course Attributes to the Schedule job with CSCHED.F_FLAT_COURSE_ATTR.
--   Corrected Proxy assignment in CSCHED.P_REDIRECT.
--   Added SALT to all CSCHED.P_SERVICES responses to improve signature strength.
--   Added CSCHED_SETTINGS.ADD_TO_WORKSHEET_IND to make the Add to Worksheet
--     button optional.
--   Added Save Cart button to the Registration Cart page.
--   Adjusted Registration Cart logic.  The Registration Cart is cleared only
--     by explicitly clicking Clear Cart.
-- v8.0.1.1                   June 07, 2013          DLD  Patch
--   Added two dummy parameters to the BWSKFREG.P_ALTPIN1 procedure to support
--     changes delivered in Student Self Service v8.5.1.
-- v8.0.1.2                   July 26, 2013          DLD  Patch
--   Added URL Encoding to the SignOnPacket StudentID to ensure encoded plus
--     characters "+" are not converted to spaces " " by the Authentication server.
-- v8.0.1.2r4             November 07, 2013          DLD  Revisions
--   Added CLOB processing to the Schedule Job with CSCHED.F_CLEAN_BREAK.
--   Adjusted CSCHED.F_CLEAN to replace with spaces instead of nulls.
--   Added Section Text to the Schedule job with CSCHED.F_FLAT_SECTION_TEXT.
--   Added Section Long Text to the Schedule job.
--   Added Course Text to the Schedule job with CSCHED.F_FLAT_COURSE_TEXT.
--   Added Course Long Text to the Schedule job.
--   Added Instructional Method Code and Description to the Schedule Job.
--   Added Part of Term Begin and End dates to the Schedule Job.
--   Added Meeting Type Code to the Meetings data in the Schedule Job.
-- v8.0.1.2r5                  May 10, 2014          DLD  Revisions
--   Added Session Code and Description to the Schedule Job.
--   Added Building Description to the Schedule Job in CSCHED.F_FLAT_MEETINGS.
--   Removed "Reset" button from the Registration Cart.
--   Added registration status dates to the Registration Cart.
--   Replaced all instances of "Authorization" with "Authentication" for consistency.
--   Removed in-line version comments.
--   Increased curr_release constant to 30 characters.
--   Changed "Clear Cart" button to return the LOGOUT_URL instead of the registration page.
--   Added registration attempt logging via CSCHED_AUDIT.
--   Added Alternate PIN Status to the Sign On Packet with CSCHED.F_GET_APINSTATUS.
--   Added dynamic client data to the Sign On Packet with CSCHED.F_GET_SIGNONFUNCTION.
--   Replaced static College Scheduler link with WebTailor InfoText in CSCHED.P_REDIRECT.
--   Added GUEST mode sign-on, including only  <Version>, <GuestId>, and <Timestamp>.
-- v8.0.1.2r6                  May 23, 2014          DLD  Revisions
--   Added a javascript delay to the direct Scheduler link in CSCHED.P_REDIRECT.
--   Added Section Fees to the Schedule Job with CSCHED.F_FLAT_FEES.
--   Added Prerequisite Method and Prerequisite Flag to the Schedule Job.
-- v8.0.1.2r6a                 September 26, 2014    DLD  Patch
--   Increased type T_REGSTAT_TAB in CSCHED.P_REGS_INTERNAL to 60 characters.
-- v8.0.1.2r6b                 March 06, 2015        DLD  Patch
--   Added CSCHED.F_AUTHFILTER to implment hybrid URL/XML encoding in SQL.
--   Added F_AUTHFILTER Encoding to C_SIGNONPACKET for the StuStatus, Override,
--     ID, Term, and Sign On Function error handler.
-- v8.0.2                      March 17, 2015        DLD  Revisions
--   Added Credit Range to the Schedule Job.
--   Added original Section Credits to the Schedule Job.
--   Replaced all references to character set 'AL32UTF8' with c_charset constant.
--   Replaced all references to SQLERRM with DBMS_UTILITY.FORMAT_ERROR_STACK.
--   Removed unnecessary references to SQLCODE.
--   Replaced UTL_RAW with UTL_I18N in CSCHED.F_COMPRESS_B64.
--   Increased all variable width Schedule columns from 4k to 32k characters.
--   Increased all Schedule related functions from 4k to 32k characters.
--   Refactored and expanded CSCHED.F_COMPRESS_B64 to add compression, add
--     encryption, improve performance, and improve exception handling.
--   Added temporary LOB cleanup to CSCHED.P_JOB_SCHEDULE exception handler.
--   Added NVL to the PartOfTermBeginEnd date selection if Part of Term is null.
--   Added Reset tag to the DeltaRequest p_services transaction.
--     <Reset>False</Reset> disables deletes during DeltaRequest processing.
--   Adjusted CSCHED.F_GET_SCHEDULE to handle a term code with no associated sections.
--   Limited Instructor to one, Primary SIRASGN row in C_SCHEDULE.
--   Added explicit column lists to all Inserts to support VPD implementations.
--   Added support for the optional CSCHED_TERMS_VIEW Dynamic Term View.
-- v8.0.3                  October 19, 2015          DLD  Revisions
--   Added CSCHED.F_SCHEDULE_FILE, a manual Schedule extract for FTP.
--   Adjusted CSCHED.P_SERVICES to accept any number of CRNs for a Registration Cart.
--   Added ACTIVITY_DATE and GROUPID to all CSCHED_REGCART transactions.
--   Adjusted CSCHED.P_SERVICES exception BAD_CRN_COUNT to account for only Zero CRNs.
--   Adjusted CSCHED.P_ADDFROMSEARCH to remove unselected CRNs from the parameter
--     list for BWSKFREG.P_ALTPIN1.
--   Added constants for Yes/No, Valid/Invalid, and Inbound/Outbound.
--   Added package wide error logging capability with CSCHED.P_RECORD_FAULT.
--   Added CSCHED.P_RECORD_FAULT to multiple top-level exception handlers.
--   Moved exclusively Schedule related declarations to the Schedule procedures.
--   Added error "Sign On Function Does Not Exist" to CSCHED.F_GET_SIGNONFUNCTION
--     exception handler.
--   Added Sign On Function name to to CSCHED.F_GET_SIGNONFUNCTION exception handler.
--   Adjusted CSCHED.F_CLEAN_BREAK to remove an unneccessary SUBSTR.
--   Added Instance tag from sys_context('USERENV','DB_NAME') to all XML schemas.
--   Added SelectedTerm tag to the SignOnPacket.
--   Added check for active interface terms to CSCHED.P_REDIRECT_INTERNAL.  If
--     there are no active terms, the NOTERMS InfoText is displayed.
--   Added CSCHED.P_JOB_QUEUE, a multiprocess queue for DBMS_SCHEDULER.
--   Added CSCHED_SERVICES.JOB_TYPE to all Job Output inserts.
--   Added Reports Service to Data Services to accept and save Course Demand data.
--   Refactored CSCHED.P_SERVICES to support multiple Jobs.
--   Removed unnecessary <Key> from <DeltaResponse>.
--   Added <ResCap> tag to the Delta Service to track Reserve Capacity seat changes.
--   Added the ReserveCapacity job with CSCHED.P_JOB_RESCAP and CSCHED.F_GET_RESCAP.
--   Added error "Sign On Function Exists in more than one Schema" to
--     CSCHED.F_GET_SIGNONFUNCTION exception handler.
--   Adjusted CSCHED.F_AUTHFILTER to include CSCHED.F_CLEAN processing.
--   Added explicit return type to CSCHED.F_AUTHFILTER.
--   Added a sort by Term Code in the SignOnPacket Terms tag.
--   Moved the SignOnPacket Timestamp tag from the Terms tag to the root.
--   Added UTL_HTTP.WRITE_TEXT Chunking to CSCHED.P_REDIRECT_INTERNAL with
--     DBMS_LOB to handle SignOnPackets larger than 32KB.
--   Added Curricula to the SignOnPacket with CSCHED.F_GET_CURRICULA controlled
--     by CSCHED_SETTINGS.CURRICULA_IND.
--   Moved Special Approval/Permits/Overrides from the SignOnPacket cursor to
--     CSCHED.F_GET_OVERRIDES controlled by CSCHED_SETTINGS.OVERRIDE_IND.
--   Added Student Attributes to the SignOnPacket with CSCHED.F_GET_STUATTR
--     controlled by CSCHED_SETTINGS.STUATTR_IND.
--   Added Cohorts to the SignOnPacket with CSCHED.F_GET_COHORTS controlled by
--     CSCHED_SETTINGS.COHORT_IND.
--   Added the Catalog job with CSCHED.P_JOB_CATALOG.
--   Adjusted c_ticket_url to perform authenication with SSO.COLLEGESCHEDULER.COM
--     instead of AUTH.COLLEGESCHEDULER.COM.
--   Added CSCHED.F_GET_SCHEDULEFUNCTION to return the text results of the client
--     Schedule Function.
--   Improved handling for the BWSKFLIB.P_SELDEFTERM 'BADTERM' message in
--     CSCHED.P_ADDFROMSEARCH.
--   Added Meeting Type Description, Schedule Type Code, and Schedule Type
--     Description to all Meetings records in CSCHED.F_FLAT_MEETINGS.
--   Added the Statistics job with CSCHED.P_JOB_STATS and CSCHED.F_GET_STATS.
--   Adjusted CSCHED.F_CLEAN_BREAK to process CLOBs and removed from spec.
--   Added CSCHED.F_FLAT_SECTION_LONG_TEXT to extract Section Descriptions.
--   Added CSCHED.F_FLAT_COURSE_LONG_TEXT to extract Course Descriptions.
--   Optimized varchar and clob typing within Schedule and Catalog extracts for
--      all "flat" functions.
--   Added SignOnPacket to Fault Logging as SOAP_BODY.
-- v8.0.3.1                October 21, 2015          DLD  Revisions
--   Added HoldDetails to the SignOnPacket with CSCHED.F_GET_HOLD_DETAILS controlled
--     by CSCHED_SETTINGS.HOLD_DETAILS_IND.
-- v8.0.3.2                January 05, 2017          DLD  Revisions
--   Replaced SSO authentication server with TICKET for AWS in C_TICKET_URL.
--   Renamed ScheduleFunction column to CustomData in CSCHED.P_JOB_SCHEDULE.
--   Reordered error details in all Course Flat Functions for consistency.
--   Added Course Grade Modes to the Schedule Job in
--     CSCHED.F_FLAT_COURSE_GRADE_MODES.
--   Added Section Grade Mode to Schedule extract.
--   Added Section Status Registration Indicator as RegistrationFlag to the
--     Schedule Job and the Section tag of the DeltaResponse.
--   Added Sign On Authentication URL Override with CSCHED_SETTINGS.AUTHENTICATION_URL.
--   Added Hold Web Display Indicator as "Display" to CSCHED.F_GET_HOLD_DETAILS.
--   Added PIDM to function backtrace/detail data in all F_GET exception handlers.
--   Removed SendToStudentCart restriction on zero CRNs, allowing the cart
--     to be cleared by the service.
-- v8.0.4                    April 07, 2017          DLD  Revisions
--   Added CSCHED.P_REDIRECT_ADVISOR to implement College Scheduler Advisor Mode.
--   Replaced individual settings columns with the settings rowtype in the
--     SignOnPacket cursors to simplify parameter passing.
--   Added the Obfuscation tag to the SignOnPacket to identify Obfuscated IDs.
-- v8.0.4.1b                   May 24, 2017          DLD  Revisions
--   Added optional TERM parameter to CSCHED.P_REDIRECT_ADVISOR.
-- v8.0.4.1c                August 16, 2017          DLD  Revisions
--   Adjusted CSCHED.P_REGS to return an error if TERM and OPT are both null.
--   Added the Incremental Course Demand report with CSCHED.P_PARSE_STUDENTDEMANDREPORT.
-- v8.0.4.1d               October 06, 2017          DLD  Revisions
--   Adjusted CSCHED.P_PARSE_STUDENTDEMANDREPORT to include AdvisorId and
--     TransactionType for CSCHED_USER_LOGIN.
-- v8.0.4.1e              December 20, 2017          DLD  Revisions
--   Added the SSB Web Indicator (from the SORWDSP table) to the Section and
--     Course Attributes in CSCHED.F_FLAT_SECTION_ATTR and F_FLAT_COURSE_ATTR.
--   Added Section Restriction Rules to the Schedule Job with
--     CSCHED.F_FLAT_RESTRICTIONS.
--   Removed obsolete exception BAD_CRN_COUNT from CSCHED.P_SERVICES.
--   Removed unnecessary Term parameter from CSCHED.F_GET_REGHOLD.
-- v8.0.4.1f              February 12, 2018          DLD  Revisions
--   Adjusted CSCHED.P_PARSE_STUDENTDEMANDREPORT to support MEP installations
--     by explicitly declaring the collection columns instead of using ROWTYPE.
--   Added "SSB Parameters" constants including CSMODE_IND to identify selected
--     College Scheduler Mode between sessions.
--   Adjusted CSCHED.P_REDIRECT_INTERNAL to simplify selection of Advisee IDs.
--   Adjusted CSCHED.P_REGS to recognize GUEST and ADVISOR Mode Logouts from
--     the CSMODE_IND SSB Parameter and redirect to the appropriate menus.
--   Replaced TICKET authentication server with SSO2 for AWS in C_TICKET_URL.
-- v8.0.4.1g                   May 07, 2018          DLD  Revisions
--   Added optional p_soap_body parameter to CSCHED.P_SERVICES to support
--     ORDS and MOD_OWA deployments of Self-Service Banner.
-- v8.0.4.1h              November 08, 2018          DLD  Revisions
--   Added section overrides for College and Department from the Section Override
--     table, SSBOVRR, to the Schedule job.
-- v8.0.4.1i               October 21, 2021          DLD  Revisions
--   Added alter session set nls_length_semantics = char.
--   Expanded CrossListGroup / _XLST_GROUP in the Schedule job to 15 characters
--      to support Student Admin release 9.3.15.
--   Removed simple IP validation from the data service, CSCHED.P_SERVICES.
--   Adjusted all SSB forms per Banner performance defect:
--      Banner Student Self-Service 8.7.2.6
--      RESOLUTION (CR-000139005): 
--      Add cattributes=>'BYPASS_ESC=Y' to any calls with table 
--      data. bwckgen1, bwckcom1, bwcksch1
--   Adjusted the SignOnPacket to identify Enrolled and Waitlisted sections
--     by the STVRSTS_VOICE_TYPE -- R-Registered - L-Waitlisted.
--   Added optional student name to the SignOnPacket controlled by
--     CSCHED_SETTINGS.STUDENT_NAME_FORMAT.
--   Adjusted CSCHED.F_FLAT_RESTRICTIONS to handle null LFST_CODEs in MAJOR
--     restrictions.
--   Adjusted CSCHED.F_FLAT_LINKS for revised JSON format representing each
--     separate link connector as an array.
--   Adjusted CSCHED.F_GET_STATS to handle null LEVL_CODEs in SGBSTDN records.
--   Added text cleaning to SSBSECT_SEQ_NUMB in CSCHED.F_GET_SCHEDULE.
--
   curr_release               CONSTANT varchar2(30)   := '8.0.4.1i';
--
   c_instance                 CONSTANT varchar2(30)   := sys_context('USERENV',
                                                                     'DB_NAME');
   c_amp                      CONSTANT varchar2(1)    := '&';      -- Ampersand
   c_tab                      CONSTANT varchar2(1)    := chr(9);   -- Tab
   c_lf                       CONSTANT varchar2(1)    := chr(10);  -- Linefeed
   c_cr                       CONSTANT varchar2(1)    := chr(13);  -- Carriage Return
   c_br                       CONSTANT varchar2(6)    := '<br />'; -- XHTML Break
   c_true                     CONSTANT varchar2(5)    := 'TRUE';
   c_false                    CONSTANT varchar2(5)    := 'FALSE';
   c_enabled                  CONSTANT varchar2(8)    := 'ENABLED';
   c_disabled                 CONSTANT varchar2(8)    := 'DISABLED';
   c_yes                      CONSTANT varchar2(1)    := 'Y';
   c_no                       CONSTANT varchar2(1)    := 'N';
   c_valid                    CONSTANT varchar2(7)    := 'VALID';
   c_invalid                  CONSTANT varchar2(7)    := 'INVALID';
   c_inbound                  CONSTANT varchar2(8)    := 'INBOUND';
   c_outbound                 CONSTANT varchar2(8)    := 'OUTBOUND';
   c_eligible_msg             CONSTANT varchar2(30)   := 'Eligible';
   c_not_eligible_msg         CONSTANT varchar2(30)   := 'Not Eligible';
   c_active                   CONSTANT varchar2(8)    := 'A';
   c_inactive                 CONSTANT varchar2(8)    := 'I';
--
   c_charset                  CONSTANT varchar2(30)   := 'AL32UTF8';
   c_time_format              CONSTANT varchar2(25)   := 'YYYY-MM-DD-HH24:MI:SS.FF6';
   c_date_format              CONSTANT varchar2(21)   := 'YYYY-MM-DD-HH24:MI:SS';
-- p_redirect
   c_ticket_url               CONSTANT varchar2(4000) :=
      'sso2.collegescheduler.com/auth.asmx/getTicketAddress';
   c_csched_domain            CONSTANT varchar2(255)  :=
      'collegescheduler.com';
   c_ticket_xmlns             CONSTANT varchar2(255)  := 'xmlns="http://tempuri.org/"';
   c_redirect_seconds         CONSTANT number(2)      := 0;
   c_link_delay_seconds       CONSTANT number(2)      := 5;
-- Encryption
   c_nonce_bytes              CONSTANT number(2)      := 32;  -- 32 * 8 = 256 bits
   c_encryption_type          CONSTANT pls_integer    := dbms_crypto.encrypt_aes256
                                                       + dbms_crypto.chain_cbc
                                                       + dbms_crypto.pad_pkcs5;
-- Sign On Modes
   c_student_mode             CONSTANT varchar2(30)   := 'STUDENT';
   c_guest_mode               CONSTANT varchar2(30)   := 'GUEST';
   c_advisor_mode             CONSTANT varchar2(30)   := 'ADVISOR';
-- SSB Parameters
   c_ssb_csmode_ind           CONSTANT varchar2(10)   := 'CSMODE_IND';
   c_ssb_stufac_ind           CONSTANT varchar2(10)   := 'STUFAC_IND';
   c_ssb_stu_ind              CONSTANT varchar2(30)   := 'STU';  -- STUFAC STU
   c_ssb_fac_ind              CONSTANT varchar2(30)   := 'FAC';  -- STUFAC FAC
   c_ssb_stupidm              CONSTANT varchar2(10)   := 'STUPIDM';
   c_ssb_term                 CONSTANT varchar2(10)   := 'TERM';
-- c_signonpacket builds the XML message delivered as the Username for STUDENT
--   and ADVISOR modes.
   cursor c_signonpacket (p_pidm            number,
                          p_id_delivered    varchar2,
                          p_id_advisor      varchar2,
                          p_SelectedTerm    varchar2,
                          p_settings        csched_settings%rowtype) is
      select xmlelement("SignOnPacket",
                xmlelement("Version",curr_release),
                xmlelement("Instance",c_instance),
                xmlelement("Timestamp",to_char(systimestamp,
                                               c_time_format)),
                nvl2(p_id_advisor,xmlelement("AdvisorId",p_id_advisor),null),
                xmlelement("StudentId",p_id_delivered),
                decode(p_settings.id_mode_ind,'I',null,
                   xmlelement("Obfuscation",'Y')),
                nvl2(p_settings.student_name_format,
                     xmlelement("StudentName",
                                (substr(f_format_name(p_pidm,
                                                      p_settings.student_name_format),
                                        1,60))),
                     null),
                xmlelement("SelectedTerm",p_SelectedTerm),
                (select xmlelement("Terms",
                    xmlagg(xmlelement("Item",
                       xmlelement("TermCode",term_code),
                       xmlelement("Term",f_authfilter((
                                           select stvterm_desc
                                             from stvterm
                                            where stvterm_code = term_code))),
                       xmlelement("StuStatus",f_authfilter(
                                                 f_get_StuStatus(p_pidm,
                                                                 term_code))),
                       xmlelement("RegHold",f_get_RegHold(p_pidm,
                                                          sysdate)),
                       xmlelement("APINStatus",f_get_APINStatus(p_pidm,
                                                                term_code)),
                       xmlelement("TicketStatus",f_get_TicketStatus(p_pidm,
                                                                    term_code)),
                       (select xmlelement("TimeTickets",
                           xmlagg(xmlelement("Ticket",
                              xmlelement("TimeTicketBegin",to_char(sfrwctl_begin_date,
                                                                   'YYYY-MM-DD')||'-'||
                                                                   substr(sfrwctl_hour_begin,1,2)||':'||
                                                                   substr(sfrwctl_hour_begin,3,2)),
                              xmlelement("TimeTicketEnd",to_char(sfrwctl_end_date,
                                                                 'YYYY-MM-DD')||'-'||
                                                                 substr(sfrwctl_hour_end,1,2)||':'||
                                                                 substr(sfrwctl_hour_end,3,2)))))
                          from sfbwctl, sfrwctl, sfbrgrp
                         where sfbrgrp_pidm      =  p_pidm
                           and sfbrgrp_term_code =  term_code
                           and sfbwctl_term_code =  sfbrgrp_term_code
                           and sfbwctl_rgrp_code =  sfbrgrp_rgrp_code
                           and sfrwctl_term_code =  sfbrgrp_term_code
                           and sfrwctl_priority  =  sfbwctl_priority),
                       xmlelement("Registration",
                          (select xmlagg(xmlelement("CRN",
                                     decode(stvrsts_voice_type,'R','E',    -- Registered-Enrolled
                                                               'L','W')||  -- waitListed-Waitlisted
                                     sfrstcr_crn))
                             from stvrsts, sfrstcr
                            where stvrsts_code = sfrstcr_rsts_code
                              and sfrstcr_term_code = term_code
                              and stvrsts_voice_type in ('R','L')
                              and sfrstcr_pidm = p_pidm)),
                       xmlelement("StudentCart",
                          (select xmlagg(xmlelement("CRN",
                                                    crn))
                             from csched_regcart
                            where pidm       = p_pidm
                              and term_code  = a.term_code
                              and active_ind = c_yes)),
                       f_get_overrides(p_pidm,
                                       term_code,
                                       p_settings.override_ind),
                       f_get_Curricula(p_pidm,
                                       term_code,
                                       p_settings.curricula_ind),
                       f_get_stuattr(p_pidm,
                                     term_code,
                                     p_settings.stuattr_ind),
                       f_get_Cohorts(p_pidm,
                                     term_code,
                                     p_settings.cohort_ind))
                       order by term_code))
                   from csched_terms a
                  where active_ind = c_yes),
                f_get_SignOnFunction(p_pidm,
                                     p_settings.sign_on_function),
                f_get_hold_details(p_pidm,
                                   p_settings.hold_detail_ind))
        from dual;
-- c_signonpacket_guest for GUEST mode.
   cursor c_signonpacket_guest (p_pidm            number,
                                p_id_delivered    varchar2,
                                p_settings        csched_settings%rowtype) is
      select xmlelement("SignOnPacket",
                xmlelement("Version",curr_release),
                xmlelement("Instance",c_instance),
                xmlelement("GuestId",p_id_delivered),
                decode(p_settings.id_mode_ind,'I',null,
                   xmlelement("Obfuscation",'Y')),
                xmlelement("Timestamp",to_char(systimestamp,
                                               c_time_format)))
        from dual;
-- p_services
   c_soap_open                CONSTANT varchar2(2000) :=
      '<?xml version="1.0" encoding="utf-8"?>'||
      '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'||
         '<soapenv:Body>';
   c_soap_close               CONSTANT varchar2(2000) :=
         '</soapenv:Body>'||
      '</soapenv:Envelope>';
-- Service Jobs
   type t_job_names           is table of xmltype
                                 index by binary_integer;
   type t_report_payloads     is table of xmltype
                                 index by binary_integer;
   c_job_error_tag            CONSTANT varchar2(30)   := '[JobError]';
   c_schedule_job             CONSTANT varchar2(255)  := 'Schedule';
      -- procedure p_job_schedule, function f_get_schedule, file f_schedule_file
   c_catalog_job              CONSTANT varchar2(255)  := 'Catalog';
      -- procedure p_job_catalog
   c_termvalidation_job       CONSTANT varchar2(255)  := 'TermValidation';
      -- procedure p_job_termvalidation
   c_prerequisites_job        CONSTANT varchar2(255)  := 'Prerequisites';
      -- procedure
   c_rescap_job               CONSTANT varchar2(255)  := 'ReserveCapacity';
      -- procedure p_job_rescap, function f_get_rescap
   c_stats_job                CONSTANT varchar2(255)  := 'Statistics';
      -- procedure p_job_stats, function f_get_stats
   c_logs_job                 CONSTANT varchar2(255)  := 'Logs';
      -- procedure p_job_logs
   c_student_demand_report    CONSTANT varchar2(255)  := 'CollegeSchedulerStudentDemand';
   c_breaks_report            CONSTANT varchar2(255)  := 'CollegeSchedulerBreaks';
   c_course_demand_report     CONSTANT varchar2(255)  := 'CollegeSchedulerCourseDemand';
   c_section_excluded_report  CONSTANT varchar2(255)  := 'CollegeSchedulerSectionDemandExcluded';
   c_section_demand_report    CONSTANT varchar2(255)  := 'CollegeSchedulerSectionDemand';
   c_user_login_report        CONSTANT varchar2(255)  := 'CollegeSchedulerUserLogins';
-- Registration Cart Buttons
   c_reg_button               CONSTANT varchar2(30)   := 'Register';
      -- DO NOT CHANGE THIS CONSTANT, it is referenced by baseline
   c_reg_button_title         CONSTANT varchar2(60)   := 'Register the selected courses now';
   c_worksheet_button         CONSTANT varchar2(30)   := 'Add to WorkSheet';
      -- DO NOT CHANGE THIS CONSTANT, it is referenced by baseline
   c_worksheet_button_title   CONSTANT varchar2(60)   := 'Add to the Registration Worksheet';
   c_save_cart_button         CONSTANT varchar2(30)   := 'Save Cart';
   c_save_cart_button_title   CONSTANT varchar2(60)   := 'Save all courses for registration later';
   c_del_cart_button          CONSTANT varchar2(30)   := 'Clear Cart';
   c_del_cart_button_title    CONSTANT varchar2(60)   := 'Clear all courses from the Registration Cart';
-- INB Global PIDM
   g_pidm                              number(8);
--
   type t_header_row           is record (name   varchar2(4000),
                                          value  varchar2(4000));
   type t_header_tab           is table of t_header_row
                                  index by binary_integer;
--
   type t_terms_tab            is table of csched_terms%rowtype
                                  index by binary_integer;
--
PROCEDURE p_record_fault(p_system             varchar2,  -- ***** AUTONOMOUS TRANSACTION *****
                         p_faultcode          number,
                         p_faultstring        varchar2,
                         p_detail             varchar2,
                         p_receiveddate       timestamp default systimestamp,
                         p_soap_body          clob      default null)
--
-- Records errors and service faults in the CSCHED_FAULT table.
--
   IS
--
      PRAGMA AUTONOMOUS_TRANSACTION;
--
   BEGIN
--
      insert into csched_fault
                (system,
                 received_date,
                 reported_ind,
                 reported_date,
                 faultcode,
                 faultstring,
                 detail,
                 soap_body)
         values (upper(p_system),
                 p_receiveddate,
                 c_no,
                 null,
                 p_faultcode,
                 p_faultstring,
                 p_detail,
                 p_soap_body);
      COMMIT;
--
--   EXCEPTION
--
--
   END p_record_fault;
--
FUNCTION f_authfilter(p_text  varchar2)
   RETURN varchar2
--
-- Returns p_text XML AND URL encoded for transactions through the AUTH server.
-- ***** DESIGNED FOR AUTH TRANSACTIONS ONLY. DO NOT REUSE. *****
--
   IS
--
      v_return  varchar2(32767);
--
   BEGIN
--
      v_return :=  utl_url.escape(
                      dbms_xmlgen.convert(
                         translate(p_text,c_lf||c_cr||c_tab,'   ')),
                      TRUE);
--
      RETURN v_return;
--
--   EXCEPTION
--
--
   END f_authfilter;
--
FUNCTION f_settings
   RETURN csched_settings%rowtype
--
-- Returns current settings from the CSCHED_SETTINGS table.
--
   IS
--
      v_settings  csched_settings%rowtype;
--
   BEGIN
--
      select *
        into v_settings
        from csched_settings;
--
      RETURN v_settings;
--
   EXCEPTION
--
      when NO_DATA_FOUND then
                  RAISE_APPLICATION_ERROR(-20001,
                                          'CSCHED_SETTINGS - NO_DATA_FOUND');
      when TOO_MANY_ROWS then
                  RAISE_APPLICATION_ERROR(-20002,
                                          'CSCHED_SETTINGS - TOO_MANY_ROWS');
--
   END f_settings;
--
FUNCTION f_encrypt_id(p_banner_id           varchar2,
                      p_id_obfuscation_key  raw)
   RETURN varchar2
--
-- Returns Base64 AES 256bit Encrypted / Obfuscated Banner ID.
--
   IS
--
--
   BEGIN
--
      RETURN utl_i18n.raw_to_char(
                utl_encode.base64_encode(
                   dbms_crypto.encrypt(
                      utl_i18n.string_to_raw(p_banner_id,
                                             c_charset),
                      c_encryption_type,
                      p_id_obfuscation_key)),
                c_charset);
--
   EXCEPTION
--
      when OTHERS then
         RAISE_APPLICATION_ERROR(-20015,
                                 'ID Obfuscation Failed');
--
   END f_encrypt_id;
--
FUNCTION f_decrypt_id_private(p_obfuscated_id       varchar2,-- PRIVATE FUNCTION
                              p_id_obfuscation_key  raw)
   RETURN varchar2
--
-- Returns DECRYPTED Base64 AES 256bit Encrypted / Obfuscated Banner ID.
--
   IS
--
--
   BEGIN
--
      RETURN utl_i18n.raw_to_char(
                dbms_crypto.decrypt(
                   utl_encode.base64_decode(
                      utl_i18n.string_to_raw(p_obfuscated_id,
                                             c_charset)),
                   c_encryption_type,
                   p_id_obfuscation_key),
                c_charset);
--
   EXCEPTION
--
      when OTHERS then
         RAISE_APPLICATION_ERROR(-20016,
                                 'ID DE-Obfuscation Failed');
--
   END f_decrypt_id_private;  -- END PRIVATE FUNCTION
--
FUNCTION f_decrypt_id(p_obfuscated_id       varchar2)        -- PUBLIC FUNCTION
   RETURN varchar2
--
-- Returns DECRYPTED Base64 AES 256bit Encrypted / Obfuscated Banner ID.
--
   IS
--
      v_id_obfuscation_key  raw(32);
--
   BEGIN
--
      select id_obfuscation_key
        into v_id_obfuscation_key
        from csched_settings;
--
      RETURN f_decrypt_id_private(p_obfuscated_id,
                                  v_id_obfuscation_key);
--
   EXCEPTION
--
      when NO_DATA_FOUND then
                  RAISE_APPLICATION_ERROR(-20001,
                                          'CSCHED_SETTINGS - NO_DATA_FOUND');
      when TOO_MANY_ROWS then
                  RAISE_APPLICATION_ERROR(-20002,
                                          'CSCHED_SETTINGS - TOO_MANY_ROWS');
      when OTHERS then
         RETURN 'OBFUSCATE';
--
   END f_decrypt_id;                                     -- END PUBLIC FUNCTION
--
FUNCTION f_compress_b64(p_uncompressed    clob,
                        p_format          number  default 1,
                        p_negotiated_key  raw     default null,
                        p_nonce           raw     default null)
   RETURN clob
--
-- f_compress_b64 accepts a CLOB, optionally compresses it with Lempel-Ziv (LZ)
-- "Brutal" compression, optionally encrypts it, encodes Base64, and returns a CLOB.
--
   IS
--
      v_uncompressed    blob            := empty_blob();
      v_compressed      blob            := empty_blob();
      v_encrypted       blob            := empty_blob();
      v_chunked         varchar2(32767);
      v_base64          clob            := empty_clob();
-- BLOB Conversion
      v_dest_offset     integer := 1;
      v_src_offset      integer := 1;
      v_lang_context    integer := 0;
      v_warning         integer;
-- Base64
      c_chunk  CONSTANT number  := 18432; -- 18 * 1024
         -- Chunk size must be divisible by 3 and should be divisible by 48.
         -- 18432 / 3 = 6144  and  18432 / 48 = 384
--
   BEGIN
-- Verify p_format parameter
      if p_format NOT between 1 and 3
      then
         RAISE_APPLICATION_ERROR(-20019,
                                 'Invalid p_format parameter');
      end if;
-- Verify p_negotiated_key parameter
      if  p_format = 3
      and (p_negotiated_key is null
       or  p_nonce is null)
      then
         RAISE_APPLICATION_ERROR(-20020,
                                 'Key and Vector required for encryption');
      end if;
--
      dbms_lob.createtemporary(v_uncompressed,
                               TRUE);
-- Convert CLOB to BLOB
      dbms_lob.converttoblob(v_uncompressed,
                             p_uncompressed,
                             dbms_lob.lobmaxsize,
                             v_dest_offset,          -- OUT result ignored
                             v_src_offset,           -- OUT result ignored
                             dbms_lob.DEFAULT_CSID,
                             v_lang_context,         -- OUT result ignored
                             v_warning);             -- OUT result ignored
--
      dbms_lob.createtemporary(v_encrypted,
                               TRUE);
--
      case nvl(p_format,1)
      when 1    then  -- Base64
         v_encrypted := v_uncompressed;
      when 2    then  -- Base64, Compressed
         v_encrypted := utl_compress.lz_compress(v_uncompressed,
                                                 9);
      when 3    then  -- Base64, Compressed, Encrypted
         dbms_lob.createtemporary(v_compressed,
                                  TRUE);
         v_compressed := utl_compress.lz_compress(v_uncompressed,
                                                  9);
         dbms_crypto.encrypt(v_encrypted,
                             v_compressed,
                             c_encryption_type,
                             p_negotiated_key,
                             p_nonce);
         dbms_lob.freetemporary(v_compressed);
      end case;
--
      dbms_lob.freetemporary(v_uncompressed);
-- Base64 encoding (in chunks)
      dbms_lob.createtemporary(v_base64,
                               TRUE);
--
      for i in 0..(trunc((dbms_lob.getlength(v_encrypted)-1)/c_chunk))
      loop
         v_chunked := utl_i18n.raw_to_char(
                         utl_encode.base64_encode(
                            dbms_lob.substr(v_encrypted,
                                            c_chunk,
                                            i * c_chunk + 1)),
                            c_charset);
         dbms_lob.writeappend(v_base64,
                              length(v_chunked),
                              v_chunked);
--
      end loop;
--
      dbms_lob.freetemporary(v_encrypted);
--
      RETURN v_base64;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_uncompressed) = 1
         then dbms_lob.freetemporary(v_uncompressed);
         end if;
         --
         if dbms_lob.istemporary(v_compressed) = 1
         then dbms_lob.freetemporary(v_compressed);
         end if;
         --
         if dbms_lob.istemporary(v_encrypted) = 1
         then dbms_lob.freetemporary(v_encrypted);
         end if;
         --
         if dbms_lob.istemporary(v_base64) = 1
         then dbms_lob.freetemporary(v_base64);
         end if;
         --
         RAISE_APPLICATION_ERROR(-20000,
                                 'RAISED:'||c_lf||
                                    substr(dbms_utility.format_error_stack||
                                              dbms_utility.format_error_backtrace,
                                           1,3992));
--
   END f_compress_b64;
--
FUNCTION f_decompress_b64(p_base64          clob,
                          p_format          number  default 1,
                          p_negotiated_key  raw     default null,
                          p_nonce           raw     default null)
   RETURN clob
--
-- f_decompress_b64 accepts a CLOB, decodes Base64, optionally decrypts it,
-- optionally decompresses it with Lempel-Ziv (LZ), and returns a CLOB.
--
   IS
--
      v_base64          clob            := empty_clob();
      v_chunked         raw(32767);
      v_encrypted       blob            := empty_blob();
      v_compressed      blob            := empty_blob();
      v_uncompressed    blob            := empty_blob();
      v_text            clob            := empty_clob();
-- CLOB Conversion
      v_dest_offset     integer := 1;
      v_src_offset      integer := 1;
      v_lang_context    integer := 0;
      v_warning         integer;
-- Base64
      c_chunk  CONSTANT number  := 24576;  -- 18432 * 4 / 3
         -- Chunk size must be 4/3rds of the f_compress_b64 chunk, 18432.
--
   BEGIN
-- Verify p_format parameter
      if p_format NOT between 1 and 3
      then
         RAISE_APPLICATION_ERROR(-20021,
                                 'Invalid p_format parameter');
      end if;
-- Verify p_negotiated_key parameter
      if  p_format = 3
      and (p_negotiated_key is null
       or  p_nonce is null)
      then
         RAISE_APPLICATION_ERROR(-20022,
                                 'Key and Vector required for decryption');
      end if;
--
      dbms_lob.createtemporary(v_encrypted,
                               TRUE);
-- Remove Linefeeds and Carriage Returns
      v_base64 := replace(replace(p_base64,c_lf),c_cr);
-- Base64 decoding (in chunks)
      for i in 0..(trunc((dbms_lob.getlength(v_base64)-1)/c_chunk))
      loop
         v_chunked := utl_encode.base64_decode(
                         utl_i18n.string_to_raw(
                            dbms_lob.substr(v_base64,
                                            c_chunk,
                                            i * c_chunk + 1),
                            c_charset));
         dbms_lob.writeappend(v_encrypted,
                              utl_raw.length(v_chunked),
                              v_chunked);
--
      end loop;
--
      dbms_lob.createtemporary(v_uncompressed,
                               TRUE);
--
      case nvl(p_format,1)
      when 1    then  -- Base64
         v_uncompressed := v_encrypted;
      when 2    then  -- Base64, Compressed
         v_uncompressed := utl_compress.lz_uncompress(v_encrypted);
      when 3    then  -- Base64, Compressed, Encrypted
         dbms_lob.createtemporary(v_compressed,
                                  TRUE);
         dbms_crypto.decrypt(v_compressed,
                             v_encrypted,
                             c_encryption_type,
                             p_negotiated_key,
                             p_nonce);
         v_uncompressed := utl_compress.lz_uncompress(v_compressed);
         dbms_lob.freetemporary(v_compressed);
      end case;
--
      dbms_lob.freetemporary(v_encrypted);
--
      dbms_lob.createtemporary(v_text,
                               TRUE);
-- Convert BLOB to CLOB
      dbms_lob.converttoclob(v_text,
                             v_uncompressed,
                             dbms_lob.lobmaxsize,
                             v_dest_offset,          -- OUT result ignored
                             v_src_offset,           -- OUT result ignored
                             dbms_lob.DEFAULT_CSID,
                             v_lang_context,         -- OUT result ignored
                             v_warning);             -- OUT result ignored
--
      dbms_lob.freetemporary(v_uncompressed);
--
      RETURN v_text;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_encrypted) = 1
         then dbms_lob.freetemporary(v_encrypted);
         end if;
         --
         if dbms_lob.istemporary(v_compressed) = 1
         then dbms_lob.freetemporary(v_compressed);
         end if;
         --
         if dbms_lob.istemporary(v_uncompressed) = 1
         then dbms_lob.freetemporary(v_uncompressed);
         end if;
         --
         if dbms_lob.istemporary(v_text) = 1
         then dbms_lob.freetemporary(v_text);
         end if;
         --
         RAISE_APPLICATION_ERROR(-20000,
                                 'RAISED:'||c_lf||
                                    substr(dbms_utility.format_error_stack||
                                              dbms_utility.format_error_backtrace,
                                           1,3992));
--
   END f_decompress_b64;
--
FUNCTION f_get_RegHold(p_pidm           number,
                       p_reg_date       date)
   RETURN varchar2
--
-- Returns c_not_eligible_msg for fatal registration holds,
-- else returns c_eligible_msg.
--
   IS
--
      v_return         varchar2(30) := c_eligible_msg;
--
   BEGIN
--
      if gb_hold.f_hold_exists(p_pidm     => p_pidm,
                               p_reg_hold => c_yes,
                               p_date     => p_reg_date) = c_yes
      then v_return := c_not_eligible_msg;
      end if;
--
      RETURN v_return;
--
--   EXCEPTION
--
--
   END f_get_reghold;
--
FUNCTION f_get_APINStatus(p_pidm          number,
                          p_reg_term      varchar2)
   RETURN varchar2
--
-- Returns c_not_eligible_msg if an Alternate PIN is required,
-- else returns c_eligible_msg.
--
   IS
--
      v_return         varchar2(30) := c_eligible_msg;
      v_sprapin_count  number(1);
--
   BEGIN
--
      select count(*)
        into v_sprapin_count
        from sprapin
       where sprapin_term_code    =  p_reg_term
         and sprapin_pidm         =  p_pidm
         and sprapin_process_name =  'TREG';
--
      if v_sprapin_count <> 0
      then v_return := c_not_eligible_msg;
      end if;
--
      RETURN v_return;
--
--   EXCEPTION
--
--
   END f_get_APINStatus;
--
FUNCTION f_get_StuStatus(p_pidm          number,
                         p_reg_term      varchar2)
   RETURN sormaud.sormaud_msg%TYPE
--
-- Returns student registration eligibility message(s) or c_eligible_msg.
--
   IS
--
      v_msg_inout     sormaud.sormaud_msg%TYPE;
      v_update_inout  sormaud.sormaud_update_cde%TYPE;
      v_readmit_term  varchar2(6);
--
   BEGIN
--
      begin
         select sobterm_readm_req
           into v_readmit_term
           from sobterm
          where sobterm_term_code = p_reg_term;
      exception
         when NO_DATA_FOUND then
            null;
      end;
--
      sfkmreg.p_check_eligibility(p_pidm,
                                  p_reg_term,
                                  v_readmit_term,
                                  v_msg_inout,
                                  v_update_inout);
--
      if v_msg_inout is null
      then v_msg_inout := c_eligible_msg;
      end if;
--
      RETURN v_msg_inout;
--
--   EXCEPTION
--
--
   END f_get_stustatus;
--
FUNCTION f_get_TicketStatus(p_pidm          number,
                            p_reg_term      varchar2)
   RETURN varchar2
--
-- Returns c_eligible_msg if student's registration time ticket is open, else
-- returns c_not_eligible_msg.
--
   IS
--
      v_return         varchar2(30) := c_not_eligible_msg;
--
   BEGIN
--
      if sfkrctl.f_check_reg_appointment(p_pidm,
                                         p_reg_term,
                                         f_checksdaxrule('WEBMANCONT',
                                                         'WEBREG'),
                                         f_checksdaxrule('WEBRESTTKT',
                                                         'WEBREG'),
                                         'W')
      then
         v_return := c_eligible_msg;
      end if;
--
      RETURN v_return;
--
--   EXCEPTION
--
--
   END f_get_TicketStatus;
--
FUNCTION f_get_overrides(p_pidm           number,
                         p_term_code      varchar2,
                         p_override_ind   varchar2)
   RETURN xmltype
--
-- Returns student Special Approvals, Permits, and Overrides for the SignOnPacket.
--
   IS
--
      v_return                 xmltype;
--
      c_system        CONSTANT varchar2(255)  := 'F_GET_OVERRIDES';
      v_sqlcode                number;
      v_sqlerrm                varchar2(4000);
      v_backtrace              varchar2(4000);
--
   BEGIN
--
      if p_override_ind = c_yes
      then
--
         select xmlelement("Overrides",
                   xmlagg(xmlelement("Section",
                                     sfrsrpo_crn||c_tab||
                                     sfrsrpo_subj_code||c_tab||
                                     sfrsrpo_crse_numb||c_tab||
                                     sfrsrpo_seq_numb||c_tab||
                                     f_authfilter(sfrsrpo_rovr_code)||c_tab||
                                     f_authfilter(stvrovr_desc)||c_tab||
                                     sfrrovr_dupl_over||
                                     sfrrovr_link_over||
                                     sfrrovr_corq_over||
                                     sfrrovr_preq_over||
                                     sfrrovr_time_over||
                                     sfrrovr_capc_over||
                                     sfrrovr_levl_over||
                                     sfrrovr_coll_over||
                                     sfrrovr_majr_over||
                                     sfrrovr_clas_over||
                                     sfrrovr_appr_over||
                                     sfrrovr_rept_over||
                                     sfrrovr_rpth_over||
                                     sfrrovr_camp_over||
                                     sfrrovr_degc_over||
                                     sfrrovr_prog_over||
                                     sfrrovr_dept_over||
                                     sfrrovr_atts_over||
                                     sfrrovr_chrt_over||
                                     sfrrovr_mexc_over)))
           into v_return
           from stvrovr, sfrrovr, sfrsrpo
          where sfrrovr_term_code =  sfrsrpo_term_code
            and sfrrovr_rovr_code =  sfrsrpo_rovr_code
            and stvrovr_code      =  sfrsrpo_rovr_code
            and sfrsrpo_term_code =  p_term_code
            and sfrsrpo_pidm      =  p_pidm;
--
      else
--
         select xmlelement("Overrides",
                   xmlattributes('disabled' as "status"))
           into v_return
           from dual;
--
      end if;
--
      RETURN v_return;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode      := sqlcode;
         v_sqlerrm      := substr(f_authfilter(dbms_utility.format_error_stack),
                                  1,4000);
         v_backtrace    := substr('PIDM: '||to_char(p_pidm)||' '||
                                     f_authfilter(dbms_utility.format_error_backtrace),
                                  1,4000);
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         select xmlelement("Overrides",
                   xmlelement("Fault",
                      xmlelement("faultcode",to_char(v_sqlcode)),
                      xmlelement("faultstring",v_sqlerrm),
                      xmlelement("detail",v_backtrace)))
           into v_return
           from dual;
         --
         RETURN v_return;
--
   END f_get_overrides;
--
FUNCTION f_get_Curricula(p_pidm           number,
                         p_term_code      varchar2,
                         p_Curricula_ind  varchar2)
   RETURN xmltype
--
-- Returns student Curricula for the SignOnPacket.
--
   IS
--
      v_return                 xmltype;
--
      c_system        CONSTANT varchar2(255)  := 'F_GET_CURRICULA';
      v_sqlcode                number;
      v_sqlerrm                varchar2(4000);
      v_backtrace              varchar2(4000);
--
   BEGIN
--
      if p_Curricula_ind = c_yes
      then
--
         select xmlelement("Curricula",
                   xmlagg(xmlelement("Curriculum",
                       xmlelement("Priority",to_char(sorlcur_priority_no)),
                       xmlelement("LevelCode",sorlcur_levl_code),
                       xmlelement("Level",(select f_authfilter(stvlevl_desc)
                                             from stvlevl
                                            where stvlevl_code =  sorlcur_levl_code)),
                       xmlelement("ClassCode",sgkclas.f_class_code(sorlcur_pidm,
                                                                   sorlcur_levl_code,
                                                                   p_term_code)),
                       xmlelement("Class",(select f_authfilter(stvclas_desc)
                                              from stvclas
                                             where stvclas_code =
                                                      sgkclas.f_class_code(sorlcur_pidm,
                                                                           sorlcur_levl_code,
                                                                           p_term_code))),
                       xmlelement("CampusCode",sorlcur_camp_code),
                       xmlelement("Campus",(select f_authfilter(stvcamp_desc)
                                              from stvcamp
                                             where stvcamp_code = sorlcur_camp_code)),
                       xmlelement("CollegeCode",sorlcur_coll_code),
                       xmlelement("College",(select f_authfilter(stvcoll_desc)
                                               from stvcoll
                                              where stvcoll_code = sorlcur_coll_code)),
                       xmlelement("DegreeCode",sorlcur_degc_code),
                       xmlelement("Degree",(select f_authfilter(stvdegc_desc)
                                              from stvdegc
                                             where stvdegc_code = sorlcur_degc_code)),
                       xmlelement("ProgramCode",sorlcur_program),
                       xmlelement("Program",(select f_authfilter(smrprle_program_desc)
                                               from smrprle
                                              where smrprle_program = sorlcur_program)),
                       xmlelement("AdmitTermCode",sorlcur_term_code_admit),
                       xmlelement("AdmitTerm",(select f_authfilter(stvterm_desc)
                                                 from stvterm
                                                where stvterm_code = sorlcur_term_code_admit)),
                       xmlelement("MatricTermCode",sorlcur_term_code_matric),
                       xmlelement("MatricTerm",(select f_authfilter(stvterm_desc)
                                                  from stvterm
                                                 where stvterm_code = sorlcur_term_code_matric)),
                       xmlelement("GradTermCode",sorlcur_term_code_grad),
                       xmlelement("GradTerm",(select f_authfilter(stvterm_desc)
                                                from stvterm
                                               where stvterm_code = sorlcur_term_code_grad)),
                       xmlelement("AdmitCode",sorlcur_admt_code),
                       xmlelement("Admit",(select f_authfilter(stvadmt_desc)
                                             from stvadmt
                                            where stvadmt_code = sorlcur_admt_code)),
                       xmlelement("StudentTypeCode",sorlcur_styp_code),
                       xmlelement("StudentType",(select f_authfilter(stvstyp_desc)
                                                   from stvstyp
                                                  where stvstyp_code = sorlcur_styp_code)),
                       (select xmlagg(xmlelement("FieldOfStudy",
                                  xmlelement("MajorCode",sorlfos_majr_code),
                                  xmlelement("Major",(select f_authfilter(stvmajr_desc)
                                                        from stvmajr
                                                       where stvmajr_code = sorlfos_majr_code)),
                                  xmlelement("LFSTypeCode",sorlfos_lfst_code),
                                  xmlelement("LFSType",(select f_authfilter(gtvlfst_desc)
                                                          from gtvlfst
                                                         where gtvlfst_code = sorlfos_lfst_code)),
                                  xmlelement("DepartmentCode",sorlfos_dept_code),
                                  xmlelement("Department",(select f_authfilter(stvdept_desc)
                                                             from stvdept
                                                            where stvdept_code = sorlfos_dept_code)))
                                      order by sorlfos_seqno)
                          from sorlfos
                         where sorlfos_pidm = sorlcur_pidm
                           and sorlfos_csts_code =  'INPROGRESS'
                           and sorlfos_cact_code =  'ACTIVE'
                           and sorlfos_lcur_seqno =  sorlcur_seqno))
                    order by  sorlcur_priority_no))
           into v_return
           from sorlcur b, sgbstdn a
          where sorlcur_pidm          =  sgbstdn_pidm
            and sorlcur_cact_code     =  'ACTIVE'
            and sorlcur_lmod_code     =  'LEARNER'
            and sorlcur_seqno         =  (select max(sorlcur_seqno)
                                            from sorlcur
                                           where sorlcur_term_code     =  b.sorlcur_term_code
                                             and sorlcur_priority_no   =  b.sorlcur_priority_no
                                             and sorlcur_lmod_code     =  b.sorlcur_lmod_code
                                             and sorlcur_pidm          =  sgbstdn_pidm)
            and sorlcur_term_code     =  (select max(sorlcur_term_code)
                                            from sorlcur
                                           where sorlcur_term_code     <= sgbstdn_term_code_eff
                                             and sorlcur_priority_no   =  b.sorlcur_priority_no
                                             and sorlcur_lmod_code     =  b.sorlcur_lmod_code
                                             and sorlcur_pidm          =  sgbstdn_pidm)
            and sgbstdn_term_code_eff =  (select max(sgbstdn_term_code_eff)
                                            from sgbstdn
                                           where sgbstdn_term_code_eff <= p_term_code
                                             and sgbstdn_pidm          =  a.sgbstdn_pidm)
            and sgbstdn_pidm          =  p_pidm;
--
      else
--
         select xmlelement("Curricula",
                   xmlattributes('disabled' as "status"))
           into v_return
           from dual;
--
      end if;
--
      RETURN v_return;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode      := sqlcode;
         v_sqlerrm      := substr(f_authfilter(dbms_utility.format_error_stack),
                                  1,4000);
         v_backtrace    := substr('PIDM: '||to_char(p_pidm)||' '||
                                     f_authfilter(dbms_utility.format_error_backtrace),
                                  1,4000);
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         select xmlelement("Curricula",
                   xmlelement("Fault",
                      xmlelement("faultcode",to_char(v_sqlcode)),
                      xmlelement("faultstring",v_sqlerrm),
                      xmlelement("detail",v_backtrace)))
           into v_return
           from dual;
         --
         RETURN v_return;
--
   END f_get_Curricula;
--
FUNCTION f_get_stuattr(p_pidm           number,
                       p_term_code      varchar2,
                       p_stuattr_ind    varchar2)
   RETURN xmltype
--
-- Returns Student Attributes for the SignOnPacket.
--
   IS
--
      v_return                 xmltype;
--
      c_system        CONSTANT varchar2(255)  := 'F_GET_STUATTR';
      v_sqlcode                number;
      v_sqlerrm                varchar2(4000);
      v_backtrace              varchar2(4000);
--
   BEGIN
--
      if p_stuattr_ind = c_yes
      then
--
         select xmlelement("StudentAttributes",
                   xmlagg(xmlelement("StudentAttribute",
                      xmlelement("AttributeCode",sgrsatt_atts_code),
                      xmlelement("Attribute",(select f_authfilter(stvatts_desc)
                                                from stvatts
                                               where stvatts_code =  sgrsatt_atts_code)))))
           into v_return
           from sgrsatt a
          where sgrsatt_term_code_eff =  (select max(sgrsatt_term_code_eff)
                                            from sgrsatt
                                           where sgrsatt_pidm          =  a.sgrsatt_pidm
                                             and sgrsatt_term_code_eff <= p_term_code)
            and sgrsatt_pidm          =  p_pidm;
--
      else
--
         select xmlelement("StudentAttributes",
                   xmlattributes('disabled' as "status"))
           into v_return
           from dual;
--
      end if;
--
      RETURN v_return;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode      := sqlcode;
         v_sqlerrm      := substr(f_authfilter(dbms_utility.format_error_stack),
                                  1,4000);
         v_backtrace    := substr('PIDM: '||to_char(p_pidm)||' '||
                                     f_authfilter(dbms_utility.format_error_backtrace),
                                  1,4000);
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         select xmlelement("StudentAttributes",
                   xmlelement("Fault",
                      xmlelement("faultcode",to_char(v_sqlcode)),
                      xmlelement("faultstring",v_sqlerrm),
                      xmlelement("detail",v_backtrace)))
           into v_return
           from dual;
         --
         RETURN v_return;
--
   END f_get_stuattr;
--
FUNCTION f_get_Cohorts(p_pidm           number,
                       p_term_code      varchar2,
                       p_cohort_ind     varchar2)
   RETURN xmltype
--
-- Returns Student Cohorts for the SignOnPacket.
--
   IS
--
      v_return                 xmltype;
--
      c_system        CONSTANT varchar2(255)  := 'F_GET_COHORTS';
      v_sqlcode                number;
      v_sqlerrm                varchar2(4000);
      v_backtrace              varchar2(4000);
--
   BEGIN
--
      if p_cohort_ind = c_yes
      then
--
         select xmlelement("StudentCohorts",
                   xmlagg(xmlelement("StudentCohort",
                      xmlelement("CohortCode",sgrchrt_chrt_code),
                      xmlelement("Cohort",(select f_authfilter(stvchrt_desc)
                                             from stvchrt
                                            where stvchrt_code =  sgrchrt_chrt_code)))))
           into v_return
           from sgrchrt a
          where sgrchrt_term_code_eff =  (select max(sgrchrt_term_code_eff)
                                            from sgrchrt
                                           where sgrchrt_pidm          =  a.sgrchrt_pidm
                                             and sgrchrt_term_code_eff <= p_term_code)
            and sgrchrt_pidm          =  p_pidm;
--
      else
--
         select xmlelement("StudentCohorts",
                   xmlattributes('disabled' as "status"))
           into v_return
           from dual;
--
      end if;
--
      RETURN v_return;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode      := sqlcode;
         v_sqlerrm      := substr(f_authfilter(dbms_utility.format_error_stack),
                                  1,4000);
         v_backtrace    := substr('PIDM: '||to_char(p_pidm)||' '||
                                     f_authfilter(dbms_utility.format_error_backtrace),
                                  1,4000);
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         select xmlelement("StudentCohorts",
                   xmlelement("Fault",
                      xmlelement("faultcode",to_char(v_sqlcode)),
                      xmlelement("faultstring",v_sqlerrm),
                      xmlelement("detail",v_backtrace)))
           into v_return
           from dual;
         --
         RETURN v_return;
--
   END f_get_Cohorts;
--
FUNCTION f_get_hold_details(p_pidm              number,
                            p_hold_details_ind  varchar2)
   RETURN xmltype
--
-- Returns Student Hold Details for the SignOnPacket.
--
   IS
--
      v_return                 xmltype;
--
      c_system        CONSTANT varchar2(255)  := 'F_GET_HOLD_DETAILS';
      v_sqlcode                number;
      v_sqlerrm                varchar2(4000);
      v_backtrace              varchar2(4000);
--
   BEGIN
--
      if p_hold_details_ind = c_yes
      then
--
         select xmlelement("HoldDetails",
                   xmlagg(xmlelement("Hold",
                      xmlelement("HoldCode",sprhold_hldd_code),
                      xmlelement("HoldType",f_authfilter(stvhldd_desc)),
                      xmlelement("Flags",nvl(stvhldd_reg_hold_ind,c_no)||
                                         nvl(stvhldd_trans_hold_ind,c_no)||
                                         nvl(stvhldd_grad_hold_ind,c_no)||
                                         nvl(stvhldd_grade_hold_ind,c_no)||
                                         nvl(stvhldd_ar_hold_ind,c_no)||
                                         nvl(stvhldd_env_hold_ind,c_no)||
                                         nvl(stvhldd_application_hold_ind,c_no)||
                                         nvl(stvhldd_compliance_hold_ind,c_no)),
                      xmlelement("Display",stvhldd_disp_web_ind))))
           into v_return
           from stvhldd,
                sprhold
          where stvhldd_code      =  sprhold_hldd_code
            and sprhold_from_date <= sysdate
            and sprhold_to_date   >= sysdate
            and sprhold_pidm      =  p_pidm;
--
      else
--
         select xmlelement("HoldDetails",
                   xmlattributes('disabled' as "status"))
           into v_return
           from dual;
--
      end if;
--
      RETURN v_return;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode      := sqlcode;
         v_sqlerrm      := substr(f_authfilter(dbms_utility.format_error_stack),
                                  1,4000);
         v_backtrace    := substr('PIDM: '||to_char(p_pidm)||' '||
                                     f_authfilter(dbms_utility.format_error_backtrace),
                                  1,4000);
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         select xmlelement("HoldDetails",
                   xmlelement("Fault",
                      xmlelement("faultcode",to_char(v_sqlcode)),
                      xmlelement("faultstring",v_sqlerrm),
                      xmlelement("detail",v_backtrace)))
           into v_return
           from dual;
         --
         RETURN v_return;
--
   END f_get_hold_details;
--
FUNCTION f_get_SignOnFunction(p_pidm            number,
                              p_SignOnFunction  varchar2)
   RETURN xmltype
--
-- Returns XML containing the coded results of the Client Sign On Function.
--
   IS
--
      v_return                 xmltype;
      v_function_status        varchar2(7);
      v_statement              varchar2(4000);
      v_function_output        clob := empty_clob();
      v_function_b64           clob := empty_clob();
--
      c_system        CONSTANT varchar2(255)  := 'F_GET_SIGNONFUNCTION';
      v_sqlcode                number;
      v_sqlerrm                varchar2(4000);
      v_backtrace              varchar2(4000);
--
   BEGIN
--
      if p_SignOnFunction is null
      then
         -- Return an empty tag
         select xmlelement("SignOnFunction")
           into v_return
           from dual;
         --
      else
         -- Validate SignOnFunction
         begin
            select status
              into v_function_status
              from all_objects
             where object_name =  upper(p_SignOnFunction)
               and object_type =  'FUNCTION';
         exception
            when TOO_MANY_ROWS then
               RAISE_APPLICATION_ERROR(-20025,
                                       'Sign On Function "'||
                                          upper(p_SignOnFunction)||
                                          '" Exists in more than one Schema');
            when NO_DATA_FOUND then
               RAISE_APPLICATION_ERROR(-20024,
                                       'Sign On Function "'||
                                          upper(p_SignOnFunction)||
                                          '" Does Not Exist');
         end;
         --
         if v_function_status <> c_valid
         then
            RAISE_APPLICATION_ERROR(-20018,
                                    'Invalid Sign On Function "'||
                                       upper(p_SignOnFunction)||
                                       '"');
         end if;
         -- Fetch SignOnFunction result
         v_statement := 'select '||
                        p_SignOnFunction||
                        '(:1) from dual';
         EXECUTE IMMEDIATE v_statement
            into           v_function_output
            using          p_pidm;
         -- Convert to Base64 and escape
         v_function_b64 := utl_url.escape(f_compress_b64(v_function_output),
                                          TRUE);
         -- Build XML
         select xmlelement("SignOnFunction",
                   xmlelement("Compressed",c_no),
                   xmlelement("Encrypted",c_no),
                   xmlelement("Data",
                      xmlcdata(v_function_b64)))
           into v_return
           from dual;
         --
      end if;
--
      RETURN v_return;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode      := sqlcode;
         v_sqlerrm      := substr(f_authfilter(dbms_utility.format_error_stack),
                                  1,4000);
         v_backtrace    := substr('PIDM: '||to_char(p_pidm)||' '||
                                     f_authfilter(dbms_utility.format_error_backtrace),
                                  1,4000);
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         select xmlelement("SignOnFunction",
                   xmlelement("Fault",
                      xmlelement("faultcode",to_char(v_sqlcode)),
                      xmlelement("faultstring",v_sqlerrm),
                      xmlelement("detail",v_backtrace)))
           into v_return
           from dual;
         --
         RETURN v_return;
--
   END f_get_SignOnFunction;
--
PROCEDURE p_get_message(p_response  IN OUT NOCOPY  utl_http.resp,
                        p_headers   IN OUT NOCOPY  t_header_tab,
                        p_message   IN OUT NOCOPY  clob)
--
-- Extracts HTTP message headers and body
--
   IS
--
      v_message  clob := empty_clob();
--
   BEGIN
-- Read Headers
      for i in 1..utl_http.get_header_count(p_response)
      loop
         utl_http.get_header(p_response,
                             i,
                             p_headers(i).name,
                             p_headers(i).value);
      end loop;
-- Read Body
      begin
         loop
            utl_http.read_text(p_response,
                               v_message);
            p_message := p_message||v_message;
         end loop;
      exception
         when utl_http.end_of_body then
            utl_http.end_response(p_response);
      end;
--
   EXCEPTION
      when OTHERS then
         null;
--
   END p_get_message;
--
PROCEDURE p_redirect_internal(p_mode      varchar2,
                              p_document  varchar2,
                              p_xyz       varchar2 default null,
                              p_term      varchar2 default null)
--
-- Implements sign-on redirection for all modes.  Distinct procedure names are
-- necessary for the individualized assignment of SSB Security Roles.
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_redirect';
--
      v_settings                  csched_settings%rowtype;
      v_active_terms              number;
      v_id                        varchar2(9);
      v_id_delivered              varchar2(255);
      v_selectedterm              varchar2(6);
      v_stupidm                   number(8);
      v_stupidm_char              varchar2(30);
      v_stuid                     varchar2(9);
      v_stuid_delivered           varchar2(255);
      v_signonpacket              xmltype;
      v_ticket_body               clob := empty_clob();
      v_ticket_request            utl_http.req;
      v_ticket_response           utl_http.resp;
      v_ticket_response_headers   t_header_tab;
      v_ticket_response_body      clob := empty_clob();
      v_ticket_response_xml       xmltype;
      v_ticket_string             varchar2(4000);
-- UTL_HTTP.WRITE_TEXT Chunking
      c_chunk            CONSTANT number := 4096; -- 4 * 1024
--
      c_system           CONSTANT varchar2(255)  := 'P_REDIRECT_INTERNAL';
      v_sqlcode                   number;
      v_sqlerrm                   varchar2(4000);
      v_backtrace                 varchar2(4000);
--
   BEGIN
-- Validate the current user
      if NOT twbkwbis.f_validuser(g_pidm)
      then
         RETURN;
      end if;
 -- Set College Scheduler SSB Mode
      twbkwbis.p_setparam(g_pidm, c_ssb_csmode_ind, p_mode);
-- Get Settings
      v_settings := f_settings;
-- Check for available terms
      select count(*)
        into v_active_terms
        from csched_terms
       where active_ind = c_yes;
      if v_active_terms = 0
      then
         bwckfrmt.p_open_doc(p_document);
         htp.br;
         twbkwbis.p_dispinfo(c_document,
                             'NOTERMS');
         htp.br;
         htp.p('<big><a href="'||v_settings.url_logout||'">'||
            v_settings.text_logout||'</a></big><br><br>');
         twbkwbis.p_closedoc(curr_release);
         RETURN;
      end if;
-- Get ID
      begin
         select spriden_id
           into v_id
           from spriden
          where spriden_change_ind is null
            and spriden_pidm = g_pidm;
      exception
         when NO_DATA_FOUND then
            RAISE_APPLICATION_ERROR(-20017,
                                    'Invalid PIDM or Current ID');
      end;
      case v_settings.id_mode_ind
      when 'I' then
         v_id_delivered := v_id;
      when 'P' then
         v_id_delivered := to_char(g_pidm);
      when 'O' then
         v_id_delivered := f_encrypt_id(v_id,
                                        v_settings.id_obfuscation_key);
      end case;
      v_id_delivered := f_authfilter(v_id_delivered);
-- Get <SelectedTerm>
      v_selectedterm := twbkwbis.f_getparam(g_pidm, c_ssb_term);
-- Get <SignOnPacket> for username
      case p_mode
-- STUDENT Mode                                                            *****
      when c_student_mode then
         open  c_signonpacket(g_pidm,
                              v_id_delivered,
                              null,
                              v_selectedterm,
                              v_settings);
         fetch c_signonpacket into v_signonpacket;
         close c_signonpacket;
-- GUEST Mode                                                              *****
      when c_guest_mode then
         open  c_signonpacket_guest(g_pidm,
                                    v_id_delivered,
                                    v_settings);
         fetch c_signonpacket_guest into v_signonpacket;
         close c_signonpacket_guest;
-- ADVISOR Mode                                                            *****
      when c_advisor_mode then
         -- Get Student Pidm
         if p_xyz  is null
         then
            bwlkoids.p_advidsel(
               calling_proc_name  => p_document,
               calling_proc_name2 => p_document);
               RETURN;
         else
            v_stupidm_char :=
               utl_i18n.raw_to_char(
                  utl_encode.base64_decode(
                     utl_i18n.string_to_raw(p_xyz,
                                            c_charset)),
                  c_charset);
            twbkwbis.p_setparam(g_pidm, c_ssb_stupidm, v_stupidm_char);
            v_stupidm := to_number(v_stupidm_char);
         end if;
         -- Get Student ID
         begin
            select spriden_id
              into v_stuid
              from spriden
             where spriden_change_ind is null
               and spriden_pidm = v_stupidm;
         exception
            when NO_DATA_FOUND then
               RAISE_APPLICATION_ERROR(-20034,
                                       'Invalid Advisee PIDM or Current ID');
         end;
         case v_settings.id_mode_ind
         when 'I' then
            v_stuid_delivered := v_stuid;
         when 'P' then
            v_stuid_delivered := to_char(v_stupidm);
         when 'O' then
            v_stuid_delivered := f_encrypt_id(v_stuid,
                                              v_settings.id_obfuscation_key);
         end case;
         v_stuid_delivered := f_authfilter(v_stuid_delivered);
         open  c_signonpacket(v_stupidm,
                              v_stuid_delivered,
                              v_id_delivered,
                              v_selectedterm,
                              v_settings);
         fetch c_signonpacket into v_signonpacket;
         close c_signonpacket;
-- End Modes                                                               *****
      end case;
-- Build v_ticket_body
      dbms_lob.createtemporary(v_ticket_body,
                               TRUE);
      dbms_lob.append(v_ticket_body,
                      'username=');
      dbms_lob.append(v_ticket_body,
                      v_signonpacket.getclobval);
      dbms_lob.append(v_ticket_body,
                      c_amp||
                      'privatekey='||
                      v_settings.csched_key);
-- Set HTTP Proxy, if necessary
      if v_settings.http_proxy is NOT null
      then utl_http.set_proxy(v_settings.http_proxy);
      end if;
-- Process HTTP Request
      if v_settings.secure_ticket_ind = c_yes
      then
-- Set Oracle Wallet
         utl_http.set_wallet(v_settings.wallet_path,v_settings.wallet_pass);
-- Begin Secure Ticket Request
         v_ticket_request := utl_http.begin_request('https://'||
                                                    nvl(v_settings.authentication_url,
                                                        c_ticket_url),
                                                    'POST',
                                                    'HTTP/1.1');
      else
-- Begin Non-Secure Ticket Request
         v_ticket_request := utl_http.begin_request('http://'||
                                                    nvl(v_settings.authentication_url,
                                                        c_ticket_url),
                                                    'POST',
                                                    'HTTP/1.1');
      end if;
-- Set HTTP Headers
-- utl_http automatically provides a HOST header for HTTP/1.1
      utl_http.set_header(v_ticket_request,
                          'Content-Type',
                          'application/x-www-form-urlencoded');
      utl_http.set_header(v_ticket_request,
                          'Content-Length',
                          to_char(length(v_ticket_body)));
-- Set HTTP Body
      for i in 0..(trunc((dbms_lob.getlength(v_ticket_body)-1)/c_chunk))
      loop
         utl_http.write_text(v_ticket_request,
                             dbms_lob.substr(v_ticket_body,
                                             c_chunk,
                                             i * c_chunk + 1));
      end loop;
-- Deliver Request and process Response
      v_ticket_response := utl_http.get_response(v_ticket_request);
-- Get Response Contents
      p_get_message(v_ticket_response,
                    v_ticket_response_headers,
                    v_ticket_response_body);
-- Check response status
      if v_ticket_response.status_code <> 200
      then
         RAISE_APPLICATION_ERROR(-20003,
                                 'Ticket Response Error: '||
                                 v_ticket_response.reason_phrase||
                                 ' (HTTP-'||v_ticket_response.status_code||')');
      end if;
-- Convert to XML
      begin
         v_ticket_response_xml := xmltype(v_ticket_response_body);
      exception
         when OTHERS then
            RAISE_APPLICATION_ERROR(-20004,
                                    'Ticket Response XML could not be parsed');
      end;
-- Extract STRING response
      begin
         v_ticket_string :=
            v_ticket_response_xml.extract('//string/text()',
                                          c_ticket_xmlns).getstringval;
      exception
         when OTHERS then
            RAISE_APPLICATION_ERROR(-20005,
                                    'Ticket Response XML string could not be parsed');
      end;
-- Validate Key
      if lower(v_ticket_string) = 'invalidkey'
      then
         RAISE_APPLICATION_ERROR(-20006,
                                 'Invalid Private Key');
      end if;
-- Validate <string> URL
      if lower(v_ticket_string) not like lower('%'||c_csched_domain||'%')
      then
         RAISE_APPLICATION_ERROR(-20007,
                                 'Ticket Response XML string returned invalid domain');
      end if;
-- Authentication Ticket Diagnostic Mode
      if v_settings.diagnose_ticket_ind = c_yes
      then
         RAISE_APPLICATION_ERROR(-20008,
                                 'Authentication Ticket Diagnostic Mode');
      end if;
--
      dbms_lob.freetemporary(v_ticket_body);
-- Build redirect page
      bwckfrmt.p_open_doc(p_document);
      htp.p('<meta http-equiv="refresh" content="'||c_redirect_seconds||
            ';URL='''||v_ticket_string||'''"><br>');
      twbkwbis.p_dispinfo(c_document,
                          'REDIRECT',
                          value1 => c_redirect_seconds);
      htp.p('<span id="scheduler-planner-text" title="Link will be available in '||
            to_char(c_link_delay_seconds)||' seconds">'||
            twbkwbis.f_dispinfo(c_document,'LINK',msg_type => 'PLAIN')||
            '</span>');
      htp.p('<a id="scheduler-planner-link" style="display: none" href="'||
            v_ticket_string||'">'||
            twbkwbis.f_dispinfo(c_document,'LINK',msg_type => 'PLAIN')||
            '</a><br><br>');
      htp.p('<script type="text/javascript">'||c_lf||
            '   function showLink () {'||c_lf||
            '    setTimeout(function () {'||c_lf||
            '     document.getElementById("scheduler-planner-text").style.display = "none";'||c_lf||
            '     document.getElementById("scheduler-planner-link").style.display = "inline";'||c_lf||
            '    }, '||c_link_delay_seconds * 1000||');}'||c_lf||
            '   if (window.addEventListener) {'||c_lf||
            '    window.addEventListener("load", showLink, false);'||c_lf||
            '     } else if (window.attachEvent) {'||c_lf||
            '     window.attachEvent("onload", showLink);'||c_lf||
            '    }'||c_lf||
            '</script>');
      twbkwbis.p_closedoc(curr_release);
--
   EXCEPTION
--
      when OTHERS then
         --
         v_sqlcode      := sqlcode;
         v_sqlerrm      := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace    := substr(dbms_utility.format_error_backtrace,1,4000);
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace,
                        systimestamp,
                        v_signonpacket.getclobval);
         --
         bwckfrmt.p_open_doc(p_document,
                             header_text_in => 'Error');
         htp.br;
         twbkwbis.p_dispinfo(c_document,
                             'TICKETERROR');
         htp.br;
         htp.sample(v_sqlerrm||'<br>'||
                    v_backtrace||'<br><br>');
         if v_settings.verbose_error_ind   = c_yes
         or v_settings.diagnose_ticket_ind = c_yes
         then
            if  v_ticket_request.url is NOT null
            then
               htp.p('<big>'||v_ticket_request.http_version||' - '||
                     v_ticket_request.method||' - '||
                     v_ticket_request.url||'</big><br><br>');
            end if;
            if v_signonpacket.getclobval is NOT null
            then
               if dbms_lob.getlength(v_signonpacket.getclobval) <= 30720  -- 30KB
               then
                  htp.p('<textarea cols="160" rows="5" title="SignOnPacket" readonly>'||
                           v_signonpacket.getclobval||
                           '</textarea><br><br>');
               else
                  htp.p('<textarea cols="160" rows="5" title="SignOnPacket" readonly>'||
                           'SignOnPacket exceeds 30KB'||
                           '</textarea><br><br>');
               end if;
            end if;
            if v_ticket_response.status_code is NOT null
            then
               htp.p('<big>'||v_ticket_response.http_version||' - '||
                     v_ticket_response.status_code||' - '||
                     v_ticket_response.reason_phrase||'</big><br><br>');
            end if;
            if v_ticket_response_headers.count > 0
            then
               for i in 1..v_ticket_response_headers.count
               loop
                  htp.sample(v_ticket_response_headers(i).name||': '||
                             v_ticket_response_headers(i).value||'<br>');
               end loop;
               htp.sample('<br>');
            end if;
            if v_ticket_response_body is NOT null
            then
               htp.p('<textarea cols="160" rows="5" title="Response" readonly>'||
                        v_ticket_response_body||
                        '</textarea><br><br>');
            end if;
         end if;
         --
         if dbms_lob.istemporary(v_ticket_body) = 1
         then dbms_lob.freetemporary(v_ticket_body);
         end if;
         --
         twbkwbis.p_closedoc(curr_release);
--
   END p_redirect_internal;
--
PROCEDURE p_redirect                                            -- WEB PROCEDURE
--
-- Redirects a Banner SSB link to the College Scheduler Service.
-- 1.  SSB requests a ticket via SSL from the College Scheduler ticket server
--     containing the user id and College Scheduler Private Key.
-- 2.  The Ticket Server replies with an XML encoded URI for the College
--     Scheduler Service.
-- 3.  If the ticket is valid, the browser will be redirected to the
--     College Scheduler Service URI encoded in the reply.
-- 4.  If the ticket is INvalid, an error page will be returned.
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_redirect';
--
   BEGIN
--
      p_redirect_internal(c_student_mode,
                          c_document);
--
--   EXCEPTION
--
--
   END p_redirect;
--
PROCEDURE p_redirect_guest                                      -- WEB PROCEDURE
--
-- Redirects a Banner SSB link to the College Scheduler Service for a GUEST.
-- Guest sign-ons deliver only the <GuestId> without any student related detail.
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_redirect_guest';
--
   BEGIN
--
      p_redirect_internal(c_guest_mode,
                          c_document);
--
--   EXCEPTION
--
--
   END p_redirect_guest;
--
PROCEDURE p_redirect_advisor(xyz   varchar2 default null,
                             term  varchar2 default null)       -- WEB PROCEDURE
--
-- Redirects a Banner SSB link to the College Scheduler Service for an ADVISOR.
-- Advisor sign-ons deliver the <AdvisorId> with any student related detail.
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_redirect_advisor';
--
   BEGIN
--
      p_redirect_internal(c_advisor_mode,
                          c_document,
                          xyz,
                          term);
--
--   EXCEPTION
--
--
   END p_redirect_advisor;
--
FUNCTION f_hash(p_message     clob)
   RETURN varchar2
--
-- Generates an HMAC-MD5 (Hash-based Message Authentication Code - MD5
-- Message-Digest Algorithm) HASH in hexidecimal/Oracle RAW format from the
-- p_message and c_sched_key.
-- <Hash>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</Hash>
--
   IS
--
      v_hash  varchar2(32);
--
   BEGIN
--
      select dbms_crypto.mac(p_message,
                             1,          -- 1=MD5  2=SHA-1
                             utl_i18n.string_to_raw(csched_key,
                                                    c_charset))
        into v_hash
        from csched_settings;
--
      RETURN v_hash;
--
--   EXCEPTION
--
--
   END f_hash;
--
FUNCTION f_clean(p_text  varchar2)
   RETURN varchar2
--
-- f_clean removes embedded Tabs, Linefeeds, and Carriage Returns from p_text.
--
   IS
--
--
   BEGIN
--
      RETURN translate(p_text,c_lf||c_cr||c_tab,'   ');
--
--   EXCEPTION
--
--
   END f_clean;
--
FUNCTION f_clean_break(p_text  clob)
   RETURN clob
--
-- f_clean_break removes embedded Tabs, and replaces Linefeeds and Carriage
-- Returns with an XHTML break:  '<br />'
--
   IS
--
      v_return  clob := empty_clob();
--
   BEGIN
--
      v_return := replace(replace(replace(replace(replace(p_text,c_tab,' '),
                  c_cr||c_lf,c_br),c_lf||c_cr,c_br),c_cr,c_br),c_lf,c_br);
--
      RETURN v_return;
--
--   EXCEPTION
--
--
   END f_clean_break;
--
FUNCTION f_flat_meetings(p_term_code  varchar2,
                         p_crn        varchar2)
   RETURN clob
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_meetings  clob := empty_clob();
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_MEETINGS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_meetings is
         select to_char(ssrmeet_start_date,'MM/DD/YYYY')||'*'||
                to_char(ssrmeet_end_date,'MM/DD/YYYY') ||'*'||
                ssrmeet_sun_day||
                ssrmeet_mon_day||
                ssrmeet_tue_day||
                ssrmeet_wed_day||
                ssrmeet_thu_day||
                ssrmeet_fri_day||
                ssrmeet_sat_day||'*'||
                ssrmeet_begin_time||'*'||
                ssrmeet_end_time||'*'||
                ssrmeet_bldg_code||'*'||
                ssrmeet_room_code||'*'||
                ssrmeet_mtyp_code||'*'||
                (select translate(stvbldg_desc,
                                  c_lf||c_cr||c_tab||'*|','   --')
                   from stvbldg
                  where stvbldg_code = ssrmeet_bldg_code)||'*'||
                (select translate(gtvmtyp_desc,
                                  c_lf||c_cr||c_tab||'*|','   --')
                   from gtvmtyp
                  where gtvmtyp_code = ssrmeet_mtyp_code)||'*'||
                ssrmeet_schd_code||'*'||
                (select translate(stvschd_desc,
                                  c_lf||c_cr||c_tab||'*|','   --')
                   from stvschd
                  where stvschd_code = ssrmeet_schd_code) meeting
           from ssrmeet
          where ssrmeet_term_code = p_term_code
            and ssrmeet_crn       = p_crn
          order by 1;
--
   BEGIN
--
      for meetings_rec in c_meetings
      loop
         if dbms_lob.getlength(v_flat_meetings) > 0
         then
            dbms_lob.append(v_flat_meetings,
                            '|'||meetings_rec.meeting);
         else
            v_flat_meetings := meetings_rec.meeting;
         end if;
      end loop;
--
      RETURN v_flat_meetings;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_meetings;
--
FUNCTION f_flat_coursecoreqs(p_term_code  varchar2,
                             p_subj_code  varchar2,
                             p_crse_numb  varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_coursecoreqs  varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_COURSECOREQS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_coursecoreqs is
         select scrcorq_subj_code_corq||'|'||
                scrcorq_crse_numb_corq coreq
           from scrcorq a
          where scrcorq_subj_code = p_subj_code
            and scrcorq_crse_numb = p_crse_numb
            and scrcorq_eff_term  =
                   (select max(scrcorq_eff_term)
                      from scrcorq
                     where scrcorq_eff_term <= p_term_code
                       and scrcorq_subj_code = a.scrcorq_subj_code
                       and scrcorq_crse_numb = a.scrcorq_crse_numb)
            and scrcorq_subj_code_corq is NOT null
            and scrcorq_crse_numb_corq is NOT null
          order by scrcorq_subj_code,
                   scrcorq_crse_numb,
                   scrcorq_eff_term,
                   scrcorq_subj_code_corq,
                   scrcorq_crse_numb_corq;
--
   BEGIN
--
      for coursecoreqs_rec in c_coursecoreqs
      loop
         if v_flat_coursecoreqs is NOT null
         then v_flat_coursecoreqs := v_flat_coursecoreqs||','||coursecoreqs_rec.coreq;
         else v_flat_coursecoreqs := coursecoreqs_rec.coreq;
         end if;
      end loop;
--
      RETURN v_flat_coursecoreqs;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr( 'TERM: '||p_term_code||
                               ' SUBJ: '||p_subj_code||
                               ' CRSE: '||p_crse_numb||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_coursecoreqs;
--
FUNCTION f_flat_sectioncoreqs(p_term_code  varchar2,
                              p_crn        varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_sectioncoreqs  varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_SECTIONCOREQS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_sectioncoreqs is
         select ssrcorq_crn_corq coreq
           from ssrcorq
          where ssrcorq_term_code = p_term_code
            and ssrcorq_crn       = p_crn
          order by ssrcorq_term_code,
                   ssrcorq_crn,
                   ssrcorq_crn_corq,
                   ssrcorq_group;
--
   BEGIN
--
      for sectioncoreqs_rec in c_sectioncoreqs
      loop
         if v_flat_sectioncoreqs is NOT null
         then v_flat_sectioncoreqs := v_flat_sectioncoreqs||','||sectioncoreqs_rec.coreq;
         else v_flat_sectioncoreqs := sectioncoreqs_rec.coreq;
         end if;
      end loop;
--
      RETURN v_flat_sectioncoreqs;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_sectioncoreqs;
--
FUNCTION f_flat_links(p_term_code   varchar2,
                      p_crn         varchar2,
                      p_subj_code   varchar2,
                      p_crse_numb   varchar2,
                      p_schd_code   varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_links                     varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_LINKS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_links is
         select '['||
                (select listagg(ssbsect_crn,',')
                          within group (order by ssbsect_subj_code,
                                                 ssbsect_crse_numb,
                                                 ssbsect_term_code,
                                                 ssbsect_crn)
                  from stvssts,
                       ssbsect
                 where stvssts_code       =  ssbsect_ssts_code
                   and stvssts_reg_ind    =  c_yes
                   and ssbsect_subj_code  =  p_subj_code
                   and ssbsect_crse_numb  =  p_crse_numb
                   and ssbsect_term_code  =  ssrlink_term_code
                   and ssbsect_link_ident =  ssrlink_link_conn
                   and ssbsect_schd_code  <> p_schd_code)||']' links
           from ssrlink
          where ssrlink_term_code =  p_term_code
            and ssrlink_crn       =  p_crn
          order by ssrlink_term_code,
                   ssrlink_crn,
                   ssrlink_link_conn;
--
   BEGIN
--
      for links_rec in c_links
      loop
         if v_flat_links is NOT null
         then v_flat_links := v_flat_links||','||links_rec.links;
         else v_flat_links := '['||links_rec.links;
         end if;
      end loop;
--
      if v_flat_links is NOT null
      then v_flat_links := v_flat_links||']';
      end if;
--
      RETURN v_flat_links;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_Links;
--
FUNCTION f_flat_crosslists(p_term_code   varchar2,
                           p_xlst_group  varchar2,
                           p_crn         varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_crosslists  varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_CROSSLISTS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_crosslists is
         select ssrxlst_crn
           from ssrxlst
          where ssrxlst_term_code  =  p_term_code
            and ssrxlst_xlst_group =  p_xlst_group
            and ssrxlst_crn        <> p_crn
          order by ssrxlst_term_code,
                   ssrxlst_xlst_group,
                   ssrxlst_crn;
--
   BEGIN
--
      if p_xlst_group is null
      then RETURN null;
      end if;
--
      for crosslists_rec in c_crosslists
      loop
         if v_flat_crosslists is NOT null
         then v_flat_crosslists := v_flat_crosslists||','||crosslists_rec.ssrxlst_crn;
         else v_flat_crosslists := crosslists_rec.ssrxlst_crn;
         end if;
      end loop;
--
      RETURN v_flat_crosslists;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_crosslists;
--
FUNCTION f_flat_levels(p_subj_code  varchar2,
                       p_crse_numb  varchar2,
                       p_term_code  varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_levels  varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_LEVELS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_levels is
         select stvlevl_code,
                translate(stvlevl_desc,
                          c_lf||c_cr||c_tab||',|','   --') levl_desc
           from stvlevl,
                scrlevl a
          where stvlevl_code      =  scrlevl_levl_code
            and scrlevl_subj_code =  p_subj_code
            and scrlevl_crse_numb =  p_crse_numb
            and scrlevl_eff_term  =
                   (select max(scrlevl_eff_term)
                      from scrlevl
                     where scrlevl_eff_term  <= p_term_code
                       and scrlevl_subj_code =  a.scrlevl_subj_code
                       and scrlevl_crse_numb =  a.scrlevl_crse_numb);
--
   BEGIN
--
      for levels_rec in c_levels
      loop
         if v_flat_levels is NOT null
         then v_flat_levels := v_flat_levels||','||
                               levels_rec.stvlevl_code||'|'||
                               levels_rec.levl_desc;
         else v_flat_levels := levels_rec.stvlevl_code||'|'||
                               levels_rec.levl_desc;
         end if;
      end loop;
--
      RETURN v_flat_levels;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr( 'TERM: '||p_term_code||
                               ' SUBJ: '||p_subj_code||
                               ' CRSE: '||p_crse_numb||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_levels;
--
FUNCTION f_flat_section_attr(p_term_code  varchar2,
                             p_crn        varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_section_attr              varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_SECTION_ATTR';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_section_attr is
         select stvattr_code,
                translate(stvattr_desc,
                          c_lf||c_cr||c_tab||',|','   --')            attr_desc,
                nvl((select c_yes
                       from sorwdsp
                      where sorwdsp_table_name =  'STVATTR'
                        and sorwdsp_code       =  ssrattr_attr_code),
                    c_no)                                             web_ind
           from stvattr,
                ssrattr
          where stvattr_code      =  ssrattr_attr_code
            and ssrattr_term_code =  p_term_code
            and ssrattr_crn       =  p_crn;
--
   BEGIN
--
      for attr_rec in c_section_attr
      loop
         if v_flat_section_attr is NOT null
         then v_flat_section_attr := v_flat_section_attr||','||
                                     attr_rec.stvattr_code||'|'||
                                     attr_rec.attr_desc||'|'||
                                     attr_rec.web_ind;
         else v_flat_section_attr := attr_rec.stvattr_code||'|'||
                                     attr_rec.attr_desc||'|'||
                                     attr_rec.web_ind;
         end if;
      end loop;
--
      RETURN v_flat_section_attr;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_section_attr;
--
FUNCTION f_flat_course_attr(p_subj_code  varchar2,
                            p_crse_numb  varchar2,
                            p_term_code  varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_course_attr               varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_COURSE_ATTR';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_course_attr is
         select stvattr_code,
                translate(stvattr_desc,
                          c_lf||c_cr||c_tab||',|','   --')            attr_desc,
                nvl((select c_yes
                       from sorwdsp
                      where sorwdsp_table_name =  'STVATTR'
                        and sorwdsp_code       =  scrattr_attr_code),
                    c_no)                                             web_ind
           from stvattr,
                scrattr a
          where stvattr_code      =  scrattr_attr_code
            and scrattr_subj_code =  p_subj_code
            and scrattr_crse_numb =  p_crse_numb
            and scrattr_eff_term  =
                   (select max(scrattr_eff_term)
                      from scrattr
                     where scrattr_eff_term  <= p_term_code
                       and scrattr_subj_code =  a.scrattr_subj_code
                       and scrattr_crse_numb =  a.scrattr_crse_numb);
--
   BEGIN
--
      for attr_rec in c_course_attr
      loop
         if v_flat_course_attr is NOT null
         then v_flat_course_attr := v_flat_course_attr||','||
                                    attr_rec.stvattr_code||'|'||
                                    attr_rec.attr_desc||'|'||
                                    attr_rec.web_ind;
         else v_flat_course_attr := attr_rec.stvattr_code||'|'||
                                    attr_rec.attr_desc||'|'||
                                    attr_rec.web_ind;
         end if;
      end loop;
--
      RETURN v_flat_course_attr;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr( 'TERM: '||p_term_code||
                               ' SUBJ: '||p_subj_code||
                               ' CRSE: '||p_crse_numb||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_course_attr;
--
FUNCTION f_flat_section_text(p_term_code  varchar2,
                             p_crn        varchar2)
   RETURN clob
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_section_text              clob := empty_clob();
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_SECTION_TEXT';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_flat_section_text is
         select f_clean(ssrtext_text) text
           from ssrtext
          where ssrtext_term_code = p_term_code
            and ssrtext_crn       = p_crn
          order by ssrtext_term_code,
                   ssrtext_crn,
                   ssrtext_seqno;
--
   BEGIN
--
      for text_rec in c_flat_section_text
      loop
         if dbms_lob.getlength(v_flat_section_text) > 0
         then
            dbms_lob.append(v_flat_section_text,c_br||text_rec.text);
         else
            v_flat_section_text := text_rec.text;
         end if;
      end loop;
--
      RETURN v_flat_section_text;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_section_text;
--
FUNCTION f_flat_course_text(p_subj_code  varchar2,
                            p_crse_numb  varchar2,
                            p_term_code  varchar2)
   RETURN clob
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_course_text               clob := empty_clob();
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_COURSE_TEXT';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_course_text is
         select f_clean(scrtext_text) text
           from scrtext a
          where scrtext_subj_code =  p_subj_code
            and scrtext_crse_numb =  p_crse_numb
            and scrtext_eff_term  =
                   (select max(scrtext_eff_term)
                      from scrtext
                     where scrtext_eff_term  <= p_term_code
                       and scrtext_subj_code =  a.scrtext_subj_code
                       and scrtext_crse_numb =  a.scrtext_crse_numb)
            and scrtext_text_code = 'A'
          order by scrtext_subj_code,
                   scrtext_crse_numb,
                   scrtext_eff_term,
                   scrtext_text_code,
                   scrtext_seqno;
--
   BEGIN
--
      for text_rec in c_course_text
      loop
         if dbms_lob.getlength(v_flat_course_text) > 0
         then
            dbms_lob.append(v_flat_course_text,c_br||text_rec.text);
         else
            v_flat_course_text := text_rec.text;
         end if;
      end loop;
--
      RETURN v_flat_course_text;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr( 'TERM: '||p_term_code||
                               ' SUBJ: '||p_subj_code||
                               ' CRSE: '||p_crse_numb||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_course_text;
--
FUNCTION f_flat_fees(p_term_code  varchar2,
                     p_crn        varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_fees                      varchar2(4000);
      v_flat_fee_row                   varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_FEES';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_fees is
         select translate(stvlevl_desc,
                          c_lf||c_cr||c_tab||',|','   --') levl_desc,
                translate(stvftyp_desc,
                          c_lf||c_cr||c_tab||',|','   --') ftyp_desc,
                translate(tbbdetc_desc,
                          c_lf||c_cr||c_tab||',|','   --') detc_desc,
                a.*
           from stvlevl, stvftyp, tbbdetc, ssrfees a
          where stvlevl_code(+)     =  ssrfees_levl_code
            and stvftyp_code        =  ssrfees_ftyp_code
            and tbbdetc_detail_code =  ssrfees_detl_code
            and ssrfees_term_code   =  p_term_code
            and ssrfees_crn         =  p_crn;
--
   BEGIN
--
      for fee_rec in c_fees
      loop
         select fee_rec.detc_desc||'|'||
                to_char(fee_rec.ssrfees_amount)||'|'||
                fee_rec.ftyp_desc||'|'||
                fee_rec.levl_desc||'|'||
                nvl2(coalesce(fee_rec.ssrfees_levl_code_stdn,
                              fee_rec.ssrfees_coll_code,
                              fee_rec.ssrfees_camp_code,
                              fee_rec.ssrfees_program,
                              fee_rec.ssrfees_degc_code,
                              fee_rec.ssrfees_term_code_admit,
                              fee_rec.ssrfees_rate_code_curric,
                              fee_rec.ssrfees_styp_code_curric,
                              fee_rec.ssrfees_lfst_code,
                              fee_rec.ssrfees_majr_code,
                              fee_rec.ssrfees_dept_code,
                              fee_rec.ssrfees_prim_sec_cde,
                              fee_rec.ssrfees_resd_code,
                              fee_rec.ssrfees_clas_code,
                              fee_rec.ssrfees_rate_code,
                              fee_rec.ssrfees_styp_code,
                              fee_rec.ssrfees_atts_code,
                              fee_rec.ssrfees_chrt_code,
                              fee_rec.ssrfees_vtyp_code),'R',null)
          into v_flat_fee_row
          from dual;
         if v_flat_fees is NOT null
         then
            v_flat_fees := v_flat_fees||','||v_flat_fee_row;
         else
            v_flat_fees := v_flat_fee_row;
         end if;
      end loop;
--
      RETURN v_flat_fees;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_fees;
--
FUNCTION f_flat_section_long_text(p_term_code  varchar2,
                                  p_crn        varchar2)
   RETURN clob
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_section_long_text              clob := empty_clob();
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_SECTION_LONG_TEXT';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
   BEGIN
--
      select ssbdesc_text_narrative
        into v_section_long_text
        from ssbdesc
       where ssbdesc_term_code =  p_term_code
         and ssbdesc_crn       =  p_crn;
--
      RETURN f_clean_break(v_section_long_text);
--
   EXCEPTION
--
      when NO_DATA_FOUND then
         RETURN null;
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_section_long_text;
--
FUNCTION f_flat_course_long_text(p_subj_code  varchar2,
                                 p_crse_numb  varchar2,
                                 p_term_code  varchar2)
   RETURN clob
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_course_long_text               clob := empty_clob();
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_COURSE_LONG_TEXT';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
   BEGIN
--
      select scbdesc_text_narrative
        into v_course_long_text
        from scbdesc a
       where scbdesc_subj_code     =  p_subj_code
         and scbdesc_crse_numb     =  p_crse_numb
         and scbdesc_term_code_eff =
             (select max(scbdesc_term_code_eff)
                from scbdesc
               where scbdesc_term_code_eff <= p_term_code
                 and scbdesc_subj_code     =  a.scbdesc_subj_code
                 and scbdesc_crse_numb     =  a.scbdesc_crse_numb);
--
      RETURN f_clean_break(v_course_long_text);
--
   EXCEPTION
--
      when NO_DATA_FOUND then
         RETURN null;
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr( 'TERM: '||p_term_code||
                               ' SUBJ: '||p_subj_code||
                               ' CRSE: '||p_crse_numb||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_course_long_text;
--
FUNCTION f_flat_course_grade_modes(p_subj_code  varchar2,
                                   p_crse_numb  varchar2,
                                   p_term_code  varchar2)
   RETURN varchar2
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_flat_course_grade_modes        varchar2(4000);
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_COURSE_GRADE_MODES';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      cursor c_grade_modes is
         select stvgmod_code,
                translate(stvgmod_desc,
                          c_lf||c_cr||c_tab||',|','   --') gmod_desc
           from stvgmod,
                scrgmod a
          where stvgmod_code      =  scrgmod_gmod_code
            and scrgmod_subj_code =  p_subj_code
            and scrgmod_crse_numb =  p_crse_numb
            and scrgmod_eff_term  =
                   (select max(scrgmod_eff_term)
                      from scrgmod
                     where scrgmod_eff_term  <= p_term_code
                       and scrgmod_subj_code =  a.scrgmod_subj_code
                       and scrgmod_crse_numb =  a.scrgmod_crse_numb)
          order by scrgmod_default_ind;
--
   BEGIN
--
      for grade_modes_rec in c_grade_modes
      loop
         if v_flat_course_grade_modes is NOT null
         then v_flat_course_grade_modes := v_flat_course_grade_modes||','||
                                           grade_modes_rec.stvgmod_code||'|'||
                                           grade_modes_rec.gmod_desc;
         else v_flat_course_grade_modes := grade_modes_rec.stvgmod_code||'|'||
                                           grade_modes_rec.gmod_desc;
         end if;
      end loop;
--
      RETURN v_flat_course_grade_modes;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr( 'TERM: '||p_term_code||
                               ' SUBJ: '||p_subj_code||
                               ' CRSE: '||p_crse_numb||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_course_grade_modes;
--
FUNCTION f_flat_restrictions(p_term_code  varchar2,
                             p_crn        varchar2)
   RETURN clob
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
   IS
--
      v_restrictions                   clob         := empty_clob();
--
      c_attribute             CONSTANT varchar2(30) := 'Attribute';
      c_cohort                CONSTANT varchar2(30) := 'Cohort';
      c_class                 CONSTANT varchar2(30) := 'Class';
      c_campus                CONSTANT varchar2(30) := 'Campus';
      c_college               CONSTANT varchar2(30) := 'College';
      c_degree                CONSTANT varchar2(30) := 'Degree';
      c_department            CONSTANT varchar2(30) := 'Department';
      c_level                 CONSTANT varchar2(30) := 'Level';
      -- No major constant.  Selected from LFST code.
      c_program               CONSTANT varchar2(30) := 'Program';
--
      c_type1_record          CONSTANT number(1)    := 1;  -- Include / Exlcude
      c_type2_record          CONSTANT number(1)    := 2;  -- Restriction Code
      c_fos_default           CONSTANT varchar2(30) := 'Field Of Study';  -- NULL LFST_CODE
--
      type t_restrictions_tab          is table of varchar2(4000);
      v_all_restrictions_tab           t_restrictions_tab := t_restrictions_tab();
--
      c_system                CONSTANT varchar2(255)  := 'F_FLAT_RESTRICTIONS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
   BEGIN
-- SSRRATT - Student Attribute Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_atts_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_attribute||'|'||
                   p_ie_cde||'|'||
                   ssrratt_atts_code||'|'||
                   (select f_clean(translate(stvatts_desc,',|','--'))
                      from stvatts
                     where stvatts_code =  ssrratt_atts_code)
              from ssrratt
             where ssrratt_term_code =  p_term_code
               and ssrratt_crn       =  p_crn
               and ssrratt_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrratt_atts_ie_cde
           into v_ie_cde
           from ssrratt
          where ssrratt_term_code =  p_term_code
            and ssrratt_crn       =  p_crn
            and ssrratt_rec_type  =  c_type1_record;
         --
         open  c_atts_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_atts_restrictions BULK COLLECT into v_restrictions_tab;
         close c_atts_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRCHR - Cohort Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_chrt_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_cohort||'|'||
                   p_ie_cde||'|'||
                   ssrrchr_chrt_code||'|'||
                   (select f_clean(translate(stvchrt_desc,',|','--'))
                      from stvchrt
                     where stvchrt_code =  ssrrchr_chrt_code)
              from ssrrchr
             where ssrrchr_term_code =  p_term_code
               and ssrrchr_crn       =  p_crn
               and ssrrchr_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrchr_chrt_ie_cde
           into v_ie_cde
           from ssrrchr
          where ssrrchr_term_code =  p_term_code
            and ssrrchr_crn       =  p_crn
            and ssrrchr_rec_type  =  c_type1_record;
         --
         open  c_chrt_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_chrt_restrictions BULK COLLECT into v_restrictions_tab;
         close c_chrt_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRCLS - Class Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_clas_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_class||'|'||
                   p_ie_cde||'|'||
                   ssrrcls_clas_code||'|'||
                   (select f_clean(translate(stvclas_desc,',|','--'))
                      from stvclas
                     where stvclas_code =  ssrrcls_clas_code)
              from ssrrcls
             where ssrrcls_term_code =  p_term_code
               and ssrrcls_crn       =  p_crn
               and ssrrcls_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrcls_class_ind
           into v_ie_cde
           from ssrrcls
          where ssrrcls_term_code =  p_term_code
            and ssrrcls_crn       =  p_crn
            and ssrrcls_rec_type  =  c_type1_record;
         --
         open  c_clas_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_clas_restrictions BULK COLLECT into v_restrictions_tab;
         close c_clas_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRCMP - Campus Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_camp_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_campus||'|'||
                   p_ie_cde||'|'||
                   ssrrcmp_camp_code||'|'||
                   (select f_clean(translate(stvcamp_desc,',|','--'))
                      from stvcamp
                     where stvcamp_code =  ssrrcmp_camp_code)
              from ssrrcmp
             where ssrrcmp_term_code =  p_term_code
               and ssrrcmp_crn       =  p_crn
               and ssrrcmp_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrcmp_camp_ind
           into v_ie_cde
           from ssrrcmp
          where ssrrcmp_term_code =  p_term_code
            and ssrrcmp_crn       =  p_crn
            and ssrrcmp_rec_type  =  c_type1_record;
         --
         open  c_camp_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_camp_restrictions BULK COLLECT into v_restrictions_tab;
         close c_camp_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRCOL - College Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_coll_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_college||'|'||
                   p_ie_cde||'|'||
                   ssrrcol_coll_code||'|'||
                   (select f_clean(translate(stvcoll_desc,',|','--'))
                      from stvcoll
                     where stvcoll_code =  ssrrcol_coll_code)
              from ssrrcol
             where ssrrcol_term_code =  p_term_code
               and ssrrcol_crn       =  p_crn
               and ssrrcol_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrcol_coll_ind
           into v_ie_cde
           from ssrrcol
          where ssrrcol_term_code =  p_term_code
            and ssrrcol_crn       =  p_crn
            and ssrrcol_rec_type  =  c_type1_record;
         --
         open  c_coll_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_coll_restrictions BULK COLLECT into v_restrictions_tab;
         close c_coll_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRDEG - Degree Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_degc_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_degree||'|'||
                   p_ie_cde||'|'||
                   ssrrdeg_degc_code||'|'||
                   (select f_clean(translate(stvdegc_desc,',|','--'))
                      from stvdegc
                     where stvdegc_code =  ssrrdeg_degc_code)
              from ssrrdeg
             where ssrrdeg_term_code =  p_term_code
               and ssrrdeg_crn       =  p_crn
               and ssrrdeg_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrdeg_degc_ind
           into v_ie_cde
           from ssrrdeg
          where ssrrdeg_term_code =  p_term_code
            and ssrrdeg_crn       =  p_crn
            and ssrrdeg_rec_type  =  c_type1_record;
         --
         open  c_degc_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_degc_restrictions BULK COLLECT into v_restrictions_tab;
         close c_degc_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRDEP - Department Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_dept_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_department||'|'||
                   p_ie_cde||'|'||
                   ssrrdep_dept_code||'|'||
                   (select f_clean(translate(stvdept_desc,',|','--'))
                      from stvdept
                     where stvdept_code =  ssrrdep_dept_code)
              from ssrrdep
             where ssrrdep_term_code =  p_term_code
               and ssrrdep_crn       =  p_crn
               and ssrrdep_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrdep_rec_type
           into v_ie_cde
           from ssrrdep
          where ssrrdep_term_code =  p_term_code
            and ssrrdep_crn       =  p_crn
            and ssrrdep_rec_type  =  c_type1_record;
         --
         open  c_dept_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_dept_restrictions BULK COLLECT into v_restrictions_tab;
         close c_dept_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRLVL - Level Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_levl_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_level||'|'||
                   p_ie_cde||'|'||
                   ssrrlvl_levl_code||'|'||
                   (select f_clean(translate(stvlevl_desc,',|','--'))
                      from stvlevl
                     where stvlevl_code =  ssrrlvl_levl_code)
              from ssrrlvl
             where ssrrlvl_term_code =  p_term_code
               and ssrrlvl_crn       =  p_crn
               and ssrrlvl_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrlvl_levl_ind
           into v_ie_cde
           from ssrrlvl
          where ssrrlvl_term_code =  p_term_code
            and ssrrlvl_crn       =  p_crn
            and ssrrlvl_rec_type  =  c_type1_record;
         --
         open  c_levl_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_levl_restrictions BULK COLLECT into v_restrictions_tab;
         close c_levl_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
-- SSRRMAJ - Major Restriction
      declare
         --
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_majr_indicators(p_term_code  varchar2,
                                  p_crn        varchar2) is
            select ssrrmaj_major_ind  ie_cde,
                   ssrrmaj_lfst_code  lfst_code
              from ssrrmaj
             where ssrrmaj_term_code =  p_term_code
               and ssrrmaj_crn       =  p_crn
               and ssrrmaj_rec_type  =  c_type1_record;
         --
         cursor c_majr_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2,
                                    p_lfst_code  varchar2) is
            select initcap(nvl(ssrrmaj_lfst_code,
                               c_fos_default))||'|'||
                   p_ie_cde||'|'||
                   ssrrmaj_majr_code||'|'||
                   (select f_clean(translate(stvmajr_desc,',|','--'))
                      from stvmajr
                     where stvmajr_code =  ssrrmaj_majr_code)
              from ssrrmaj
             where ssrrmaj_term_code =  p_term_code
               and ssrrmaj_crn       =  p_crn
               and ssrrmaj_rec_type  =  c_type2_record
               and     (    ssrrmaj_lfst_code =  p_lfst_code
                    or (    p_lfst_code       is null
                        and ssrrmaj_lfst_code is null));
         --
      begin
         --
         for majr_ind_rec in c_majr_indicators(p_term_code,
                                               p_crn)
         loop
            --
            open  c_majr_restrictions(p_term_code,
                                      p_crn,
                                      majr_ind_rec.ie_cde,
                                      majr_ind_rec.lfst_code);
            fetch c_majr_restrictions BULK COLLECT into v_restrictions_tab;
            close c_majr_restrictions;
            --
            if v_restrictions_tab.count <> 0
            then
               v_all_restrictions_tab := v_all_restrictions_tab
                                         multiset union all
                                         v_restrictions_tab;
            end if;
            --
         end loop;
      end;
-- SSRRPRG - Program Restriction
      declare
         --
         v_ie_cde                         varchar2(1);
         v_restrictions_tab               t_restrictions_tab;
         --
         cursor c_prog_restrictions(p_term_code  varchar2,
                                    p_crn        varchar2,
                                    p_ie_cde     varchar2) is
            select c_program||'|'||
                   p_ie_cde||'|'||
                   ssrrprg_program||'|'||
                   (select f_clean(translate(smrprle_program_desc,',|','--'))
                      from smrprle
                     where smrprle_program =  ssrrprg_program)
              from ssrrprg
             where ssrrprg_term_code =  p_term_code
               and ssrrprg_crn       =  p_crn
               and ssrrprg_rec_type  =  c_type2_record;
         --
      begin
         --
         select ssrrprg_program_ind
           into v_ie_cde
           from ssrrprg
          where ssrrprg_term_code =  p_term_code
            and ssrrprg_crn       =  p_crn
            and ssrrprg_rec_type  =  c_type1_record;
         --
         open  c_prog_restrictions(p_term_code,
                                   p_crn,
                                   v_ie_cde);
         fetch c_prog_restrictions BULK COLLECT into v_restrictions_tab;
         close c_prog_restrictions;
         --
         if v_restrictions_tab.count <> 0
         then
            v_all_restrictions_tab := v_all_restrictions_tab
                                      multiset union all
                                      v_restrictions_tab;
         end if;
         --
      exception
         when NO_DATA_FOUND then
            null;
      end;
--
      if v_all_restrictions_tab.count <> 0
      then
         for i in v_all_restrictions_tab.first..v_all_restrictions_tab.last
         loop
            if dbms_lob.getlength(v_restrictions) > 0
            then
               dbms_lob.append(v_restrictions,','||
                               v_all_restrictions_tab(i));
            else
               v_restrictions := v_all_restrictions_tab(i);
            end if;
         end loop;
      end if;
--
      RETURN v_restrictions;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('TERM: '||p_term_code||
                               ' CRN: '||p_crn||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         RETURN null;
--
   END f_flat_restrictions;
--
PROCEDURE p_job_logs
--
-- p_job_logs generates a fault logging report and saves the output in the
-- CSCHED_SERVICES table.  p_job_logs is executed asynchronously as a
-- dbms_scheduler job by p_job_queue.
--
   IS

      v_settings                       csched_settings%rowtype;
      v_log_row                        varchar2(32767);
      v_logs                           clob := empty_clob();
      v_logs_coded                     clob := empty_clob();
      v_requesteddate                  timestamp;
      v_terms_view_status              varchar2(7);
--
      c_system                CONSTANT varchar2(255)  := 'P_JOB_LOGS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      c_logs_header           CONSTANT varchar2(32767) :=
         '[System]'||c_tab||
         '[LatestDate]'||c_tab||
         '[FaultCode]'||c_tab||
         '[FaultString]'||c_tab||
         '[ExampleDetail]'||c_tab||
         '[Count]'||c_lf;
--
      type t_logs_row         is record (System         varchar2(255),
                                         LatestDate     varchar2(26),
                                         FaultCode      varchar2(6),
                                         FaultString    varchar2(4000),
                                         ExampleDetail  varchar2(4000),
                                         Cnt            varchar2(38)
                                         );
--
      type t_logs_tab         is table of t_logs_row
                                 index by binary_integer;
      v_logs_tab                         t_logs_tab;
--
      cursor c_logs(p_requesteddate  timestamp) is
         select system,
                to_char(max(received_date),
                        c_time_format) ,
                to_char(faultcode),
                f_clean(faultstring),
                f_clean(min(detail)),
                to_char(count(*))
           from csched_fault
          where reported_ind  =  c_no
            and received_date <  p_requesteddate
          group by system,
                   faultcode,
                   faultstring
          order by max(received_date) DESC,
                   system,
                   faultcode,
                   faultstring;
--
   BEGIN
--
      v_RequestedDate := systimestamp;
      v_settings      := f_settings;
--
      dbms_lob.createtemporary(v_logs,
                               TRUE);
      dbms_lob.writeappend(v_logs,
                           length(c_logs_header),
                           to_clob(c_logs_header));
--
      open  c_logs(v_requesteddate);
      fetch c_logs BULK COLLECT into v_logs_tab;
      close c_logs;
--
      if v_logs_tab.count <> 0
      then
         for i in v_logs_tab.first..v_logs_tab.last
         loop
            v_log_row :=
               v_logs_tab(i).System||c_tab||
               v_logs_tab(i).LatestDate||c_tab||
               v_logs_tab(i).FaultCode||c_tab||
               v_logs_tab(i).FaultString||c_tab||
               v_logs_tab(i).ExampleDetail||c_tab||
               v_logs_tab(i).Cnt||c_lf;
            dbms_lob.append(v_logs,v_log_row);
         end loop;
      end if;
--
      dbms_lob.createtemporary(v_logs_coded,
                               TRUE);
--
      dbms_lob.append(v_logs_coded,
                      f_compress_b64(v_logs,
                                     v_settings.schedule_format,
                                     v_settings.negotiated_key));
--
      dbms_lob.freetemporary(v_logs);
--
      insert into csched_services
                (job_type,
                 job_name,
                 requested_date,
                 fulfilled_date,
                 payload)
         values (c_outbound,
                 c_logs_job,
                 v_RequestedDate,
                 systimestamp,
                 v_logs_coded);
--
      dbms_lob.freetemporary(v_logs_coded);
--
      update csched_fault
         set reported_ind  =  c_yes,
             reported_date =  systimestamp
       where reported_ind  =  c_no
         and received_date <  v_requesteddate;
--
      COMMIT;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_logs) = 1
         then dbms_lob.freetemporary(v_logs);
         end if;
--
         if dbms_lob.istemporary(v_logs_coded) = 1
         then dbms_lob.freetemporary(v_logs_coded);
         end if;
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         insert into csched_services
                   (job_type,
                    job_name,
                    requested_date,
                    fulfilled_date,
                    payload)
            values (c_outbound,
                    c_logs_job,
                    v_RequestedDate,
                    systimestamp,
                    to_clob(c_job_error_tag||c_lf||
                            c_logs_job||c_lf||
                            v_sqlerrm||c_lf||
                            v_backtrace));
         COMMIT;
--
  END p_job_logs;
--
FUNCTION f_get_schedulefunction(p_term_code         varchar2,
                                p_crn               varchar2,
                                p_schedulefunction  varchar2)
   RETURN varchar2
--
-- Returns the text results of the client Schedule Function.
--
   IS
--
      v_return                 varchar2(4000);
      v_function_status        varchar2(7);
      v_statement              varchar2(4000);
--
--
   BEGIN
--
      if p_schedulefunction is NOT null
      then
         -- Validate ScheduleFunction
         begin
            select status
              into v_function_status
              from all_objects
             where object_name =  upper(p_schedulefunction)
               and object_type =  'FUNCTION';
         exception
            when TOO_MANY_ROWS then
               RAISE_APPLICATION_ERROR(-20028,
                                       'Schedule Function "'||
                                          upper(p_schedulefunction)||
                                          '" Exists in more than one Schema');
            when NO_DATA_FOUND then
               RAISE_APPLICATION_ERROR(-20029,
                                       'Schedule Function "'||
                                          upper(p_schedulefunction)||
                                          '" Does Not Exist');
         end;
         --
         if v_function_status <> c_valid
         then
            RAISE_APPLICATION_ERROR(-20030,
                                    'Invalid Schedule Function "'||
                                       upper(p_schedulefunction)||
                                       '"');
         end if;
         -- Fetch SignOnFunction result
         v_statement := 'select '||
                        p_schedulefunction||
                        '(:1,:2) from dual';
         EXECUTE IMMEDIATE v_statement
            into           v_return
            using          p_term_code,
                           p_crn;
         --
      end if;
--
      RETURN v_return;
--
--   EXCEPTION
--
--
   END f_get_schedulefunction;
--
FUNCTION f_get_schedule(p_term_code               varchar2,
                        p_schedulefunction        varchar2,
                        p_instructor_name_format  varchar2)
   RETURN clob
--
-- f_get_schedule accepts a Term Code and returns the Schedule report, tab
-- delimited, as a Character Large Object (CLOB).
--
   IS
--
      v_schedule_row              clob := empty_clob();
      v_schedule                  clob := empty_clob();
      v_prev_SubjectCode          varchar2(4);
      v_prev_Course               varchar2(5);
      v_CollegeCode               varchar2(2);
      v_College                   varchar2(30);
      v_DepartmentCode            varchar2(4);
      v_Department                varchar2(30);
      v_course_Credits            number(7,3);
--
      type t_schedule_row         is record (TermCode                varchar2(6),
                                             Term                    varchar2(30),
                                             CRN                     varchar2(5),
                                             Timestamp               varchar2(26),
                                             PartOfTermCode          varchar2(3),
                                             PartOfTerm              varchar2(30),
                                             SubjectCode             varchar2(4),
                                             Subject                 varchar2(30),
                                             Course                  varchar2(5),
                                             Section                 varchar2(3),
                                             SectionStatusCode       varchar2(1),
                                             SectionStatus           varchar2(30),
                                             ScheduleTypeCode        varchar2(3),
                                             ScheduleType            varchar2(30),
                                             CampusCode              varchar2(3),
                                             Campus                  varchar2(30),
                                             SectionTitle            varchar2(30),
                                             SectionPrintIndicator   varchar2(1),
                                             SeatCapacity            number(4,0),
                                             SeatsFilled             number(4,0),
                                             SeatsOpen               number(4,0),
                                             WaitlistCapacity        number(4,0),
                                             WaitlistFilled          number(4,0),
                                             WaitlistOpen            number(4,0),
                                             SectionWebIndicator     varchar2(1),
                                             CollegeCode             varchar2(2),
                                             College                 varchar2(30),
                                             DepartmentCode          varchar2(4),
                                             Department              varchar2(30),
                                             CourseTitle             varchar2(30),
                                             Credits                 number(7,3),
                                             -- Meetings             -- Clob Exclusion
                                             Instructor              varchar2(60),
                                             LongCourseTitle         varchar2(100),
                                             LongSectionTitle        varchar2(100),
                                             CourseCoReqs            varchar2(4000),
                                             SectionCoReqs           varchar2(4000),
                                             Links                   varchar2(4000),
                                             CrossLists              varchar2(4000),
                                             CrossListGroup          varchar2(15),
                                             CrossListCapacity       number(4,0),
                                             CrossListFilled         number(4,0),
                                             CrossListOpen           number(4,0),
                                             Levels                  varchar2(4000),
                                             RegistrationBegin       varchar2(19),
                                             RegistrationEnd         varchar2(19),
                                             ApprovalCode            varchar2(2),
                                             Approval                varchar2(30),
                                             SectionAttributes       varchar2(4000),
                                             CourseAttributes        varchar2(4000),
                                             -- SectionText          -- Clob Exclusion
                                             -- SectionLongText      -- Clob Exclusion
                                             CourseText              clob,
                                             CourseLongText          clob,
                                             InstructionalMethodCode varchar2(5),
                                             InstructionalMethod     varchar2(30),
                                             PartOfTermBeginEnd      varchar2(39),
                                             SessionCode             varchar2(1),
                                             Session                 varchar2(30),
                                             Fees                    varchar2(4000),
                                             PreReqMethod            varchar2(1),
                                             PreReqFlag              varchar2(1),
                                             CreditRange             varchar2(17),
                                             SectionCredits          varchar2(8),
                                             ScheduleFunction        varchar2(4000),
                                             CourseGradeModes        varchar2(4000),
                                             SectionGradeMode        varchar2(4000),
                                             RegistrationFlag        varchar2(1)
                                             );
--
      type t_schedule_tab         is table of t_schedule_row
                                     index by binary_integer;
      v_schedule_tab              t_schedule_tab;
--
      cursor c_schedule(p_term_code               varchar2,
                        p_rsts_code               varchar2,
                        p_schedulefunction        varchar2,
                        p_instructor_name_format  varchar2) is
         select ssbsect_term_code                                              TermCode,
                (select f_clean(stvterm_desc)
                   from stvterm
                  where stvterm_code = ssbsect_term_code)                      Term,
                ssbsect_crn                                                    CRN,
                to_char(systimestamp,
                        c_time_format)                                         Timestamp,
                ssbsect_ptrm_code                                              PartOfTermCode,
                (select f_clean(stvptrm_desc)
                   from stvptrm
                  where stvptrm_code = ssbsect_ptrm_code)                      PartOfTerm,
                ssbsect_subj_code SubjectCode,
                (select f_clean(stvsubj_desc)
                   from stvsubj
                  where stvsubj_code = ssbsect_subj_code)                      Subject,
                ssbsect_crse_numb                                              Course,
                f_clean(ssbsect_seq_numb)                                      Section,
                ssbsect_ssts_code                                              SectionStatusCode,
                (select f_clean(stvssts_desc)
                   from stvssts
                  where stvssts_code = ssbsect_ssts_code)                      SectionStatus,
                ssbsect_schd_code                                              ScheduleTypeCode,
                (select f_clean(stvschd_desc)
                   from stvschd
                  where stvschd_code = ssbsect_schd_code)                      ScheduleType,
                ssbsect_camp_code                                              CampusCode,
                (select f_clean(stvcamp_desc)
                   from stvcamp
                  where stvcamp_code = ssbsect_camp_code)                      Campus,
                f_clean(ssbsect_crse_title)                                    SectionTitle,
                ssbsect_prnt_ind                                               SectionPrintIndicator,
                ssbsect_max_enrl                                               SeatCapacity,
                ssbsect_enrl                                                   SeatsFilled,
                ssbsect_seats_avail                                            SeatsOpen,
                ssbsect_wait_capacity                                          WaitlistCapacity,
                ssbsect_wait_count                                             WaitlistFilled,
                ssbsect_wait_avail                                             WaitlistOpen,
                ssbsect_voice_avail                                            SectionWebIndicator,
                (select ssbovrr_coll_code
                   from ssbovrr
                  where ssbovrr_term_code =  ssbsect_term_code
                    and ssbovrr_crn       =  ssbsect_crn)                      CollegeCode,
                (select f_clean(stvcoll_desc)
                   from stvcoll
                  where stvcoll_code =
                        (select ssbovrr_coll_code
                           from ssbovrr
                          where ssbovrr_term_code =  ssbsect_term_code
                            and ssbovrr_crn       =  ssbsect_crn))             College,
                (select ssbovrr_dept_code
                   from ssbovrr
                  where ssbovrr_term_code =  ssbsect_term_code
                    and ssbovrr_crn       =  ssbsect_crn)                      DepartmentCode,
                (select f_clean(stvdept_desc)
                   from stvdept
                  where stvdept_code =
                        (select ssbovrr_dept_code
                           from ssbovrr
                          where ssbovrr_term_code =  ssbsect_term_code
                            and ssbovrr_crn       =  ssbsect_crn))             Department,
                null                                                           CourseTitle,
                ssbsect_credit_hrs                                             Credits,
                -- Clob Exclusion                                              Meetings,
                nvl((select f_clean(substr(f_format_name(sirasgn_pidm,
                                                         nvl(p_instructor_name_format,
                                                             'LFM')),
                                           1,60))
                       from sirasgn
                      where sirasgn_term_code   = ssbsect_term_code
                        and sirasgn_crn         = ssbsect_crn
                        and sirasgn_primary_ind = c_yes
                        and rownum = 1),'Not Assigned')                        Instructor,
                (select f_clean(scrsyln_long_course_title)
                   from scrsyln a
                  where scrsyln_subj_code  = ssbsect_subj_code
                    and scrsyln_crse_numb  = ssbsect_crse_numb
                    and scrsyln_term_code_eff =
                        (select max(scrsyln_term_code_eff)
                           from scrsyln
                          where scrsyln_term_code_eff <= ssbsect_term_code
                            and scrsyln_subj_code     =  a.scrsyln_subj_code
                            and scrsyln_crse_numb     =  a.scrsyln_crse_numb)) LongCourseTitle,
                (select f_clean(ssrsyln_long_course_title)
                   from ssrsyln
                  where ssrsyln_term_code = ssbsect_term_code
                    and ssrsyln_crn       = ssbsect_crn)                       LongSectionTitle,
                f_flat_CourseCoReqs(ssbsect_term_code,
                                    ssbsect_subj_code,
                                    ssbsect_crse_numb)                         CourseCoReqs,
                f_flat_SectionCoReqs(ssbsect_term_code,
                                     ssbsect_crn)                              SectionCoReqs,
                decode(stvssts_reg_ind,
                       c_yes,f_flat_Links(ssbsect_term_code,
                                          ssbsect_crn,
                                          ssbsect_subj_code,
                                          ssbsect_crse_numb,
                                          ssbsect_schd_code),
                       null)                                                   Links,
                f_flat_CrossLists(ssbsect_term_code,
                                  ssrxlst_xlst_group,
                                  ssbsect_crn)                                 CrossLists,
                ssrxlst_xlst_group                                             CrossListGroup,
                ssbxlst_max_enrl                                               CrossListCapacity,
                ssbxlst_enrl                                                   CrossListFilled,
                ssbxlst_seats_avail                                            CrossListOpen,
                null                                                           Levels,
                to_char(nvl(ssbsect_reg_from_date,
                            sfrrsts_start_date),
                        c_date_format)                                         RegistrationBegin,
                to_char(nvl(ssbsect_reg_to_date,
                            sfrrsts_end_date),
                        c_date_format)                                         RegistrationEnd,
                ssbsect_sapr_code                                              ApprovalCode,
                (select f_clean(stvsapr_desc)
                   from stvsapr
                  where stvsapr_code = ssbsect_sapr_code)                      Approval,
                f_flat_section_attr(ssbsect_term_code,
                                    ssbsect_crn)                               SectionAttributes,
                null                                                           CourseAttributes,
                -- Clob Exclusion                                              SectionText,
                -- Clob Exclusion                                              SectionLongText,
                null                                                           CourseText,
                null                                                           CourseLongText,
                ssbsect_insm_code                                              InstructionalMethodCode,
                (select f_clean(gtvinsm_desc)
                   from gtvinsm
                  where gtvinsm_code = ssbsect_insm_code)                      InstructionalMethod,
                nvl((select to_char(sobptrm_start_date,c_date_format)||c_tab||
                        to_char(sobptrm_end_date,c_date_format)
                   from sobptrm
                  where sobptrm_term_code = ssbsect_term_code
                    and sobptrm_ptrm_code = ssbsect_ptrm_code),c_tab)          PartOfTermBeginEnd,
                ssbsect_sess_code                                              SessionCode,
                (select f_clean(stvsess_desc)
                   from stvsess
                  where stvsess_code = ssbsect_sess_code)                      "Session",
                f_flat_fees(ssbsect_term_code,
                            ssbsect_crn)                                       Fees,
                ssbsect_prereq_chk_method_cde                                  PreReqMethod,
                decode((select count(*)
                         from ssrrtst
                        where ssrrtst_term_code =  ssbsect_term_code
                          and ssrrtst_crn       =  ssbsect_crn),0,c_no,c_yes)  PreReqFlag,
                null                                                           CreditRange,
                ssbsect_credit_hrs                                             SectionCredits,
                f_clean(f_get_schedulefunction(ssbsect_term_code,
                                               ssbsect_crn,
                                               p_schedulefunction))            ScheduleFunction,
                null                                                           CourseGradeModes,
                nvl2(ssbsect_gmod_code,
                     (ssbsect_gmod_code||'|'||
                        (select translate(stvgmod_desc,
                                          c_lf||c_cr||c_tab||',|','   --')
                           from stvgmod
                          where stvgmod_code =  ssbsect_gmod_code)),null)      SectionGradeMode,
                stvssts_reg_ind                                                RegistrationFlag
                -- Clob Exclusion                                              SectionRestrictions
           from sfrrsts,
                ssbxlst,
                ssrxlst,
                stvssts,
                ssbsect
          where sfrrsts_term_code(+)  =  ssbsect_term_code
            and sfrrsts_ptrm_code(+)  =  ssbsect_ptrm_code
            and sfrrsts_rsts_code(+)  =  p_rsts_code
            and ssrxlst_term_code(+)  =  ssbsect_term_code
            and ssrxlst_crn(+)        =  ssbsect_crn
            and ssbxlst_term_code(+)  =  ssrxlst_term_code
            and ssbxlst_xlst_group(+) =  ssrxlst_xlst_group
            and stvssts_code          =  ssbsect_ssts_code
            and ssbsect_term_code     =  p_term_code
          order by ssbsect_subj_code,
                   ssbsect_crse_numb,
                   ssbsect_term_code,
                   ssbsect_crn;
--
      cursor c_schedule_scbcrse(p_subj_code  varchar2,
                                p_crse_numb  varchar2,
                                p_term_code  varchar2) is
         select scbcrse_coll_code                                              CollegeCode,
                (select f_clean(stvcoll_desc)
                   from stvcoll
                  where stvcoll_code = scbcrse_coll_code)                      College,
                scbcrse_dept_code                                              DepartmentCode,
                (select f_clean(stvdept_desc)
                   from stvdept
                  where stvdept_code = scbcrse_dept_code)                      Department,
                f_clean(scbcrse_title)                                         CourseTitle,
                coalesce(scbcrse_credit_hr_high,
                         scbcrse_credit_hr_low)                                Credits,
                f_flat_levels(scbcrse_subj_code,
                              scbcrse_crse_numb,
                              p_term_code)                                     Levels,
                f_flat_course_attr(scbcrse_subj_code,
                                   scbcrse_crse_numb,
                                   p_term_code)                                CourseAttributes,
                f_flat_course_text(scbcrse_subj_code,
                                   scbcrse_crse_numb,
                                   p_term_code)                                CourseText,
                f_flat_course_long_text(scbcrse_subj_code,
                                        scbcrse_crse_numb,
                                        p_term_code)                           CourseLongText,
                to_char(scbcrse_credit_hr_low)||'|'||
                   to_char(scbcrse_credit_hr_high)                             CreditRange,
                f_flat_course_grade_modes(scbcrse_subj_code,
                                          scbcrse_crse_numb,
                                          p_term_code)                         CourseGradeModes
           from scbcrse a
          where scbcrse_subj_code     =  p_subj_code
            and scbcrse_crse_numb     =  p_crse_numb
            and scbcrse_eff_term      =  (select max(scbcrse_eff_term)
                                            from scbcrse
                                            where scbcrse_eff_term <= p_term_code
                                             and scbcrse_subj_code = a.scbcrse_subj_code
                                             and scbcrse_crse_numb = a.scbcrse_crse_numb);
--
   BEGIN
-- Fetch SSBSECT Section Data
      open  c_schedule(p_term_code,
                       f_stu_getwebregsrsts('R'),
                       p_schedulefunction,
                       p_instructor_name_format);
      fetch c_schedule BULK COLLECT into v_schedule_tab;
      close c_schedule;
-- Verify Section Count
      if v_schedule_tab.count <> 0
      then
-- Fetch SCBCRSE Course Data
         v_prev_SubjectCode := '****';
         v_prev_Course      := '*****';
         for i in v_schedule_tab.first..v_schedule_tab.last
         loop
            if v_schedule_tab(i).SubjectCode <> v_prev_SubjectCode
            or v_schedule_tab(i).Course      <> v_prev_Course
            then
               -- Fetch new Subject/Course
               open c_schedule_scbcrse(v_schedule_tab(i).SubjectCode,
                                       v_schedule_tab(i).Course,
                                       p_term_code);
               fetch c_schedule_scbcrse into v_CollegeCode,
                                             v_College,
                                             v_DepartmentCode,
                                             v_Department,
                                             v_schedule_tab(i).CourseTitle,
                                             v_course_Credits,
                                             v_schedule_tab(i).Levels,
                                             v_schedule_tab(i).CourseAttributes,
                                             v_schedule_tab(i).CourseText,
                                             v_schedule_tab(i).CourseLongText,
                                             v_schedule_tab(i).CreditRange,
                                             v_schedule_tab(i).CourseGradeModes;
               close c_schedule_scbcrse;
            else
               -- Copy from previous Subject/Course
               v_schedule_tab(i).CourseTitle      := v_schedule_tab(i-1).CourseTitle;
               v_schedule_tab(i).Levels           := v_schedule_tab(i-1).Levels;
               v_schedule_tab(i).CourseAttributes := v_schedule_tab(i-1).CourseAttributes;
            end if;
            v_schedule_tab(i).CollegeCode      := nvl(v_schedule_tab(i).CollegeCode,
                                                      v_CollegeCode);
            v_schedule_tab(i).College          := nvl(v_schedule_tab(i).College,
                                                      v_College);
            v_schedule_tab(i).DepartmentCode   := nvl(v_schedule_tab(i).DepartmentCode,
                                                      v_DepartmentCode);
            v_schedule_tab(i).Department       := nvl(v_schedule_tab(i).Department,
                                                      v_Department);
            v_schedule_tab(i).Credits          := nvl(v_schedule_tab(i).Credits,
                                                      v_course_Credits);
            -- Set Previous Course
            v_prev_SubjectCode := v_schedule_tab(i).SubjectCode;
            v_prev_Course      := v_schedule_tab(i).Course;
         end loop;
         -- Prepare CLOB
         dbms_lob.createtemporary(v_schedule,
                                  TRUE);
         -- Build CLOB
         for i in v_schedule_tab.first..v_schedule_tab.last
         loop
            v_schedule_row :=
               v_schedule_tab(i).TermCode||c_tab||
               v_schedule_tab(i).Term||c_tab||
               v_schedule_tab(i).CRN||c_tab||
               v_schedule_tab(i).Timestamp||c_tab||
               v_schedule_tab(i).PartOfTermCode||c_tab||
               v_schedule_tab(i).PartOfTerm||c_tab||
               v_schedule_tab(i).SubjectCode||c_tab||
               v_schedule_tab(i).Subject||c_tab||
               v_schedule_tab(i).Course||c_tab||
               v_schedule_tab(i).Section||c_tab||
               v_schedule_tab(i).SectionStatusCode||c_tab||
               v_schedule_tab(i).SectionStatus||c_tab||
               v_schedule_tab(i).ScheduleTypeCode||c_tab||
               v_schedule_tab(i).ScheduleType||c_tab||
               v_schedule_tab(i).CampusCode||c_tab||
               v_schedule_tab(i).Campus||c_tab||
               v_schedule_tab(i).SectionTitle||c_tab||
               v_schedule_tab(i).SectionPrintIndicator||c_tab||
               to_char(v_schedule_tab(i).SeatCapacity)||c_tab||
               to_char(v_schedule_tab(i).SeatsFilled)||c_tab||
               to_char(v_schedule_tab(i).SeatsOpen)||c_tab||
               to_char(v_schedule_tab(i).WaitlistCapacity)||c_tab||
               to_char(v_schedule_tab(i).WaitlistFilled)||c_tab||
               to_char(v_schedule_tab(i).WaitlistOpen)||c_tab||
               v_schedule_tab(i).SectionWebIndicator||c_tab||
               v_schedule_tab(i).CollegeCode||c_tab||
               v_schedule_tab(i).College||c_tab||
               v_schedule_tab(i).DepartmentCode||c_tab||
               v_schedule_tab(i).Department||c_tab||
               v_schedule_tab(i).CourseTitle||c_tab||
               to_char(v_schedule_tab(i).Credits)||c_tab||
               f_flat_meetings(v_schedule_tab(i).TermCode,
                               v_schedule_tab(i).CRN)||c_tab||
               v_schedule_tab(i).Instructor||c_tab||
               v_schedule_tab(i).LongCourseTitle||c_tab||
               v_schedule_tab(i).LongSectionTitle||c_tab||
               v_schedule_tab(i).CourseCoReqs||c_tab||
               v_schedule_tab(i).SectionCoReqs||c_tab||
               v_schedule_tab(i).Links||c_tab||
               v_schedule_tab(i).CrossLists||c_tab||
               v_schedule_tab(i).CrossListGroup||c_tab||
               to_char(v_schedule_tab(i).CrossListCapacity)||c_tab||
               to_char(v_schedule_tab(i).CrossListFilled)||c_tab||
               to_char(v_schedule_tab(i).CrossListOpen)||c_tab||
               v_schedule_tab(i).Levels||c_tab||
               v_schedule_tab(i).RegistrationBegin||c_tab||
               v_schedule_tab(i).RegistrationEnd||c_tab||
               v_schedule_tab(i).ApprovalCode||c_tab||
               v_schedule_tab(i).Approval||c_tab||
               v_schedule_tab(i).SectionAttributes||c_tab||
               v_schedule_tab(i).CourseAttributes||c_tab||
               f_flat_section_text(v_schedule_tab(i).TermCode,
                                   v_schedule_tab(i).CRN)||c_tab||
               f_flat_section_long_text(v_schedule_tab(i).TermCode,
                                        v_schedule_tab(i).CRN)||c_tab||
               v_schedule_tab(i).CourseText||c_tab||
               v_schedule_tab(i).CourseLongText||c_tab||
               v_schedule_tab(i).InstructionalMethodCode||c_tab||
               v_schedule_tab(i).InstructionalMethod||c_tab||
               v_schedule_tab(i).PartOfTermBeginEnd||c_tab||
               v_schedule_tab(i).SessionCode||c_tab||
               v_schedule_tab(i).Session||c_tab||
               v_schedule_tab(i).Fees||c_tab||
               v_schedule_tab(i).PreReqMethod||c_tab||
               v_schedule_tab(i).PreReqFlag||c_tab||
               v_schedule_tab(i).CreditRange||c_tab||
               v_schedule_tab(i).SectionCredits||c_tab||
               v_schedule_tab(i).ScheduleFunction||c_tab||
               v_schedule_tab(i).CourseGradeModes||c_tab||
               v_schedule_tab(i).SectionGradeMode||c_tab||
               v_schedule_tab(i).RegistrationFlag||c_tab||
               f_flat_restrictions(v_schedule_tab(i).TermCode,
                                   v_schedule_tab(i).CRN)||c_lf;
            dbms_lob.append(v_schedule,v_schedule_row);
         end loop;
--
      end if;
--
      RETURN v_schedule;
--
--   EXCEPTION
--
--
   END f_get_schedule;
--
PROCEDURE p_job_schedule
--
-- p_job_schedule calls f_get_schedule to generate schedule data for
-- current College Scheduler terms and saves the output in the
-- CSCHED_SERVICES table.  p_job_schedule is executed asynchronously as a
-- dbms_scheduler job by p_job_queue.
--
   IS
--
      v_settings                       csched_settings%rowtype;
      v_terms_tab                      t_terms_tab;
      v_schedule                       clob := empty_clob();
      v_schedule_coded                 clob := empty_clob();
      v_RequestedDate                  timestamp;
      v_terms_view_status              varchar2(7);
--
      c_system                CONSTANT varchar2(255)  := 'P_JOB_SCHEDULE';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      c_schedule_header       CONSTANT varchar2(32767) :=
         '[TermCode]'||c_tab||
         '[Term]'||c_tab||
         '[CRN]'||c_tab||
         '[Timestamp]'||c_tab||
         '[PartOfTermCode]'||c_tab||
         '[PartOfTerm]'||c_tab||
         '[SubjectCode]'||c_tab||
         '[Subject]'||c_tab||
         '[Course]'||c_tab||
         '[Section]'||c_tab||
         '[SectionStatusCode]'||c_tab||
         '[SectionStatus]'||c_tab||
         '[ScheduleTypeCode]'||c_tab||
         '[ScheduleType]'||c_tab||
         '[CampusCode]'||c_tab||
         '[Campus]'||c_tab||
         '[SectionTitle]'||c_tab||
         '[SectionPrintIndicator]'||c_tab||
         '[SeatCapacity]'||c_tab||
         '[SeatsFilled]'||c_tab||
         '[SeatsOpen]'||c_tab||
         '[WaitlistCapacity]'||c_tab||
         '[WaitlistFilled]'||c_tab||
         '[WaitlistOpen]'||c_tab||
         '[SectionWebIndicator]'||c_tab||
         '[CollegeCode]'||c_tab||
         '[College]'||c_tab||
         '[DepartmentCode]'||c_tab||
         '[Department]'||c_tab||
         '[CourseTitle]'||c_tab||
         '[Credits]'||c_tab||
         '[Meetings]'||c_tab||
         '[Instructor]'||c_tab||
         '[LongCourseTitle]'||c_tab||
         '[LongSectionTitle]'||c_tab||
         '[CourseCoReqs]'||c_tab||
         '[SectionCoReqs]'||c_tab||
         '[Links]'||c_tab||
         '[CrossLists]'||c_tab||
         '[CrossListGroup]'||c_tab||
         '[CrossListCapacity]'||c_tab||
         '[CrossListFilled]'||c_tab||
         '[CrossListOpen]'||c_tab||
         '[Levels]'||c_tab||
         '[RegistrationBegin]'||c_tab||
         '[RegistrationEnd]'||c_tab||
         '[ApprovalCode]'||c_tab||
         '[Approval]'||c_tab||
         '[SectionAttributes]'||c_tab||
         '[CourseAttributes]'||c_tab||
         '[SectionText]'||c_tab||
         '[SectionLongText]'||c_tab||
         '[CourseText]'||c_tab||
         '[CourseLongText]'||c_tab||
         '[InstructionalMethodCode]'||c_tab||
         '[InstructionalMethod]'||c_tab||
         '[PartOfTermBegin]'||c_tab||
         '[PartOfTermEnd]'||c_tab||
         '[SessionCode]'||c_tab||
         '[Session]'||c_tab||
         '[Fees]'||c_tab||
         '[PreReqMethod]'||c_tab||
         '[PreReqFlag]'||c_tab||
         '[CreditRange]'||c_tab||
         '[SectionCredits]'||c_tab||
         '[CustomData]'||c_tab||                -- Previously [ScheduleFunction]
         '[CourseGradeModes]'||c_tab||
         '[SectionGradeMode]'||c_tab||
         '[RegistrationFlag]'||c_tab||
         '[SectionRestrictions]'||c_lf;
--
   BEGIN
--
      v_RequestedDate := systimestamp;
      v_settings      := f_settings;
-- Validate CSCHED_TERMS_VIEW
      begin
         select status
           into v_terms_view_status
           from all_objects
          where object_name =  'CSCHED_TERMS_VIEW'
            and object_type =  'VIEW';
      exception
         when NO_DATA_FOUND then
            null;
      end;
      if v_terms_view_status = c_invalid
      then
         RAISE_APPLICATION_ERROR(-20023,
                                 'Invalid Terms View - CSCHED_TERMS_VIEW');
      end if;
-- Set active terms from CSCHED_TERMS_VIEW
      if v_terms_view_status = c_valid
      then
         -- Insert current terms
         EXECUTE IMMEDIATE ('insert into csched_terms '||
                                     '(term_code, '||
                                      'active_ind, '||
                                      'activity_date) '||
                               'select term_code, '||
                                      '''Y'', '||
                                      'sysdate '||
                                 'from csched_terms_view '||
                                'where term_code NOT in (select term_code '||
                                                          'from csched_terms)');
         -- Activate current terms
         EXECUTE IMMEDIATE ('update csched_terms '||
                               'set active_ind    = ''Y'', '||
                                   'activity_date = sysdate '||
                             'where term_code in (select term_code '||
                                                   'from csched_terms_view) '||
                               'and active_ind = ''N''');
         -- Inactivate non-current terms
         EXECUTE IMMEDIATE ('update csched_terms '||
                               'set active_ind    = ''N'', '||
                                   'activity_date = sysdate '||
                             'where term_code NOT in (select term_code '||
                                                       'from csched_terms_view) '||
                               'and active_ind = ''Y''');
         --
         COMMIT;
         --
      end if;
--
      select *
        BULK COLLECT
        into v_terms_tab
        from csched_terms
       where active_ind = c_yes
       order by term_code;
--
       if v_terms_tab.count = 0
       then RAISE_APPLICATION_ERROR(-20014,
                                    'Zero Active Terms (CSCHED_TERMS)');
       end if;
--
      dbms_lob.createtemporary(v_schedule,
                               TRUE);
      dbms_lob.writeappend(v_schedule,
                           length(c_schedule_header),
                           to_clob(c_schedule_header));
--
      for i in v_terms_tab.first..v_terms_tab.last
      loop
         dbms_lob.append(v_schedule,
                         f_get_schedule(v_terms_tab(i).term_code,
                                        v_settings.schedule_function,
                                        v_settings.instructor_name_format));
      end loop;
--
      dbms_lob.createtemporary(v_schedule_coded,
                               TRUE);
--
      dbms_lob.append(v_schedule_coded,
                      f_compress_b64(v_schedule,
                                     v_settings.schedule_format,
                                     v_settings.negotiated_key));
--
      dbms_lob.freetemporary(v_schedule);
--
      insert into csched_services
                (job_type,
                 job_name,
                 requested_date,
                 fulfilled_date,
                 payload)
         values (c_outbound,
                 c_schedule_job,
                 v_RequestedDate,
                 systimestamp,
                 v_schedule_coded);
--
      dbms_lob.freetemporary(v_schedule_coded);
--
      COMMIT;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_schedule) = 1
         then dbms_lob.freetemporary(v_schedule);
         end if;
--
         if dbms_lob.istemporary(v_schedule_coded) = 1
         then dbms_lob.freetemporary(v_schedule_coded);
         end if;
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         insert into csched_services
                   (job_type,
                    job_name,
                    requested_date,
                    fulfilled_date,
                    payload)
            values (c_outbound,
                    c_schedule_job,
                    v_RequestedDate,
                    systimestamp,
                    to_clob(c_job_error_tag||c_lf||
                            c_schedule_job||c_lf||
                            v_sqlerrm||c_lf||
                            v_backtrace));
         COMMIT;
--
   END p_job_schedule;
--
PROCEDURE p_job_catalog
--
-- p_job_catalog generates catalog data for the earliest enrollment term that
-- has not yet ended and saves the output in the CSCHED_SERVICES table.
-- p_job_catalog is executed asynchronously as a dbms_scheduler job by p_job_queue.
--
   IS
--
      v_settings                       csched_settings%rowtype;
      v_catalog_row                    clob := empty_clob();
      v_catalog                        clob := empty_clob();
      v_catalog_coded                  clob := empty_clob();
      v_prev_subj_crse                 varchar2(9);
      v_RequestedDate                  timestamp;
--
      c_system                CONSTANT varchar2(255)  := 'P_JOB_CATALOG';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      c_catalog_header        CONSTANT varchar2(32767) :=
         '[TermCode]'||c_tab||
         '[Term]'||c_tab||
         '[SubjectCode]'||c_tab||
         '[Subject]'||c_tab||
         '[Course]'||c_tab||
         '[Timestamp]'||c_tab||
         '[CourseStatusCode]'||c_tab||
         '[CourseStatus]'||c_tab||
         '[Active]'||c_tab||
         '[CollegeCode]'||c_tab||
         '[College]'||c_tab||
         '[DepartmentCode]'||c_tab||
         '[Department]'||c_tab||
         '[CourseTitle]'||c_tab||
         '[LongCourseTitle]'||c_tab||
         '[CourseCoReqs]'||c_tab||
         '[Levels]'||c_tab||
         '[CourseAttributes]'||c_tab||
         '[CourseText]'||c_tab||
         '[CourseLongText]'||c_tab||
         '[CreditRange]'||c_tab||
         '[Restriction]'||c_lf;
--
      type t_catalog_row          is record (TermCode                varchar2(6),
                                             Term                    varchar2(30),
                                             SubjectCode             varchar2(4),
                                             Subject                 varchar2(30),
                                             Course                  varchar2(5),
                                             Timestamp               varchar2(26),
                                             CourseStatusCode        varchar2(1),
                                             CourseStatus            varchar2(30),
                                             Active                  varchar2(1),
                                             CollegeCode             varchar2(2),
                                             College                 varchar2(30),
                                             DepartmentCode          varchar2(4),
                                             Department              varchar2(30),
                                             CourseTitle             varchar2(30),
                                             LongCourseTitle         varchar2(100),
                                             CourseCoReqs            varchar2(4000),
                                             Levels                  varchar2(4000),
                                             CourseAttributes        varchar2(4000),
                                             -- CourseText           -- Clob Exclusion
                                             CourseLongText          clob,
                                             CreditRange             varchar2(17),
                                             Restriction             varchar2(4000)
                                             );
--
      type t_catalog_tab          is table of t_catalog_row
                                     index by binary_integer;
      v_catalog_tab               t_catalog_tab;
--
      cursor c_catalog is
         select scbcrse_eff_term                                               TermCode,
                (select f_clean(stvterm_desc)
                   from stvterm
                  where stvterm_code = scbcrse_eff_term)                       Term,
                scbcrse_subj_code                                              SubjectCode,
                (select f_clean(stvsubj_desc)
                   from stvsubj
                  where stvsubj_code = scbcrse_subj_code)                      Subject,
                scbcrse_crse_numb                                              Course,
                to_char(systimestamp,
                        c_time_format)                                         Timestamp,
                scbcrse_csta_code                                              CourseStatusCode,
                f_clean(stvcsta_desc)                                          CourseStatus,
                stvcsta_active_ind                                             Active,
                scbcrse_coll_code                                              CollegeCode,
                (select f_clean(stvcoll_desc)
                   from stvcoll
                  where stvcoll_code = scbcrse_coll_code)                      College,
                scbcrse_dept_code                                              DepartmentCode,
                (select f_clean(stvdept_desc)
                   from stvdept
                  where stvdept_code = scbcrse_dept_code)                      Department,
                f_clean(scbcrse_title)                                         CourseTitle,
                (select f_clean(scrsyln_long_course_title)
                   from scrsyln b
                  where scrsyln_subj_code  = scbcrse_subj_code
                    and scrsyln_crse_numb  = scbcrse_crse_numb
                    and scrsyln_term_code_eff =
                        (select max(scrsyln_term_code_eff)
                           from scrsyln
                          where scrsyln_term_code_eff <= stvterm_code
                            and scrsyln_subj_code     =  b.scrsyln_subj_code
                            and scrsyln_crse_numb     =  b.scrsyln_crse_numb)) LongCourseTitle,
                f_flat_CourseCoReqs(stvterm_code,
                                    scbcrse_subj_code,
                                    scbcrse_crse_numb)                         CourseCoReqs,
                f_flat_levels(scbcrse_subj_code,
                              scbcrse_crse_numb,
                              stvterm_code)                                    Levels,
                f_flat_course_attr(scbcrse_subj_code,
                                   scbcrse_crse_numb,
                                   stvterm_code)                               CourseAttributes,
                -- Clob Exclusion                                              CourseText,
                f_flat_course_long_text(scbcrse_subj_code,
                                        scbcrse_crse_numb,
                                        stvterm_code)                          CourseLongText,
                to_char(scbcrse_credit_hr_low)||'|'||
                   to_char(scbcrse_credit_hr_high)                             CreditRange,
                (select listagg(scrrtrm_term_ind||'|'||
                                scrrtrm_rtrm_code||'|'||
                                f_clean((select translate(stvrtrm_desc,',|','--')
                                           from stvrtrm
                                          where stvrtrm_code =  scrrtrm_rtrm_code)),',')
                           within group (order by scrrtrm_term_ind,
                                                  scrrtrm_rtrm_code)
                   from scrrtrm d
                  where scrrtrm_subj_code =  scbcrse_subj_code
                    and scrrtrm_crse_numb =  scbcrse_crse_numb
                    and scrrtrm_eff_term  =
                           (select max(scrrtrm_eff_term)
                              from scrrtrm
                             where scrrtrm_eff_term       <= stvterm_code
                               and scrrtrm_subj_code      = d.scrrtrm_subj_code
                               and scrrtrm_crse_numb      = d.scrrtrm_crse_numb)
                    and scrrtrm_rec_type  =  1)                                Restriction
           from stvcsta,
                scbcrse a,
                (select min(stvterm_code) stvterm_code
                   from stvterm
                  where stvterm_code NOT in ('000000','999999')
                    and sysdate <=  stvterm_end_date)
          where stvcsta_code     =  scbcrse_csta_code
            and (scbcrse_eff_term =  (select max(scbcrse_eff_term)
                                        from scbcrse
                                       where scbcrse_eff_term  <= stvterm_code
                                         and scbcrse_subj_code =  a.scbcrse_subj_code
                                         and scbcrse_crse_numb =  a.scbcrse_crse_numb)
             or  scbcrse_eff_term =  (select min(scbcrse_eff_term)
                                        from scbcrse
                                       where scbcrse_eff_term > stvterm_code
                                         and scbcrse_csta_code in
                                                (select stvcsta_code
                                                   from stvcsta
                                                  where stvcsta_active_ind = c_active)
                                         and scbcrse_subj_code =  a.scbcrse_subj_code
                                         and scbcrse_crse_numb =  a.scbcrse_crse_numb))
          order by scbcrse_subj_code,
                   scbcrse_crse_numb,
                   scbcrse_eff_term;
--
   BEGIN
--
      v_RequestedDate := systimestamp;
      v_settings      := f_settings;
--
      dbms_lob.createtemporary(v_catalog,
                               TRUE);
      dbms_lob.writeappend(v_catalog,
                           length(c_catalog_header),
                           to_clob(c_catalog_header));
-- Fetch SCBCRSE Course Data
      open  c_catalog;
      fetch c_catalog BULK COLLECT into v_catalog_tab;
      close c_catalog;
--
      if v_catalog_tab.count = 0
      then RAISE_APPLICATION_ERROR(-20026,
                                   'Catalog not selected');
      end if;
-- Build CLOB
      for i in v_catalog_tab.first..v_catalog_tab.last
      loop
         v_catalog_row :=
            v_catalog_tab(i).TermCode||c_tab||
            v_catalog_tab(i).Term||c_tab||
            v_catalog_tab(i).SubjectCode||c_tab||
            v_catalog_tab(i).Subject||c_tab||
            v_catalog_tab(i).Course||c_tab||
            v_catalog_tab(i).Timestamp||c_tab||
            v_catalog_tab(i).CourseStatusCode||c_tab||
            v_catalog_tab(i).CourseStatus||c_tab||
            v_catalog_tab(i).Active||c_tab||
            v_catalog_tab(i).CollegeCode||c_tab||
            v_catalog_tab(i).College||c_tab||
            v_catalog_tab(i).DepartmentCode||c_tab||
            v_catalog_tab(i).Department||c_tab||
            v_catalog_tab(i).CourseTitle||c_tab||
            v_catalog_tab(i).LongCourseTitle||c_tab||
            v_catalog_tab(i).CourseCoReqs||c_tab||
            v_catalog_tab(i).Levels||c_tab||
            v_catalog_tab(i).CourseAttributes||c_tab||
            f_flat_course_text(v_catalog_tab(i).SubjectCode,
                               v_catalog_tab(i).Course,
                               v_catalog_tab(i).TermCode)||c_tab||
            v_catalog_tab(i).CourseLongText||c_tab||
            v_catalog_tab(i).CreditRange||c_tab||
            v_catalog_tab(i).Restriction||c_lf;
        -- prefer an Active Future course over an Inactive Current
         if  (i < v_catalog_tab.last
         and  v_catalog_tab(i).Course      =  v_catalog_tab(i+1).Course
         and  v_catalog_tab(i).SubjectCode =  v_catalog_tab(i+1).SubjectCode
         and  v_catalog_tab(i).Active      =  c_inactive
         and  v_catalog_tab(i+1).Active    =  c_active)
          or (v_prev_subj_crse =  v_catalog_tab(i).SubjectCode||
                                  v_catalog_tab(i).Course)
         then
            null;
         else
            dbms_lob.append(v_catalog,v_catalog_row);
            v_prev_subj_crse := v_catalog_tab(i).SubjectCode||
                                v_catalog_tab(i).Course;
         end if;
      end loop;
--
      dbms_lob.createtemporary(v_catalog_coded,
                               TRUE);
--
      dbms_lob.append(v_catalog_coded,
                      f_compress_b64(v_catalog,
                                     v_settings.schedule_format,
                                     v_settings.negotiated_key));
--
      dbms_lob.freetemporary(v_catalog);
--
      insert into csched_services
                (job_type,
                 job_name,
                 requested_date,
                 fulfilled_date,
                 payload)
         values (c_outbound,
                 c_catalog_job,
                 v_RequestedDate,
                 systimestamp,
                 v_catalog_coded);
--
      dbms_lob.freetemporary(v_catalog_coded);
--
      COMMIT;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_catalog) = 1
         then dbms_lob.freetemporary(v_catalog);
         end if;
--
         if dbms_lob.istemporary(v_catalog_coded) = 1
         then dbms_lob.freetemporary(v_catalog_coded);
         end if;
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         insert into csched_services
                   (job_type,
                    job_name,
                    requested_date,
                    fulfilled_date,
                    payload)
            values (c_outbound,
                    c_catalog_job,
                    v_RequestedDate,
                    systimestamp,
                    to_clob(c_job_error_tag||c_lf||
                            c_catalog_job||c_lf||
                            v_sqlerrm||c_lf||
                            v_backtrace));
         COMMIT;
--
   END p_job_catalog;
--
PROCEDURE p_job_termvalidation
--
-- p_job_termvalidation generates term validation data from the STVTERM table
-- and saves the output in the CSCHED_SERVICES table.  p_job_termvalidation is
-- executed asynchronously as a dbms_scheduler job by p_job_queue.
--
   IS
--
      v_settings                       csched_settings%rowtype;
      v_term_row                       clob := empty_clob();
      v_terms                          clob := empty_clob();
      v_terms_coded                    clob := empty_clob();
      v_RequestedDate                  timestamp;
      v_catalog_term                   varchar2(6);
--
      c_system                CONSTANT varchar2(255)  := 'P_JOB_TERMVALIDATION';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      c_term_header           CONSTANT varchar2(32767) :=
         '[TermCode]'||c_tab||
         '[Term]'||c_tab||
         '[Timestamp]'||c_tab||
         '[TermBegin]'||c_tab||
         '[TermEnd]'||c_tab||
         '[ScheduleTerm]'||c_tab||
         '[CatalogTerm]'||c_lf;
--
      type t_terms_row            is record (TermCode                varchar2(6),
                                             Term                    varchar2(30),
                                             Timestamp               varchar2(26),
                                             TermBegin               varchar2(19),
                                             TermEnd                 varchar2(19),
                                             ScheduleTerm            varchar2(1),
                                             CatalogTerm             varchar2(1)
                                             );
--
      type t_terms_tab            is table of t_terms_row
                                     index by binary_integer;
      v_terms_tab                 t_terms_tab;
--
      cursor c_terms is
         select stvterm_code                                                   TermCode,
                f_clean(stvterm_desc)                                          Term,
                to_char(systimestamp,
                        c_time_format)                                         Timestamp,
                to_char(stvterm_start_date,c_date_format)                      TermBegin,
                to_char(stvterm_end_date,c_date_format)                        TermEnd,
                nvl((select c_yes
                       from csched_terms
                      where term_code  =  stvterm_code
                        and active_ind =  c_yes),c_no)                         ScheduleTerm,
                null                                                           CatalogTerm
           from stvterm
          order by stvterm_code;
--
   BEGIN
--
      v_RequestedDate := systimestamp;
      v_settings      := f_settings;
-- Select Catalog Term
      begin
         select min(stvterm_code)
           into v_catalog_term
           from stvterm
          where stvterm_code NOT in ('000000','999999')
            and sysdate <=  stvterm_end_date;
      exception
         when NO_DATA_FOUND then
            null;
      end;
--
      dbms_lob.createtemporary(v_terms,
                               TRUE);
      dbms_lob.writeappend(v_terms,
                           length(c_term_header),
                           to_clob(c_term_header));
-- Fetch SCBCRSE Course Data
      open  c_terms;
      fetch c_terms BULK COLLECT into v_terms_tab;
      close c_terms;
--
      if v_terms_tab.count = 0
      then RAISE_APPLICATION_ERROR(-20027,
                                   'No Term Codes available');
      end if;
-- Build CLOB
      for i in v_terms_tab.first..v_terms_tab.last
      loop
         if v_terms_tab(i).TermCode = v_catalog_term
         then
            v_terms_tab(i).CatalogTerm := c_yes;
         else
            v_terms_tab(i).CatalogTerm := c_no;
         end if;
         v_term_row :=
            v_terms_tab(i).TermCode||c_tab||
            v_terms_tab(i).Term||c_tab||
            v_terms_tab(i).Timestamp||c_tab||
            v_terms_tab(i).TermBegin||c_tab||
            v_terms_tab(i).TermEnd||c_tab||
            v_terms_tab(i).ScheduleTerm||c_tab||
            v_terms_tab(i).CatalogTerm||c_lf;
         dbms_lob.append(v_terms,v_term_row);
      end loop;
--
      dbms_lob.createtemporary(v_terms_coded,
                               TRUE);
--
      dbms_lob.append(v_terms_coded,
                      f_compress_b64(v_terms,
                                     v_settings.schedule_format,
                                     v_settings.negotiated_key));
--
      dbms_lob.freetemporary(v_terms);
--
      insert into csched_services
                (job_type,
                 job_name,
                 requested_date,
                 fulfilled_date,
                 payload)
         values (c_outbound,
                 c_termvalidation_job,
                 v_RequestedDate,
                 systimestamp,
                 v_terms_coded);
--
      dbms_lob.freetemporary(v_terms_coded);
--
      COMMIT;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_terms) = 1
         then dbms_lob.freetemporary(v_terms);
         end if;
--
         if dbms_lob.istemporary(v_terms_coded) = 1
         then dbms_lob.freetemporary(v_terms_coded);
         end if;
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         insert into csched_services
                   (job_type,
                    job_name,
                    requested_date,
                    fulfilled_date,
                    payload)
            values (c_outbound,
                    c_termvalidation_job,
                    v_RequestedDate,
                    systimestamp,
                    to_clob(c_job_error_tag||c_lf||
                            c_termvalidation_job||c_lf||
                            v_sqlerrm||c_lf||
                            v_backtrace));
         COMMIT;
--
   END p_job_termvalidation;
--
FUNCTION f_get_stats
   RETURN clob
--
-- f_get_stats returns College Scheduler statistics, tab delimited, as a
--   Character Large Object (CLOB).
--
   IS
--
      c_nullclass            CONSTANT varchar2(2)    := '--';
      c_nulllevel            CONSTANT varchar2(2)    := '--';
      c_stats_date_format    CONSTANT varchar2(10)   := 'YYYY-MM-DD';
      c_number_format        CONSTANT varchar2(18)   := 'FM999999999990.000';
--
      v_stats_text                    varchar2(32767);
      v_neverreg                      number(15);
      v_stats                         clob := empty_clob();
--
      cursor c_terms is
         select stvterm_code                                                   TermCode,
                f_clean(stvterm_desc)                                          Term,
                stvterm_start_date                                             StartDate,
                stvterm_end_date                                               EndDate,
                stvterm_acyr_code                                              AcademicYear
           from stvterm
          where stvterm_code not in ('000000','999999')
            and stvterm_code in (select distinct term_code
                                   from csched_regcart)
          order by stvterm_code;
--
      cursor c_stats(p_term_code  varchar2) is
         --
         WITH student AS (
                 select sgbstdn_pidm                                           Pidm,
                        sgbstdn_levl_code                                      LevelCode,
                        (select DISTINCT 1
                               from csched_regcart
                              where pidm      =  sgbstdn_pidm
                                and term_code =  p_term_code)                  PlanUser
                   from sgbstdn a
                  where sgbstdn_term_code_eff =
                           (select max(sgbstdn_term_code_eff)
                             from sgbstdn
                            where sgbstdn_term_code_eff <= p_term_code
                              and sgbstdn_pidm          =  a.sgbstdn_pidm)),
         --
              registration AS (
                 select sfrstcr_pidm                                           Pidm,
                        count(*)                                               RegCount,
                        sum(sfrstcr_credit_hr)                                 RegHours,
                        decode(sum(sfrstcr_credit_hr),0,null,1)                RegUser
                   from sfrstcr
                  where sfrstcr_term_code =  p_term_code
                    and sfrstcr_rsts_code in (select stvrsts_code
                                                from stvrsts
                                               where stvrsts_incl_sect_enrl =  'Y'
                                                 and stvrsts_wait_ind       =  'N'
                                                 and stvrsts_withdraw_ind   =  'N')
                  group by sfrstcr_pidm),
         --
              withdrawn AS (
                 select sfrstcr_pidm                                           Pidm,
                        count(*)                                               WDCount,
                        sum(sfrstcr_credit_hr)                                 WDHours
                   from sfrstcr
                  where sfrstcr_term_code =  p_term_code
                    and sfrstcr_rsts_code in (select stvrsts_code
                                                from stvrsts
                                               where stvrsts_wait_ind        =  'N'
                                                 and (stvrsts_withdraw_ind   =  'Y'
                                                  or  stvrsts_incl_sect_enrl =  'N'))
                  group by sfrstcr_pidm),
         --
              regaudit AS (
                 select sfrstca_pidm                                           Pidm,
                        count(*)                                               AuditCount
                   from sfrstca
                  where sfrstca_term_code =  p_term_code
                  group by sfrstca_pidm)
         --
         select null                                                           TermCode,
                null                                                           Term,
                null                                                           StartDate,
                null                                                           EndDate,
                null                                                           AcademicYear,
                nvl(sgkclas.f_class_code(student.Pidm,
                                         student.LevelCode,
                                         p_term_code),
                    c_nullclass)                                               ClassCode,
                null                                                           "Class",
                LevelCode                                                      LevelCode,
                null                                                           "Level",
                nvl(sum(RegUser*nvl2(PlanUser,0,1)),0)                         RNPTotal,
                nvl(sum(RegUser*nvl2(PlanUser,0,1)*AuditCount),0)              RNPRows,
                nvl(sum(RegUser*nvl2(PlanUser,0,1)*RegCount),0)                RNPRegs,
                nvl(sum(RegUser*nvl2(PlanUser,0,1)*WDCount),0)                 RNPWD,
                nvl(sum(RegUser*nvl2(PlanUser,0,1)*RegHours),0)                RNPRegsCr,
                nvl(sum(RegUser*PlanUser),0)                                   RPLTotal,
                nvl(sum(RegUser*PlanUser*AuditCount),0)                        RPLRows,
                nvl(sum(RegUser*PlanUser*RegCount),0)                          RPLRegs,
                nvl(sum(RegUser*PlanUser*WDCount),0)                           RPLWD,
                nvl(sum(RegUser*PlanUser*RegHours),0)                          RPLRegsCr,
                nvl(sum(nvl2(RegUser,0,1)*nvl2(PlanUser,0,1)),0)               XNPTotal,
                nvl(sum(nvl2(RegUser,0,1)*nvl2(PlanUser,0,1)*AuditCount),0)    XNPRows,
                nvl(sum(nvl2(RegUser,0,1)*nvl2(PlanUser,0,1)*RegCount),0)      XNPRegs,
                nvl(sum(nvl2(RegUser,0,1)*nvl2(PlanUser,0,1)*WDCount),0)       XNPWD,
                nvl(sum(nvl2(RegUser,0,1)*nvl2(PlanUser,0,1)*RegHours),0)      XNPRegsCr,
                nvl(sum(nvl2(RegUser,0,1)*PlanUser),0)                         XPLTotal,
                nvl(sum(nvl2(RegUser,0,1)*PlanUser*AuditCount),0)              XPLRows,
                nvl(sum(nvl2(RegUser,0,1)*PlanUser*RegCount),0)                XPLRegs,
                nvl(sum(nvl2(RegUser,0,1)*PlanUser*WDCount),0)                 XPLWD,
                nvl(sum(nvl2(RegUser,0,1)*PlanUser*RegHours),0)                XPLRegsCr,
                count(*)                                                       ALLTotal,
                0                                                              NeverReg
           from regaudit,
                withdrawn,
                registration,
                student
          where regaudit.Pidm        =  student.Pidm
            and withdrawn.Pidm(+)    =  student.Pidm
            and registration.Pidm(+) =  student.Pidm
          group by LevelCode,
                   nvl(sgkclas.f_class_code(student.Pidm,
                                            student.LevelCode,
                                            p_term_code),
                       c_nullclass)
          order by 8,6;
--
      cursor c_neverreg (p_term_code  varchar2) is
         select count(*)
           from (select distinct pidm
                   from csched_regcart
                  where term_code =  p_term_code
                    and (not exists (select 'X'
                                      from sfrstca
                                     where sfrstca_term_code =  p_term_code
                                       and sfrstca_pidm      =  pidm)));
--
      type t_stats_row            is record  (TermCode      varchar2(6),
                                              Term          varchar2(30),
                                              StartDate     date,
                                              EndDate       date,
                                              AcademicYear  varchar2(4),
                                              ClassCode     varchar2(2),
                                              Class         varchar2(30),
                                              LevelCode     varchar2(2),
                                              Level         varchar2(30),
                                              RNPTotal      number(15),
                                              RNPRows       number(15),
                                              RNPRegs       number(15),
                                              RNPWD         number(15),
                                              RNPRegsCr     number(15,3),
                                              RPLTotal      number(15),
                                              RPLRows       number(15),
                                              RPLRegs       number(15),
                                              RPLWD         number(15),
                                              RPLRegsCr     number(15,3),
                                              XNPTotal      number(15),
                                              XNPRows       number(15),
                                              XNPRegs       number(15),
                                              XNPWD         number(15),
                                              XNPRegsCr     number(15,3),
                                              XPLTotal      number(15),
                                              XPLRows       number(15),
                                              XPLRegs       number(15),
                                              XPLWD         number(15),
                                              XPLRegsCr     number(15,3),
                                              ALLTotal      number(15),
                                              NeverReg      number(15));
--
      type t_stats_tab            is table of t_stats_row;
      v_stats_tab                 t_stats_tab;
--
      c_stats_key       CONSTANT  varchar2(4000) :=
         '[TermCode]'||c_tab||
         '[Term]'||c_tab||
         '[StartDate]'||c_tab||
         '[EndDate]'||c_tab||
         '[AcademicYear]'||c_tab||
         '[ClassCode]'||c_tab||
         '[Class]'||c_tab||
         '[LevelCode]'||c_tab||
         '[Level]'||c_tab||
         '[RNPTotal]'||c_tab||                  -- Registered Non-Scheduler Users
         '[RNPRows]'||c_tab||
         '[RNPRegs]'||c_tab||
         '[RNPWD]'||c_tab||
         '[RNPRegsCr]'||c_tab||
         '[RPLTotal]'||c_tab||                  -- Registered Scheduler Users
         '[RPLRows]'||c_tab||
         '[RPLRegs]'||c_tab||
         '[RPLWD]'||c_tab||
         '[RPLRegsCr]'||c_tab||
         '[XNPTotal]'||c_tab||                  -- Non-Registered Non-Scheduler Users
         '[XNPRows]'||c_tab||
         '[XNPRegs]'||c_tab||
         '[XNPWD]'||c_tab||
         '[XNPRegsCr]'||c_tab||
         '[XPLTotal]'||c_tab||                  -- Non-Registered Scheduler Users
         '[XPLRows]'||c_tab||
         '[XPLRegs]'||c_tab||
         '[XPLWD]'||c_tab||
         '[XPLRegsCr]'||c_tab||
         '[ALLTotal]'||c_tab||                  -- All Users
         '[NeverReg]'||c_lf;                    -- Never Registered Scheduler Users
--
   BEGIN
--
      v_stats := c_stats_key;
--
      for term_rec in c_terms
      loop
      --
         open c_stats(term_rec.TermCode);
         fetch c_stats
          BULK COLLECT
          into v_stats_tab;
         close c_stats;
      --
         for i in 1..v_stats_tab.count
         loop
            -- v_stats_tab(i).Class
            begin
               select f_clean(stvclas_desc)
                 into v_stats_tab(i).Class
                 from stvclas
                where stvclas_code =  v_stats_tab(i).ClassCode;
            exception
               when NO_DATA_FOUND then
                  v_stats_tab(i).Class := c_nullclass;
            end;
            --  v_stats_tab(i).Level
            begin
               select f_clean(stvlevl_desc)
                 into v_stats_tab(i).Level
                 from stvlevl
                where stvlevl_code =  v_stats_tab(i).LevelCode;
            exception
               when NO_DATA_FOUND then
                  v_stats_tab(i).Level := c_nulllevel;
            end;
         --
         end loop;
      --
         for i in 1..v_stats_tab.count
         loop
         --
            v_stats_text :=
               term_rec.TermCode||c_tab||
               term_rec.Term||c_tab||
               to_char(term_rec.StartDate,c_stats_date_format)||c_tab||
               to_char(term_rec.EndDate,c_stats_date_format)||c_tab||
               term_rec.AcademicYear||c_tab||
               v_stats_tab(i).ClassCode||c_tab||
               v_stats_tab(i).Class||c_tab||
               v_stats_tab(i).LevelCode||c_tab||
               v_stats_tab(i).Level||c_tab||
               to_char(v_stats_tab(i).RNPTotal)||c_tab||
               to_char(v_stats_tab(i).RNPRows)||c_tab||
               to_char(v_stats_tab(i).RNPRegs)||c_tab||
               to_char(v_stats_tab(i).RNPWD)||c_tab||
               to_char(v_stats_tab(i).RNPRegsCr,c_number_format)||c_tab||
               to_char(v_stats_tab(i).RPLTotal)||c_tab||
               to_char(v_stats_tab(i).RPLRows)||c_tab||
               to_char(v_stats_tab(i).RPLRegs)||c_tab||
               to_char(v_stats_tab(i).RPLWD)||c_tab||
               to_char(v_stats_tab(i).RPLRegsCr,c_number_format)||c_tab||
               to_char(v_stats_tab(i).XNPTotal)||c_tab||
               to_char(v_stats_tab(i).XNPRows)||c_tab||
               to_char(v_stats_tab(i).XNPRegs)||c_tab||
               to_char(v_stats_tab(i).XNPWD)||c_tab||
               to_char(v_stats_tab(i).XNPRegsCr,c_number_format)||c_tab||
               to_char(v_stats_tab(i).XPLTotal)||c_tab||
               to_char(v_stats_tab(i).XPLRows)||c_tab||
               to_char(v_stats_tab(i).XPLRegs)||c_tab||
               to_char(v_stats_tab(i).XPLWD)||c_tab||
               to_char(v_stats_tab(i).XPLRegsCr,c_number_format)||c_tab||
               to_char(v_stats_tab(i).ALLTotal)||c_tab||
               '0'||c_lf;
            v_stats := v_stats||v_stats_text;
         end loop;
      --
         open  c_neverreg(term_rec.TermCode);
         fetch c_neverreg into v_neverreg;
         close c_neverreg;
      --
         if v_neverreg <> 0
         then
            v_stats_text :=
               term_rec.TermCode||c_tab||
               term_rec.Term||c_tab||
               to_char(term_rec.StartDate,c_stats_date_format)||c_tab||
               to_char(term_rec.EndDate,c_stats_date_format)||c_tab||
               term_rec.AcademicYear||c_tab||
               c_nullclass||c_tab||
               'Never Registered Scheduler Users'||c_tab||
               c_nullclass||c_tab||
               c_nullclass||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               '0'||c_tab||
               to_char(v_NeverReg)||c_lf;
            v_stats := v_stats||v_stats_text;
         end if;
      end loop;
--
      RETURN v_stats;
--
--   EXCEPTION
--
--
   END f_get_stats;
--
PROCEDURE p_job_stats
--
-- p_job_stats calls f_get_stats to generate College Scheduler statistincs and
-- saves the output in the CSCHED_SERVICES table.  p_job_stats is executed
-- asynchronously as a dbms_scheduler job by p_job_queue.
--
   IS
--
      v_settings                       csched_settings%rowtype;
      v_stats                          clob := empty_clob();
      v_stats_coded                    clob := empty_clob();
      v_RequestedDate                  timestamp;
--
      c_system                CONSTANT varchar2(255)  := 'P_JOB_STATS';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
   BEGIN
--
      v_RequestedDate := systimestamp;
      v_settings      := f_settings;
--
      dbms_lob.createtemporary(v_stats,
                               TRUE);
      dbms_lob.append(v_stats,
                      f_get_stats);
--
      dbms_lob.createtemporary(v_stats_coded,
                               TRUE);
--
      dbms_lob.append(v_stats_coded,
                      f_compress_b64(v_stats,
                                     v_settings.schedule_format,
                                     v_settings.negotiated_key));
--
      dbms_lob.freetemporary(v_stats);
--
      insert into csched_services
                (job_type,
                 job_name,
                 requested_date,
                 fulfilled_date,
                 payload)
         values (c_outbound,
                 c_stats_job,
                 v_RequestedDate,
                 systimestamp,
                 v_stats_coded);
--
      dbms_lob.freetemporary(v_stats_coded);
--
      COMMIT;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_stats) = 1
         then dbms_lob.freetemporary(v_stats);
         end if;
--
         if dbms_lob.istemporary(v_stats_coded) = 1
         then dbms_lob.freetemporary(v_stats_coded);
         end if;
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         insert into csched_services
                   (job_type,
                    job_name,
                    requested_date,
                    fulfilled_date,
                    payload)
            values (c_outbound,
                    c_stats_job,
                    v_RequestedDate,
                    systimestamp,
                    to_clob(c_job_error_tag||c_lf||
                            c_stats_job||c_lf||
                            v_sqlerrm||c_lf||
                            v_backtrace));
         COMMIT;
--
   END p_job_stats;
--
FUNCTION f_schedule_file                                 -- ***** AUTONOMOUS TRANSACTION *****
   RETURN clob
--
-- f_schedule_file generates Schedule data as a formatted XML extract for
-- FTP or other alternative delivery methods.
--
   IS
--
      PRAGMA AUTONOMOUS_TRANSACTION;
--
      v_schedule_xml  xmltype;
--
      v_settings                  csched_settings%rowtype;
      v_rdy_job_name              varchar2(30);
      v_rdy_requested_date        timestamp;
      v_rdy_fulfilled_date        timestamp;
      v_rdy_job_output            clob := empty_clob();
--
      cursor c_one_job is
         select job_name,
                requested_date,
                fulfilled_date,
                payload
           from csched_services a
          where fulfilled_date = (select max(fulfilled_date)
                                    from csched_services
                                   where job_name = a.job_name)
          order by requested_date;
--
   BEGIN
--
      v_settings      := f_settings;
-- Generate schedule data
      p_job_schedule;
-- Fetch schedule data from temp table
      open c_one_job;
      fetch c_one_job into v_rdy_job_name,
                           v_rdy_requested_date,
                           v_rdy_fulfilled_date,
                           v_rdy_job_output;
      close c_one_job;
-- Delete
      delete csched_services
       where job_name = v_rdy_job_name;
      COMMIT;
-- Generate XML
      select xmlelement("FTP",
             xmlelement("FileLocation",'FTP'),
             xmlelement("Version",curr_release),
             xmlelement("Instance",c_instance),
             xmlelement("Jobs",
                xmlelement("Job",
                   xmlelement("Name",v_rdy_job_name),
                   xmlelement("Requested",to_char(v_rdy_requested_date,c_time_format)),
                   xmlelement("Fulfilled",to_char(v_rdy_fulfilled_date,c_time_format)),
                   xmlelement("Length",to_char(dbms_lob.getlength(v_rdy_job_output))),
                   xmlelement("Compressed",
                              decode(v_settings.schedule_format,
                                     2,c_yes,3,c_yes,c_no)),
                   xmlelement("Encrypted",
                              decode(v_settings.schedule_format,
                                     3,c_yes,c_no)),
                   xmlelement("Data",
                      xmlcdata(v_rdy_job_output)))))
        into v_schedule_xml
        from dual;
--
      RETURN v_schedule_xml.getclobval;
--
--   EXCEPTION
--
--
   END f_schedule_file;
--
FUNCTION f_get_rescap(p_term_code  varchar2)
   RETURN clob
--
-- f_get_rescap accepts a Term Code and returns the Reserve Capacity report,
-- tab delimited, as a Character Large Object (CLOB).
--
   IS
--
      v_rescap_row                clob := empty_clob();
      v_rescap                    clob := empty_clob();
--
      type t_rescap_row           is record (TermCode                varchar2(6),
                                             Term                    varchar2(30),
                                             CRN                     varchar2(5),
                                             Sequence                number(4),
                                             Timestamp               varchar2(26),
                                             SeatCapacity            number(4,0),
                                             SeatsFilled             number(4,0),
                                             SeatsOpen               number(4,0),
                                             WaitlistCapacity        number(4,0),
                                             WaitlistFilled          number(4,0),
                                             WaitlistOpen            number(4,0),
                                             Overflow                varchar2(1),
                                             LevelCode               varchar2(2),
                                             Level                   varchar2(30),
                                             MajorCode               varchar2(4),
                                             Major                   varchar2(30),
                                             ClassCode               varchar2(2),
                                             Class                   varchar2(30),
                                             CampusCode              varchar2(3),
                                             Campus                  varchar2(30),
                                             CollegeCode             varchar2(2),
                                             College                 varchar2(30),
                                             DegreeCode              varchar2(6),
                                             Degree                  varchar2(30),
                                             ProgramCode             varchar2(12),
                                             Program                 varchar2(30),
                                             LFSTypeCode             varchar2(15),
                                             LFSType                 varchar2(30),
                                             DepartmentCode          varchar2(4),
                                             Department              varchar2(30),
                                             PrimaryCode             varchar2(1),
                                             Primary                 varchar2(30),
                                             AdmitTermCode           varchar2(6),
                                             AdmitTerm               varchar2(30),
                                             MatricTermCode          varchar2(6),
                                             MatricTerm              varchar2(30),
                                             AttributeCode           varchar2(4),
                                             Attribute               varchar2(30),
                                             CohortCode              varchar2(10),
                                             Cohort                  varchar2(30),
                                             GradTermCode            varchar2(6),
                                             GradTerm                varchar2(30),
                                             Precedence              number(9),
                                             Weight                  number(9));
--
      type t_rescap_tab           is table of t_rescap_row
                                     index by binary_integer;
      v_rescap_tab                t_rescap_tab;
--
      cursor c_rescap (p_term_code  varchar2) is
         select ssrresv_term_code                                              TermCode,
                (select f_clean(stvterm_desc)
                   from stvterm
                  where stvterm_code = ssrresv_term_code)                      Term,
                ssrresv_crn                                                    CRN,
                ssrresv_seq_no                                                 Sequence,
                to_char(systimestamp,
                        c_time_format)                                         Timestamp,
                ssrresv_max_enrl                                               SeatCapacity,
                ssrresv_enrl                                                   SeatsFilled,
                ssrresv_seats_avail                                            SeatsOpen,
                ssrresv_wait_capacity                                          WaitlistCapacity,
                ssrresv_wait_count                                             WaitlistFilled,
                ssrresv_wait_avail                                             WaitlistOpen,
                ssrresv_overflow_ind                                           Overflow,
                ssrresv_levl_code                                              LevelCode,
                (select f_clean(stvlevl_desc)
                   from stvlevl
                  where stvlevl_code = ssrresv_levl_code)                      "Level",
                ssrresv_majr_code                                              MajorCode,
                (select f_clean(stvmajr_desc)
                   from stvmajr
                  where stvmajr_code = ssrresv_majr_code)                      Major,
                ssrresv_clas_code                                              ClassCode,
                (select f_clean(stvclas_desc)
                   from stvclas
                  where stvclas_code = ssrresv_clas_code)                      Class,
                ssrresv_camp_code                                              CampusCode,
                (select f_clean(stvcamp_desc)
                   from stvcamp
                  where stvcamp_code = ssrresv_camp_code)                      Campus,
                ssrresv_coll_code                                              CollegeCode,
                (select f_clean(stvcoll_desc)
                   from stvcoll
                  where stvcoll_code = ssrresv_coll_code)                      College,
                ssrresv_degc_code                                              DegreeCode,
                (select f_clean(stvdegc_desc)
                   from stvdegc
                  where stvdegc_code = ssrresv_degc_code)                      Degree,
                ssrresv_program                                                ProgramCode,
                (select smrprle_program_desc
                   from smrprle
                  where smrprle_program = ssrresv_program)                     Program,
                ssrresv_lfst_code                                              LFSTypeCode,
                (select f_clean(gtvlfst_desc)
                   from gtvlfst
                  where gtvlfst_code = ssrresv_lfst_code)                      LFSType,
                ssrresv_dept_code                                              DepartmentCode,
                (select f_clean(stvdept_desc)
                   from stvdept
                  where stvdept_code = ssrresv_dept_code)                      Department,
                ssrresv_prim_sec_cde                                           PrimaryCode,
                decode(ssrresv_prim_sec_cde,'P','Primary',
                                            'S','Secondary',
                                            'A','All',
                                            null)                              Primary,
                ssrresv_term_code_admit                                        AdmitTermCode,
                (select f_clean(stvterm_desc)
                   from stvterm
                  where stvterm_code = ssrresv_term_code_admit)                AdmitTerm,
                ssrresv_term_code_matric                                       MatricTermCode,
                (select f_clean(stvterm_desc)
                   from stvterm
                  where stvterm_code = ssrresv_term_code_matric)               MatricTerm,
                ssrresv_atts_code                                              AttributeCode,
                (select f_clean(stvatts_desc)
                   from stvatts
                  where stvatts_code = ssrresv_atts_code)                      Attribute,
                ssrresv_chrt_code                                              CohortCode,
                (select f_clean(stvchrt_desc)
                   from stvchrt
                  where stvchrt_code = ssrresv_chrt_code)                      Cohort,
                ssrresv_term_code_grad                                         GradTermCode,
                (select f_clean(stvterm_desc)
                   from stvterm
                  where stvterm_code = ssrresv_term_code_grad)                 GradTerm,
                (decode(ssrresv_levl_code,null,0,1)+
                 decode(ssrresv_camp_code,null,0,1)+
                 decode(ssrresv_coll_code,null,0,1)+
                 decode(ssrresv_degc_code,null,0,1)+
                 decode(ssrresv_program,null,0,1)+
                 decode(ssrresv_lfst_code,null,
                 decode(ssrresv_majr_code,null,0,1),1)+
                 decode(ssrresv_majr_code,null,0,1)+
                 decode(ssrresv_dept_code,null,0,1)+
                 decode(ssrresv_clas_code,null,0,1)+
                 decode(ssrresv_atts_code,null,0,1)+
                 decode(ssrresv_chrt_code,null,0,1)+
                 decode(ssrresv_term_code_admit,null,0,1)+
                 decode(ssrresv_term_code_matric,null,0,1)+
                 decode(ssrresv_term_code_grad,null,0,1))                      Precedence,
                (decode(ssrresv_levl_code,null,0,16384)+
                 decode(ssrresv_camp_code,null,0,8192)+
                 decode(ssrresv_coll_code,null,0,4096)+
                 decode(ssrresv_degc_code,null,0,2048)+
                 decode(ssrresv_program,null,0,1024)+
                 decode(ssrresv_lfst_code,null,
                 decode(ssrresv_majr_code,null,0,512),512)+
                 decode(ssrresv_majr_code,null,0,256)+
                 decode(ssrresv_dept_code,null,0,128)+
                 decode(ssrresv_clas_code,null,0,64)+
                 decode(ssrresv_atts_code,null,0,32)+
                 decode(ssrresv_chrt_code,null,0,16)+
                 decode(ssrresv_term_code_admit,null,0,8)+
                 decode(ssrresv_term_code_matric,null,0,4)+
                 decode(ssrresv_term_code_grad,null,0,2))                      Weight
           from ssrresv
          where ssrresv_term_code = p_term_code
          order by TermCode,
                   CRN,
                   Precedence                                            desc,
                   Weight                                                desc,
                   decode(ssrresv_prim_sec_cde,null,2,'A',2,'P',1,'S',0) desc;
--
   BEGIN
-- Fetch SSRRESV Data
      open  c_rescap(p_term_code);
      fetch c_rescap BULK COLLECT into v_rescap_tab;
      close c_rescap;
-- Verify Section Count
      if v_rescap_tab.count <> 0
      then
         -- Prepare CLOB
         dbms_lob.createtemporary(v_rescap,
                                  TRUE);
         -- Build CLOB
         for i in v_rescap_tab.first..v_rescap_tab.last
         loop
            v_rescap_row :=
               v_rescap_tab(i).TermCode||c_tab||
               v_rescap_tab(i).Term||c_tab||
               v_rescap_tab(i).CRN||c_tab||
               to_char(v_rescap_tab(i).Sequence)||c_tab||
               v_rescap_tab(i).Timestamp||c_tab||
               to_char(v_rescap_tab(i).SeatCapacity)||c_tab||
               to_char(v_rescap_tab(i).SeatsFilled)||c_tab||
               to_char(v_rescap_tab(i).SeatsOpen)||c_tab||
               to_char(v_rescap_tab(i).WaitlistCapacity)||c_tab||
               to_char(v_rescap_tab(i).WaitlistFilled)||c_tab||
               to_char(v_rescap_tab(i).WaitlistOpen)||c_tab||
               v_rescap_tab(i).Overflow||c_tab||
               v_rescap_tab(i).LevelCode||c_tab||
               v_rescap_tab(i).Level||c_tab||
               v_rescap_tab(i).MajorCode||c_tab||
               v_rescap_tab(i).Major||c_tab||
               v_rescap_tab(i).ClassCode||c_tab||
               v_rescap_tab(i).Class||c_tab||
               v_rescap_tab(i).CampusCode||c_tab||
               v_rescap_tab(i).Campus||c_tab||
               v_rescap_tab(i).CollegeCode||c_tab||
               v_rescap_tab(i).College||c_tab||
               v_rescap_tab(i).DegreeCode||c_tab||
               v_rescap_tab(i).Degree||c_tab||
               v_rescap_tab(i).ProgramCode||c_tab||
               v_rescap_tab(i).Program||c_tab||
               v_rescap_tab(i).LFSTypeCode||c_tab||
               v_rescap_tab(i).LFSType||c_tab||
               v_rescap_tab(i).DepartmentCode||c_tab||
               v_rescap_tab(i).Department||c_tab||
               v_rescap_tab(i).PrimaryCode||c_tab||
               v_rescap_tab(i).Primary||c_tab||
               v_rescap_tab(i).AdmitTermCode||c_tab||
               v_rescap_tab(i).AdmitTerm||c_tab||
               v_rescap_tab(i).MatricTermCode||c_tab||
               v_rescap_tab(i).MatricTerm||c_tab||
               v_rescap_tab(i).AttributeCode||c_tab||
               v_rescap_tab(i).Attribute||c_tab||
               v_rescap_tab(i).CohortCode||c_tab||
               v_rescap_tab(i).Cohort||c_tab||
               v_rescap_tab(i).GradTermCode||c_tab||
               v_rescap_tab(i).GradTerm||c_tab||
               to_char(v_rescap_tab(i).Precedence)||c_tab||
               to_char(v_rescap_tab(i).Weight)||c_lf;
            dbms_lob.append(v_rescap,v_rescap_row);
         end loop;
--
      end if;
--
      RETURN v_rescap;
--
--   EXCEPTION
--
--
   END f_get_rescap;
--
PROCEDURE p_job_rescap
--
-- p_job_rescap calls f_get_rescap to generate Reserve Capacity data for
-- current College Scheduler terms and saves the output in the
-- CSCHED_SERVICES table.  p_job_rescap is executed asynchronously as a
-- dbms_scheduler job by p_job_queue.
--
   IS
--
      v_settings                       csched_settings%rowtype;
      v_terms_tab                      t_terms_tab;
      v_rescap                         clob := empty_clob();
      v_rescap_coded                   clob := empty_clob();
      v_RequestedDate                  timestamp;
--
      c_system                CONSTANT varchar2(255)  := 'P_JOB_RESCAP';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
      c_rescap_header         CONSTANT varchar2(32767) :=
         '[TermCode]'||c_tab||
         '[Term]'||c_tab||
         '[CRN]'||c_tab||
         '[Sequence]'||c_tab||
         '[Timestamp]'||c_tab||
         '[SeatCapacity]'||c_tab||
         '[SeatsFilled]'||c_tab||
         '[SeatsOpen]'||c_tab||
         '[WaitlistCapacity]'||c_tab||
         '[WaitlistFilled]'||c_tab||
         '[WaitlistOpen]'||c_tab||
         '[Overflow]'||c_tab||
         '[LevelCode]'||c_tab||
         '[Level]'||c_tab||
         '[MajorCode]'||c_tab||
         '[Major]'||c_tab||
         '[ClassCode]'||c_tab||
         '[Class]'||c_tab||
         '[CampusCode]'||c_tab||
         '[Campus]'||c_tab||
         '[CollegeCode]'||c_tab||
         '[College]'||c_tab||
         '[DegreeCode]'||c_tab||
         '[Degree]'||c_tab||
         '[ProgramCode]'||c_tab||
         '[Program]'||c_tab||
         '[LFSTypeCode]'||c_tab||
         '[LFSType]'||c_tab||
         '[DepartmentCode]'||c_tab||
         '[Department]'||c_tab||
         '[PrimaryCode]'||c_tab||
         '[Primary]'||c_tab||
         '[AdmitTermCode]'||c_tab||
         '[AdmitTerm]'||c_tab||
         '[MatricTermCode]'||c_tab||
         '[MatricTerm]'||c_tab||
         '[AttributeCode]'||c_tab||
         '[Attribute]'||c_tab||
         '[CohortCode]'||c_tab||
         '[Cohort]'||c_tab||
         '[GradTermCode]'||c_tab||
         '[GradTerm]'||c_tab||
         '[Precedence]'||c_tab||
         '[Weight]'||c_lf;
--
   BEGIN
--
      v_RequestedDate := systimestamp;
      v_settings      := f_settings;
--
      select *
        BULK COLLECT
        into v_terms_tab
        from csched_terms
       where active_ind = c_yes
       order by term_code;
--
       if v_terms_tab.count = 0
       then RAISE_APPLICATION_ERROR(-20014,
                                    'Zero Active Terms (CSCHED_TERMS)');
       end if;
--
      dbms_lob.createtemporary(v_rescap,
                               TRUE);
      dbms_lob.writeappend(v_rescap,
                           length(c_rescap_header),
                           to_clob(c_rescap_header));
--
      for i in v_terms_tab.first..v_terms_tab.last
      loop
         dbms_lob.append(v_rescap,
                         f_get_rescap(v_terms_tab(i).term_code));
      end loop;
--
      dbms_lob.createtemporary(v_rescap_coded,
                               TRUE);
--
      dbms_lob.append(v_rescap_coded,
                      f_compress_b64(v_rescap,
                                     v_settings.schedule_format,
                                     v_settings.negotiated_key));
--
      dbms_lob.freetemporary(v_rescap);
--
      insert into csched_services
                (job_type,
                 job_name,
                 requested_date,
                 fulfilled_date,
                 payload)
         values (c_outbound,
                 c_rescap_job,
                 v_RequestedDate,
                 systimestamp,
                 v_rescap_coded);
--
      dbms_lob.freetemporary(v_rescap_coded);
--
      COMMIT;
--
   EXCEPTION
--
      when OTHERS then
--
         if dbms_lob.istemporary(v_rescap) = 1
         then dbms_lob.freetemporary(v_rescap);
         end if;
--
         if dbms_lob.istemporary(v_rescap_coded) = 1
         then dbms_lob.freetemporary(v_rescap_coded);
         end if;
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         insert into csched_services
                   (job_type,
                    job_name,
                    requested_date,
                    fulfilled_date,
                    payload)
            values (c_outbound,
                    c_rescap_job,
                    v_RequestedDate,
                    systimestamp,
                    to_clob(c_job_error_tag||c_lf||
                            c_rescap_job||c_lf||
                            v_sqlerrm||c_lf||
                            v_backtrace));
         COMMIT;
--
   END p_job_rescap;
--
PROCEDURE p_parse_studentdemandreport(p_studentdemandreport  clob)
--
-- p_parse_student_demand_report parses and saves Course and User data delivered
-- from College Scheduler as the incremental XML StudentDemandReport.
--
   IS
--
      v_report_xml         xmltype;
      type t_student_tab   is table of varchar2(255)
                              index by binary_integer;
      v_student_tab        t_student_tab;
      -- csched_user_login
      type t_login_row     is record (pidm                number(8),
                                      studentid           varchar2(255),
                                      loggedin            varchar2(255),
                                      activity_date       date,
                                      advisorid           varchar2(255),
                                      transactiontype     varchar2(255));
      type t_login_tab     is table of t_login_row
                              index by binary_integer;
      v_login_tab          t_login_tab;
      -- csched_breaks
      type t_break_row     is record (pidm                number(8),
                                      studentid           varchar2(255),
                                      breakname           varchar2(255),
                                      days                varchar2(255),
                                      starttime           varchar2(255),
                                      endtime             varchar2(255),
                                      activity_date       date);
      type t_break_tab     is table of t_break_row
                              index by binary_integer;
      v_break_tab          t_break_tab;
      -- csched_course_demand
      type t_course_row    is record (pidm                number(8),
                                      term                varchar2(255),
                                      termcode            varchar2(255),
                                      subject             varchar2(255),
                                      coursenumber        varchar2(255),
                                      studentid           varchar2(255),
                                      datemodified        varchar2(255),
                                      activity_date       date);
      type t_course_tab    is table of t_course_row
                              index by binary_integer;
      v_course_tab         t_course_tab;
      -- csched_section_demand
      type t_lock_row      is record (pidm                number(8),
                                      term                varchar2(255),
                                      termcode            varchar2(255),
                                      registrationnumber  varchar2(255),
                                      studentid           varchar2(255),
                                      activity_date       date);
      type t_lock_tab      is table of t_lock_row
                               index by binary_integer;
      v_lock_tab           t_lock_tab;
      -- csched_section_excluded
      type t_filtered_row  is record (pidm                number(8),
                                      term                varchar2(255),
                                      termcode            varchar2(255),
                                      registrationnumber  varchar2(255),
                                      studentid           varchar2(255),
                                      activity_date       date);
      type t_filtered_tab  is table of t_filtered_row
                              index by binary_integer;
      v_filtered_tab       t_filtered_tab;
--
   BEGIN
--
      v_report_xml := xmltype(p_studentdemandreport);
      -- Students
      select x_id                               -- studentid
        BULK COLLECT
        into v_student_tab
        from xmltable('StudentDemandReport/Students/Student'
                      passing v_report_xml
                      columns
                         x_id                   varchar2(255) path 'Id');
      -- Logins - csched_user_login
      select (select spriden_pidm
                from spriden
               where spriden_id =  a.x_id
                 and rownum     =  1),          -- pidm
             a.x_id,                            -- studentid
             b.x_login,                         -- loggedin
             sysdate,                           -- activity_date
             b.x_advisorid,                     -- advisorid
             b.x_transactiontype                -- transactiontype
        BULK COLLECT
        into v_login_tab
        from xmltable('StudentDemandReport/Students/Student'
                      passing v_report_xml
                      columns
                         x_id                   varchar2(255) path 'Id',
                         x_logins_xml           xmltype       path 'Logins') a,
             xmltable('Logins/Login'
                      passing a.x_logins_xml
                      columns
                         x_login                varchar2(255) path 'AccessedAt',
                         x_advisorid            varchar2(255) path 'AdvisorId',
                         x_transactiontype      varchar2(255) path 'TransactionType') b;
      -- Breaks - csched_breaks
      select (select spriden_pidm
                from spriden
               where spriden_id =  a.x_id
                 and rownum     =  1),          -- pidm
             a.x_id,                            -- studentid
             b.x_name,                          -- breakname
             b.x_days,                          -- days
             b.x_timestart,                     -- starttime
             b.x_timeend,                       -- endtime
             sysdate                            -- activity_date
        BULK COLLECT
        into v_break_tab
        from xmltable('StudentDemandReport/Students/Student'
                      passing v_report_xml
                      columns
                         x_id                   varchar2(255) path 'Id',
                         x_breaks_xml           xmltype       path 'Breaks') a,
             xmltable('Breaks/Break'
                      passing a.x_breaks_xml
                      columns
                         x_name                 varchar2(255) path 'Name',
                         x_days                 varchar2(255) path 'Days',
                         x_timestart            varchar2(255) path 'TimeStart',
                         x_timeend              varchar2(255) path 'TimeEnd') b;
      -- Courses - csched_course_demand
      select (select spriden_pidm
                from spriden
               where spriden_id =  a.x_id
                 and rownum     =  1),          -- pidm
             b.x_term,                          -- term
             b.x_termcode,                      -- termcode
             b.x_subjectid,                     -- subject
             b.x_coursenumber,                  -- coursenumber
             a.x_id,                            -- studentid
             b.x_datemodified,                  -- datemodified
             sysdate                            -- activity_date
        BULK COLLECT
        into v_course_tab
        from xmltable('StudentDemandReport/Students/Student'
                      passing v_report_xml
                      columns
                         x_id                   varchar2(255) path 'Id',
                         x_courses_xml          xmltype       path 'Courses') a,
             xmltable('Courses/Course'
                      passing a.x_courses_xml
                      columns
                         x_term                 varchar2(255) path 'Term',
                         x_termcode             varchar2(255) path 'TermCode',
                         x_subjectid            varchar2(255) path 'SubjectId',
                         x_coursenumber         varchar2(255) path 'CourseNumber',
                         x_datemodified         varchar2(255) path 'DateModified') b;
      -- Locks - csched_section_demand
      select (select spriden_pidm
                from spriden
               where spriden_id =  a.x_id
                 and rownum     =  1),          -- pidm
             b.x_term,                          -- term
             b.x_termcode,                      -- termcode
             b.x_registrationnumber,            -- registrationnumber
             a.x_id,                            -- studentid
             sysdate                            -- activity_date
        BULK COLLECT
        into v_lock_tab
        from xmltable('StudentDemandReport/Students/Student'
                      passing v_report_xml
                      columns
                         x_id                   varchar2(255) path 'Id',
                         x_locks_xml            xmltype       path 'Locks') a,
             xmltable('Locks/Lock'
                      passing a.x_locks_xml
                      columns
                         x_term                 varchar2(255) path 'Term',
                         x_termcode             varchar2(255) path 'TermCode',
                         x_registrationnumber   varchar2(255) path 'RegistrationNumber') b;
      -- FilteredSections - csched_section_excluded
      select (select spriden_pidm
                from spriden
               where spriden_id =  a.x_id
                 and rownum     =  1),          -- pidm
             b.x_term,                          -- term
             b.x_termcode,                      -- termcode
             b.x_registrationnumber,            -- registrationnumber
             a.x_id,                            -- studentid
             sysdate                            -- activity_date
        BULK COLLECT
        into v_filtered_tab
        from xmltable('StudentDemandReport/Students/Student'
                      passing v_report_xml
                      columns
                         x_id                   varchar2(255) path 'Id',
                         x_filtered_xml         xmltype       path 'FilteredSections') a,
             xmltable('FilteredSections/FilteredSection'
                      passing a.x_filtered_xml
                      columns
                         x_term                 varchar2(255) path 'Term',
                         x_termcode             varchar2(255) path 'TermCode',
                         x_registrationnumber   varchar2(255) path 'RegistrationNumber') b;
      -- Delete old records
      FORALL i in v_student_tab.first..v_student_tab.last
         delete from csched_user_login
          where studentid = v_student_tab(i);
      FORALL i in v_student_tab.first..v_student_tab.last
         delete from csched_breaks
          where studentid = v_student_tab(i);
      FORALL i in v_student_tab.first..v_student_tab.last
         delete from csched_course_demand
          where studentid = v_student_tab(i);
      FORALL i in v_student_tab.first..v_student_tab.last
         delete from csched_section_demand
          where studentid = v_student_tab(i);
      FORALL i in v_student_tab.first..v_student_tab.last
         delete from csched_section_excluded
          where studentid = v_student_tab(i);
      -- Insert new records
      FORALL i in v_login_tab.first..v_login_tab.last
         insert into csched_user_login
                   (pidm,
                    studentid,
                    loggedin,
                    activity_date,
                    advisorid,
                    transactiontype)
            values (v_login_tab(i).pidm,
                    v_login_tab(i).studentid,
                    v_login_tab(i).loggedin,
                    v_login_tab(i).activity_date,
                    v_login_tab(i).advisorid,
                    v_login_tab(i).transactiontype);
      FORALL i in v_break_tab.first..v_break_tab.last
         insert into csched_breaks
                   (pidm,
                    studentid,
                    breakname,
                    days,
                    starttime,
                    endtime,
                    activity_date)
            values (v_break_tab(i).pidm,
                    v_break_tab(i).studentid,
                    v_break_tab(i).breakname,
                    v_break_tab(i).days,
                    v_break_tab(i).starttime,
                    v_break_tab(i).endtime,
                    v_break_tab(i).activity_date);
      FORALL i in v_course_tab.first..v_course_tab.last
         insert into csched_course_demand
                   (pidm,
                    term,
                    termcode,
                    subject,
                    coursenumber,
                    studentid,
                    datemodified,
                    activity_date)
            values (v_course_tab(i).pidm,
                    v_course_tab(i).term,
                    v_course_tab(i).termcode,
                    v_course_tab(i).subject,
                    v_course_tab(i).coursenumber,
                    v_course_tab(i).studentid,
                    v_course_tab(i).datemodified,
                    v_course_tab(i).activity_date);
      FORALL i in v_lock_tab.first..v_lock_tab.last
         insert into csched_section_demand
                   (pidm,
                    term,
                    termcode,
                    registrationnumber,
                    studentid,
                    activity_date)
            values (v_lock_tab(i).pidm,
                    v_lock_tab(i).term,
                    v_lock_tab(i).termcode,
                    v_lock_tab(i).registrationnumber,
                    v_lock_tab(i).studentid,
                    v_lock_tab(i).activity_date);
      FORALL i in v_filtered_tab.first..v_filtered_tab.last
         insert into csched_section_excluded
                   (pidm,
                    term,
                    termcode,
                    registrationnumber,
                    studentid,
                    activity_date)
            values (v_filtered_tab(i).pidm,
                    v_filtered_tab(i).term,
                    v_filtered_tab(i).termcode,
                    v_filtered_tab(i).registrationnumber,
                    v_filtered_tab(i).studentid,
                    v_filtered_tab(i).activity_date);
      --
      COMMIT;
--
--   EXCEPTION
--
--
   END p_parse_studentdemandreport;
--
PROCEDURE p_parse_report(p_job_name        varchar2)
--
-- p_parse_report parses and saves Course Demand and User data delivered from
-- College Scheduler.
--
   IS
--
      v_settings                       csched_settings%rowtype;
      v_compressed_ind                 varchar2(1);
      v_encrypted_ind                  varchar2(1);
      v_encryption_iv                  raw(32);
      v_report_raw                     clob;
      v_report                         clob;
      v_report_length                  integer;
      v_format                         number(1);
      v_rowtext                        varchar2(32767);
      v_rowoffset                      integer;
      v_rowend                         integer;
      v_rowcount                       integer;
      type t_columntext                is table of varchar2(255)
                                          index by binary_integer;
      v_columntext                     t_columntext;
      v_columnoffset                   integer;
      v_columnend                      integer;
      v_columncount                    integer;
--
      c_system                CONSTANT varchar2(255)  := 'P_PARSE_REPORT';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
   BEGIN
--
      v_settings := f_settings;
-- fetch report payload
      select compressed_ind,
             encrypted_ind,
             encryption_iv,
             payload
        into v_compressed_ind,
             v_encrypted_ind,
             v_encryption_iv,
             v_report_raw
        from csched_services a
       where job_type       =  c_inbound
         and job_name       =  p_job_name
         and requested_date =  (select max(requested_date)
                                  from csched_services
                                 where job_type = a.job_type
                                   and job_name = a.job_name);
-- Verify format
      case v_compressed_ind||v_encrypted_ind
      when c_no||c_no then
         v_format := 1;
      when c_yes||c_no then
         v_format := 2;
      when c_yes||c_yes then
         v_format := 3;
      else
         RAISE_APPLICATION_ERROR(-20032,
                                 'Unrecognized compression-encryption format');
      end case;
-- Decode report payload
      v_report := f_decompress_b64(v_report_raw,
                                   v_format,
                                   v_settings.negotiated_key,
                                   v_encryption_iv);
      v_report_length := dbms_lob.getlength(v_report);
--
      if p_job_name in (c_student_demand_report)
      then -- Incremental Reports
         --
         case
         --
         when p_job_name = c_student_demand_report then
            p_parse_studentdemandreport(v_report);
         --
         end case;
         --
      else -- Bulk Reports
         -- Delete previous data
         case
         --
         when p_job_name = c_breaks_report then
            delete csched_breaks;
         --
         when p_job_name = c_course_demand_report then
            delete csched_course_demand;
         --
         when p_job_name = c_section_excluded_report then
            delete csched_section_excluded;
         --
         when p_job_name = c_section_demand_report then
            delete csched_section_demand;
         --
         when p_job_name = c_user_login_report then
            delete csched_user_login;
         --
         end case;
         --
         v_rowcount := 1;
         -- Parse report payload
         loop
            -- Clear previous row
            v_columntext.delete;
            -- Parse rows
            v_rowoffset  := dbms_lob.instr(v_report,c_lf,1,v_rowcount);
            exit when nvl(v_rowoffset,0) = 0;
            v_rowend := dbms_lob.instr(v_report,c_lf,1,v_rowcount+1);
            if  v_rowend = 0
            then
               if v_rowoffset + 1 <= v_report_length
               then
                  v_rowend := v_report_length;
               else
                  exit;
               end if;
            end if;
            v_rowtext := dbms_lob.substr(v_report,
                                         v_rowend - v_rowoffset - 2,
                                         v_rowoffset + 1);
            -- Parse columns
            v_columnend := instr(v_rowtext,',',1,1);
            v_columntext(1) := substr(v_rowtext,1,v_columnend - 1);
            v_columncount := 2;
            loop
               v_columnoffset := instr(v_rowtext,',',1,v_columncount - 1);
               exit when nvl(v_columnoffset,0) = 0;
               v_columnend := instr(v_rowtext,',',1,v_columncount);
               if  v_columnend = 0
               then
                  if v_columnoffset + 1 <= v_rowend
                  then
                     v_columnend := v_rowend;
                  else
                     exit;
                  end if;
               end if;
               v_columntext(v_columncount) := substr(v_rowtext,
                                                     v_columnoffset + 1,
                                                     v_columnend - v_columnoffset - 1);
               v_columncount := v_columncount + 1;
            end loop;
            -- Insert rows
            case
            --
            when p_job_name = c_breaks_report then
               if v_columncount >= 5  -- Extra columns are ignored
               then
                  -- StudentID,BreakName,Days,StartTime,EndTime
                  insert into csched_breaks
                            (pidm,
                             studentid,
                             breakname,
                             days,
                             starttime,
                             endtime,
                             activity_date)
                     values (null,
                             v_columntext(1),
                             v_columntext(2),
                             v_columntext(3),
                             v_columntext(4),
                             v_columntext(5),
                             sysdate);
               else
                  RAISE_APPLICATION_ERROR(-20033,
                                          'Too few columns');
               end if;
            --
            when p_job_name = c_course_demand_report then
               if v_columncount >= 6  -- Extra columns are ignored
               then
                  -- Term,TermCode,Subject,CourseNumber,StudentID,DateModified
                  insert into csched_course_demand
                            (pidm,
                             term,
                             termcode,
                             subject,
                             coursenumber,
                             studentid,
                             datemodified,
                             activity_date)
                     values (null,
                             v_columntext(1),
                             v_columntext(2),
                             v_columntext(3),
                             v_columntext(4),
                             v_columntext(5),
                             v_columntext(6),
                             sysdate);
               else
                  RAISE_APPLICATION_ERROR(-20033,
                                          'Too few columns');
               end if;
            --
            when p_job_name = c_section_demand_report then
               if v_columncount >= 4  -- Extra columns are ignored
               then
                  -- Term,TermCode,RegistrationNumber,StudentID
                  insert into csched_section_demand
                            (pidm,
                             term,
                             termcode,
                             registrationnumber,
                             studentid,
                             activity_date)
                     values (null,
                             v_columntext(1),
                             v_columntext(2),
                             v_columntext(3),
                             v_columntext(4),
                             sysdate);
               else
                  RAISE_APPLICATION_ERROR(-20033,
                                          'Too few columns');
               end if;
            --
            when p_job_name = c_section_excluded_report then
               if v_columncount >= 4  -- Extra columns are ignored
               then
                  -- Term,TermCode,RegistrationNumber,StudentID
                  insert into csched_section_excluded
                            (pidm,
                             term,
                             termcode,
                             registrationnumber,
                             studentid,
                             activity_date)
                     values (null,
                             v_columntext(1),
                             v_columntext(2),
                             v_columntext(3),
                             v_columntext(4),
                             sysdate);
               else
                  RAISE_APPLICATION_ERROR(-20033,
                                          'Too few columns');
               end if;
            --
            when p_job_name = c_user_login_report then
               if v_columncount >= 2  -- Extra columns are ignored
               then
                  -- StudentID,LoggedIn
                  insert into csched_user_login
                            (pidm,
                             studentid,
                             loggedin,
                             activity_date)
                     values (null,
                             v_columntext(1),
                             v_columntext(2),
                             sysdate);
               else
                  RAISE_APPLICATION_ERROR(-20033,
                                          'Too few columns');
               end if;
            --
            end case;
            v_rowcount := v_rowcount + 1;
         end loop;
--
      end if;
--
      delete csched_services
       where job_type       =  c_inbound
         and job_name       =  p_job_name;
      COMMIT;
--
   EXCEPTION
--
      when OTHERS then
--
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr('Report: '||p_job_name||' '||c_lf||
                               dbms_utility.format_error_backtrace,1,4000);
--
         ROLLBACK;
--
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
         delete csched_services
          where job_type       =  c_inbound
            and job_name       =  p_job_name;
         COMMIT;
--
   END p_parse_report;
--
PROCEDURE p_job_queue
--
-- p_job_queue serially executes underlying jobs and reports ready for processing
-- in the CSCHED_SERVICES table.  p_job_queue is executed asynchronously as a
-- dbms_scheduler job.
--
   IS
-- Outbound Jobs
      cursor c_jobs is
         select job_name
           from csched_services
          where job_type       =  c_outbound
            and fulfilled_date is null
          group by job_name
          order by min(requested_date);
-- Inbound Reports
      cursor c_reports is
         select job_name
           from csched_services
          where job_type       =  c_inbound
            and fulfilled_date is null
          group by job_name
          order by max(requested_date);
--
      c_system                CONSTANT varchar2(255)  := 'P_JOB_QUEUE';
      v_sqlcode                        number;
      v_sqlerrm                        varchar2(4000);
      v_backtrace                      varchar2(4000);
--
   BEGIN
-- Outbound Jobs
      for jobs_rec in c_jobs
      loop
         case jobs_rec.job_name
         when c_schedule_job then
            p_job_schedule;
         when c_catalog_job then
            p_job_catalog;
         when c_termvalidation_job then
            p_job_termvalidation;
--         when c_prerequisites_job then
--            null;
         when c_rescap_job then
            p_job_rescap;
         when c_stats_job then
            p_job_stats;
         when c_logs_job then
            p_job_logs;
         end case;
      end loop;
-- Inbound Reports
      for reports_rec in c_reports
      loop
         p_parse_report(reports_rec.job_name);
      end loop;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
--
   END p_job_queue;
--
PROCEDURE p_soap_fault(p_faultcode          number,
                       p_faultstring        varchar2,
                       p_detail             varchar2,
                       p_receiveddate       timestamp default null,
                       p_servicerequest     number    default null,
                       p_soap_body          xmltype   default null)
--
-- Generates the SOAP Fault response message and posts Fault details to the
-- Fault Log table csched_fault.  Intended to be called by the
-- p_services exception handler.
--
   IS
--
      c_system    CONSTANT varchar2(255) := 'P_SERVICES';
      v_body               xmltype;
      v_soap_fault         clob := empty_clob();
      v_servicefault       number;  -- csched_fault_seq
      v_logged             varchar2(1) := c_yes;
--
   BEGIN
-- Fetch Fault Sequence
      select csched_fault_seq.nextval
        into v_servicefault
        from dual;
-- Insert log record
      begin
         p_record_fault(c_system,
                        p_faultcode,
                        p_faultstring,
                        p_detail,
                        p_receiveddate,
                        p_soap_body.getclobval);
      exception
         when OTHERS then
            ROLLBACK;  -- Allow SOAP Fault to be delivered even if the log
                       -- cannot be written.
            v_logged := c_no;
      end;
-- Generate v_body
      select xmlelement("Fault",
                xmlelement("Version",curr_release),
                xmlelement("Instance",c_instance),
                xmlelement("ReceivedDate",to_char(p_receiveddate,c_time_format)),
                xmlelement("ResponseDate",to_char(systimestamp,c_time_format)),
                xmlelement("ServiceRequest",to_char(p_servicerequest)),
                xmlelement("ServiceFault",to_char(v_servicefault)),
                xmlelement("LocalLog",decode(v_logged,c_yes,'Saved',
                                                      c_no,'NOT Saved')),
                xmlelement("SALT",utl_i18n.raw_to_char(
                                     utl_encode.base64_encode(
                                        dbms_crypto.randombytes(c_nonce_bytes)),
                                        c_charset)))
        into v_body
        from dual;
-- Generate SOAP fault
      v_soap_fault := c_soap_open||
                      v_body.getclobval||
                      '<Hash>'||f_hash(v_body.getclobval)||'</Hash>'||
                      '<soapenv:Fault>'||
                         '<soapenv:faultcode>'||p_faultcode||'</soapenv:faultcode>'||
                         '<soapenv:faultstring>'||p_faultstring||'</soapenv:faultstring>'||
                         '<soapenv:detail>'||p_detail||'</soapenv:detail>'||
                      '</soapenv:Fault>'||
                      c_soap_close;
-- Deliver SOAP fault
      owa_util.mime_header('text/xml', TRUE);
      htp.prn(v_soap_fault);
--
--   EXCEPTION
--
--
   END p_soap_fault;
--
PROCEDURE p_services(p_soap_body  varchar2 default null)        -- WEB PROCEDURE
--
-- p_services establishes a simple SOAP/XML messaging service within
-- Self Service Banner.  p_services responds to requests from College Scheduler
-- to communicate with Banner.
--
   IS
--
      v_soap_response             clob := empty_clob();
-- HTP.PRN Chunking
      c_chunk            CONSTANT number := 4096; -- 4 * 1024
--
      c_system           CONSTANT varchar2(255) := 'P_SERVICES';
      v_sqlcode                   number;
      v_sqlerrm                   varchar2(4000);
      v_backtrace                 varchar2(4000);
--
      v_settings                  csched_settings%rowtype;
      v_receiveddate              timestamp;
      v_responsedate              timestamp;
      v_servicerequest            number;  -- csched_request_seq
      v_soap_action               varchar2(2000);
      v_reset                     varchar2(2000);
      v_response_body             xmltype;
      v_request_soap_body         xmltype;
--
      v_deltarequest              xmltype;
      v_raw_deltarequest          xmltype;
      v_sendtostudentcart         xmltype;
      v_raw_sendtostudentcart     xmltype;
      v_reports                   xmltype;
      v_raw_reports               xmltype;
      v_request_hash              varchar2(2000);
      v_msg_count                 number(2) := 0;
--
      bad_soap_action             exception;  --  2
      bad_soap_body               exception;  --  3
      bad_hash_required           exception;  --  4
      bad_hash                    exception;  --  5
      bad_msg_count               exception;  --  6
      bad_job                     exception;  --  7
      bad_sendtostudentcart       exception;  --  8
      bad_student_id              exception;  --  9
      bad_term                    exception;  -- 10
      bad_groupid_required        exception;  -- 12
      bad_report                  exception;  -- 13
      bad_report_payload          exception;  -- 14
-- Jobs
      v_job_names                 t_job_names;
      v_report_names              t_job_names;
      v_report_payloads           t_report_payloads;
      v_compressed                xmltype;
      v_encrypted                 xmltype;
      v_service_count             number;
      v_queued                    varchar2(4000);
      v_rdy_job_name              varchar2(30);
      v_rdy_requested_date        timestamp;
      v_rdy_fulfilled_date        timestamp;
      v_rdy_job_payload           clob := empty_clob();
--
      cursor c_one_job is
         select job_name,
                requested_date,
                fulfilled_date,
                payload
           from csched_services a
          where job_type       =  c_outbound
            and fulfilled_date is NOT null
            and fulfilled_date =  (select max(fulfilled_date)
                                     from csched_services
                                    where job_name = a.job_name)
          order by requested_date;
-- SendToStudentCartResponse
      v_pidm                      number(8);
      v_term                      varchar2(2000);
      v_id_delivered              varchar2(2000);
      v_student_id                varchar2(2000);
      type t_crn_tab              is table of xmltype
                                     index by binary_integer;
      v_crn_tab                   t_crn_tab;
      type t_GroupID_tab          is table of xmltype
                                     index by binary_integer;
      v_GroupID_tab               t_GroupID_tab;
      v_crn_verify                varchar2(2000);
--
   BEGIN
--
      v_receiveddate := systimestamp;
      v_settings     := f_settings;
--
      select csched_request_seq.nextval
        into v_servicerequest
        from dual;
      v_soap_action   := coalesce(owa_util.get_cgi_env('HTTP_SOAPACTION'),
                                  owa_util.get_cgi_env('soapaction'));
--
      if p_soap_body is null
      then
         begin
            v_request_soap_body := xmltype(owa_util.get_cgi_env('SOAP_BODY'));
         exception
            when OTHERS then
               RAISE bad_soap_body;
         end;
      else
         v_request_soap_body := xmltype(p_soap_body);
      end if;
-- Validate initial conditions
      case
         when nvl(v_soap_action,'X') <> v_settings.soap_action
          and p_soap_body is null then
            RAISE bad_soap_action;
         when v_request_soap_body is null then
            RAISE bad_soap_body;
         else
            null;  -- Initial conditions are valid
      end case;
-- Validate incoming Hash
      begin
         v_request_hash      := v_request_soap_body.extract('//Hash/text()').getstringval;
         if v_request_hash is null
         then RAISE bad_hash_required;
         end if;
      exception
         when OTHERS then
            RAISE bad_hash_required;
      end;
-- Determine Service
      v_sendtostudentcart := v_request_soap_body.extract('//SendToStudentCart');
      v_deltarequest      := v_request_soap_body.extract('//DeltaRequest');
      v_reports           := v_request_soap_body.extract('//Reports');
-- Verify single request
      if v_sendtostudentcart is NOT null
      then v_msg_count := 1;
      end if;
      if v_deltarequest is NOT null
      then v_msg_count := v_msg_count + 1;
      end if;
      if v_reports is NOT null
      then v_msg_count := v_msg_count + 1;
      end if;
      if v_msg_count <> 1
      then RAISE bad_msg_count;
      end if;
-- Process Response
      case
-- SendToStudentCartResponse
      when v_sendtostudentcart is NOT null
      then
         select extract(column_value,'//SendToStudentCart')
           into v_raw_SendToStudentCart
           from table(xmlsequence(v_request_soap_body));
         -- Verify Hash
         if upper(v_request_hash) <>
            f_hash(v_raw_SendToStudentCart.getclobval)
         then RAISE bad_hash;
         end if;
         -- Parse SendToStudentCart tags
         declare
            i  pls_integer  :=  0;
         begin
            v_id_delivered := v_request_soap_body.extract('//StudentID/text()').getstringval;
            v_term         := v_request_soap_body.extract('//TermCode/text()').getstringval;
            loop
               i := i + 1;
               v_crn_tab(i)     := v_request_soap_body.extract('//Sections/Section['||i||']/CRN/text()');
               v_GroupID_tab(i) := v_request_soap_body.extract('//Sections/Section['||i||']/GroupID/text()');
               exit when v_crn_tab(i) is null;
            end loop;
         exception
            when OTHERS then
               RAISE bad_sendtostudentcart;
         end;
         -- Unobfuscate ID
         case v_settings.id_mode_ind
         when 'I' then
            begin
               select spriden_pidm,
                      spriden_id
                 into v_pidm,
                      v_student_id
                 from spriden
                where spriden_id = v_id_delivered
                  and rownum = 1;
            exception
               when NO_DATA_FOUND then
                  RAISE bad_student_id;
            end;
         when 'P' then
            begin
               select spriden_pidm,
                      spriden_id
                 into v_pidm,
                      v_student_id
                 from spriden
                where spriden_change_ind is null
                  and spriden_pidm = to_number(v_id_delivered);
            exception
               when OTHERS then
                  RAISE bad_student_id;
            end;
         when 'O' then
            v_student_id := f_decrypt_id_private(v_id_delivered,
                                                 v_settings.id_obfuscation_key);
            begin
               select spriden_pidm
                 into v_pidm
                 from spriden
                where spriden_id = v_student_id
                  and rownum = 1;
            exception
               when NO_DATA_FOUND then
                  RAISE bad_student_id;
            end;
         end case;
         -- Validate Term
         begin
            select stvterm_code
              into v_term
              from stvterm
             where stvterm_code = v_term;
         exception
            when NO_DATA_FOUND then
               RAISE bad_term;
         end;
         -- Process CRNs
         if v_crn_tab.count > 0
         then
            declare
               i  pls_integer  :=  0;
            begin
               loop
                  i := i + 1;
                  exit when v_crn_tab(i) is null;
                  -- Verify CRN
                  begin
                     select ssbsect_crn
                       into v_crn_verify
                       from ssbsect
                      where ssbsect_term_code = v_term
                        and ssbsect_crn       = v_crn_tab(i).getstringval;
                     insert into csched_regcart
                               (pidm,
                                term_code,
                                received_date,
                                crn,
                                active_ind,
                                student_id,
                                status,
                                detail,
                                activity_date,
                                groupid)
                        values (v_pidm,
                                v_term,
                                v_receiveddate,
                                v_crn_tab(i),
                                c_yes,
                                v_student_id,
                                'Added',
                                null,
                                systimestamp,
                                v_GroupID_tab(i).getstringval);
                  exception
                     when NO_DATA_FOUND then
                        insert into csched_regcart
                                  (pidm,
                                   term_code,
                                   received_date,
                                   crn,
                                   active_ind,
                                   student_id,
                                   status,
                                   detail,
                                   activity_date,
                                   groupid)
                           values (v_pidm,
                                   v_term,
                                   v_receiveddate,
                                   v_crn_tab(i).getstringval,
                                   c_no,
                                   v_student_id,
                                   'Error',
                                   'Invalid CRN',
                                   systimestamp,
                                   v_GroupID_tab(i).getstringval);
                  end;
               end loop;
            end;
         end if;
         -- Inactivate old records for this ID
         update csched_regcart
            set active_ind = c_no,
                activity_date = systimestamp
          where pidm = v_pidm
            and term_code = v_term
            and received_date <> v_receiveddate;
         -- Commit regcart records
         COMMIT;
         -- Build SendToStudentCartResponse
         select xmlelement("SendToStudentCartResponse",
                   xmlelement("Version",curr_release),
                   xmlelement("Instance",c_instance),
                   xmlelement("ReceivedDate",to_char(v_receiveddate,c_time_format)),
                   xmlelement("ResponseDate",to_char(systimestamp,c_time_format)),
                   xmlelement("ServiceRequest",to_char(v_servicerequest)),
                   xmlelement("StudentID",v_student_id),
                   xmlelement("TermCode",v_term),
                   xmlelement("Sections",
                      (select xmlagg(xmlelement("Section",
                                 xmlelement("CRN",crn),
                                 xmlelement("Status",status),
                                 xmlelement("Detail",detail),
                                 xmlelement("GroupID",groupid))
                                 order by groupid,
                                          crn)
                         from csched_regcart
                        where pidm = v_pidm
                          and term_code = v_term
                          and received_date = v_receiveddate)),
                   xmlelement("SALT",utl_i18n.raw_to_char(
                                        utl_encode.base64_encode(
                                           dbms_crypto.randombytes(c_nonce_bytes)),
                                           c_charset)))
           into v_response_body
           from dual;
-- DeltaResponse
      when v_deltarequest is NOT null
      then
         select extract(column_value,'//DeltaRequest')
           into v_raw_deltarequest
           from table(xmlsequence(v_request_soap_body));
         -- Verify Hash
         if upper(v_request_hash) <>
            f_hash(v_raw_deltarequest.getclobval)
         then RAISE bad_hash;
         end if;
         -- Check for Reset tag
         if  v_raw_deltarequest.extract('//Reset/text()') is NOT null
         then
            v_reset := v_raw_deltarequest.extract(
                          '//Reset/text()').getstringval;
         end if;
         -- Check for Job Output
         open c_one_job;
         fetch c_one_job into v_rdy_job_name,
                              v_rdy_requested_date,
                              v_rdy_fulfilled_date,
                              v_rdy_job_payload;
         close c_one_job;
         -- Check for Jobs
         for i in 1..100
         loop
            v_job_names(i) := v_request_soap_body.extract('//Jobs/Job['||i||']/Name/text()');
            EXIT WHEN v_job_names(i) is null;
            -- Verify Job Name
            if v_job_names(i).getstringval NOT in (c_schedule_job,
                                                   c_catalog_job,
                                                   c_termvalidation_job,
                                                   c_prerequisites_job,
                                                   c_rescap_job,
                                                   c_stats_job,
                                                   c_logs_job)
            then
               raise bad_job;
            end if;
            -- Insert Into Queue
            insert into csched_services
                      (job_type,
                       job_name,
                       requested_date,
                       fulfilled_date,
                       payload)
               values (c_outbound,
                       v_job_names(i).getstringval,
                       v_receiveddate + ((interval '0.000001' second)*(i-1)),
                       null,
                       empty_clob());
            COMMIT;
            -- Add to Queue tag
            if i = 1
            then
               v_queued := v_job_names(1).getstringval;
            else
               v_queued := v_queued||','||v_job_names(i).getstringval;
            end if;
         end loop;
         -- Build DeltaResponse
         select xmlelement("DeltaResponse",
                nvl2(v_reset,xmlelement("Reset",v_reset),null),
                xmlelement("Version",curr_release),
                xmlelement("Instance",c_instance),
                xmlelement("ReceivedDate",to_char(v_receiveddate,c_time_format)),
                xmlelement("ResponseDate",to_char(systimestamp,c_time_format)),
                xmlelement("ServiceRequest",to_char(v_servicerequest)),
                xmlelement("Queued",v_queued),
                (select xmlelement("Sections",
                           xmlagg(xmlelement("Section",
                                      term_code||c_tab||
                                      crn||c_tab||
                                      to_char(delta_timestamp,c_time_format)||c_tab||
                                      to_char(max_enrl)||c_tab||
                                      to_char(enrl)||c_tab||
                                      to_char(seats_avail)||c_tab||
                                      to_char(wait_capacity)||c_tab||
                                      to_char(wait_count)||c_tab||
                                      to_char(wait_avail)||c_tab||
                                      operation||c_tab||
                                      ssts_code||c_tab||
                                      voice_avail||c_tab||
                                      (select stvssts_reg_ind
                                         from stvssts
                                        where stvssts_code = ssts_code))))
                      from csched_delta a
                     where term_code       in (select term_code
                                                 from csched_terms
                                                where active_ind = c_yes)
                       and delta_timestamp =  (select max(delta_timestamp)
                                                 from csched_delta
                                                where term_code = a.term_code
                                                  and crn = a.crn)),
                (select xmlelement("ResCaps",
                           xmlagg(xmlelement("ResCap",
                                      term_code||c_tab||
                                      crn||c_tab||
                                      sequence||c_tab||
                                      to_char(rescap_timestamp,c_time_format)||c_tab||
                                      to_char(max_enrl)||c_tab||
                                      to_char(enrl)||c_tab||
                                      to_char(seats_avail)||c_tab||
                                      to_char(wait_capacity)||c_tab||
                                      to_char(wait_count)||c_tab||
                                      to_char(wait_avail)||c_tab||
                                      operation)))
                      from csched_rescap b
                     where term_code        in (select term_code
                                                  from csched_terms
                                                 where active_ind =  c_yes)
                       and rescap_timestamp =  (select max(rescap_timestamp)
                                                  from csched_rescap
                                                 where term_code =  b.term_code
                                                   and crn       =  b.crn
                                                   and sequence  =  b.sequence)),
                xmlelement("Jobs",
                   nvl2(v_rdy_job_name,xmlelement("Job",
                      xmlelement("Name",v_rdy_job_name),
                      xmlelement("Requested",to_char(v_rdy_requested_date,c_time_format)),
                      xmlelement("Fulfilled",to_char(v_rdy_fulfilled_date,c_time_format)),
                      xmlelement("Length",to_char(dbms_lob.getlength(v_rdy_job_payload))),
                      xmlelement("Compressed",
                                 decode(v_settings.schedule_format,
                                        2,c_yes,3,c_yes,c_no)),
                      xmlelement("Encrypted",
                                 decode(v_settings.schedule_format,
                                        3,c_yes,c_no)),
                      xmlelement("Data",
                         xmlcdata(nvl(v_rdy_job_payload,null)))),null)),
                xmlelement("SALT",utl_i18n.raw_to_char(
                                     utl_encode.base64_encode(
                                        dbms_crypto.randombytes(c_nonce_bytes)),
                                        c_charset))),
                systimestamp
           into v_response_body,
                v_responsedate
           from dual;
         -- Remove old delta and rescap records
         if NOT nvl(upper(v_reset),c_true) = c_false
         then
            delete csched_delta
             where delta_timestamp  <  v_responsedate;
            delete csched_rescap
             where rescap_timestamp <  v_responsedate;
            COMMIT;
         end if;
         -- Remove old services records
         if  v_rdy_job_name is NOT null
         and NOT nvl(upper(v_reset),c_true) = c_false
         then
            delete csched_services
             where job_name             =  v_rdy_job_name
               and v_rdy_requested_date <= v_rdy_fulfilled_date;
            COMMIT;
         end if;
-- ReportsResponse
      when v_reports is NOT null
      then
         select extract(column_value,'//Reports')
           into v_raw_Reports
           from table(xmlsequence(v_request_soap_body));
         -- Verify Hash
         if upper(v_request_hash) <>
            f_hash(v_raw_reports.getclobval)
         then RAISE bad_hash;
         end if;
         -- Compression and encryption
         v_compressed := v_request_soap_body.extract('//Reports/Compressed/text()');
         v_encrypted  := v_request_soap_body.extract('//Reports/Encrypted/text()');
         -- Check for Reports
         for i in 1..100
         loop
            v_report_names(i)    := v_request_soap_body.extract('//Reports/Report['||i||']/Name/text()');
            v_report_payloads(i) := v_request_soap_body.extract('//Reports/Report['||i||']/Data/text()');
            EXIT WHEN v_report_names(i) is null;
            -- Validate Report Names
            if v_report_names(i).getstringval NOT in (c_student_demand_report,
                                                      c_breaks_report,
                                                      c_course_demand_report,
                                                      c_section_excluded_report,
                                                      c_section_demand_report,
                                                      c_user_login_report)
            then
               raise  bad_report;
            end if;
            -- Validate Report Payloads
            if v_report_payloads(i) is null
            then
               raise  bad_report_payload;
            end if;
            -- Queue Report
            insert into csched_services
                      (job_type,
                       job_name,
                       requested_date,
                       compressed_ind,
                       encrypted_ind,
                       encryption_iv,
                       fulfilled_date,
                       payload)
               values (c_inbound,
                       v_report_names(i),
                       v_receiveddate + ((interval '0.000001' second)*(i-1)),
                       nvl2(v_compressed,v_compressed.getstringval,null),
                       nvl2(v_encrypted,v_encrypted.getstringval,null),
                       null,
                       null,
                       substr(v_report_payloads(i).getclobval,
                              10,
                              length(v_report_payloads(i).getclobval)-12));
            COMMIT;
            -- Add to Queue tag
            if i = 1
            then
               v_queued := v_report_names(1).getstringval;
            else
               v_queued := v_queued||','||v_report_names(i).getstringval;
            end if;
            --
         end loop;
         -- Build ReportsResponse
         select xmlelement("ReportsResponse",
                xmlelement("Version",curr_release),
                xmlelement("Instance",c_instance),
                xmlelement("ReceivedDate",to_char(v_receiveddate,c_time_format)),
                xmlelement("ResponseDate",to_char(systimestamp,c_time_format)),
                xmlelement("ServiceRequest",to_char(v_servicerequest)),
                xmlelement("Queued",v_queued),
                xmlelement("SALT",utl_i18n.raw_to_char(
                                     utl_encode.base64_encode(
                                        dbms_crypto.randombytes(c_nonce_bytes)),
                                        c_charset)))
           into v_response_body
           from dual;
--
      end case;
-- Queue Jobs and Reports
      select count(*)
        into v_service_count
        from csched_services
       where fulfilled_date is null;
      if v_service_count <> 0
      then
         declare
            bad_job_running exception;
            pragma exception_init(bad_job_running,
                                  -27477);
            v_disabled_count  number;
         begin
         dbms_scheduler.create_job(
            job_name            => 'CSCHED_JOB_QUEUE',
            job_type            => 'STORED_PROCEDURE',
            job_action          => 'CSCHED.P_JOB_QUEUE',
            number_of_arguments => 0,
            enabled             => TRUE,
            auto_drop           => TRUE,
            comments            => 'Queued by CSCHED for College Scheduler');
         exception
            when bad_job_running then
               select count(*)
                 into v_disabled_count
                 from all_scheduler_jobs
                where job_name =  'CSCHED_JOB_QUEUE'
                  and state    =  c_disabled;
               if v_disabled_count > 0
               then
                  dbms_scheduler.drop_job('CSCHED_JOB_QUEUE',
                                           TRUE);
                  dbms_scheduler.create_job(
                     job_name            => 'CSCHED_JOB_QUEUE',
                     job_type            => 'STORED_PROCEDURE',
                     job_action          => 'CSCHED.P_JOB_QUEUE',
                     number_of_arguments => 0,
                     enabled             => TRUE,
                     auto_drop           => TRUE,
                     comments            => 'Queued by CSCHED for College Scheduler');
                  p_record_fault(c_system,
                                 -20000,
                                 'CSCHED_JOB_QUEUE Restarted',
                                 'DBMS_SCHEDULER Job CSCHED_JOB_QUEUE was dropped and restarted.');
               end if;
         end;
      end if;
-- Generate complete response
      v_soap_response := (c_soap_open||
                          v_response_body.getclobval||
                          '<Hash>'||f_hash(v_response_body.getclobval)||'</Hash>'||
                          c_soap_close);
-- Deliver SOAP response (in chunks)
      owa_util.mime_header('text/xml', TRUE);
      for i in 0..(trunc((dbms_lob.getlength(v_soap_response)-1)/c_chunk))
      loop
         htp.prn(dbms_lob.substr(v_soap_response,
                                 c_chunk,
                                 i * c_chunk + 1));
      end loop;
--
   EXCEPTION
--
      when bad_soap_action then
         ROLLBACK;
         p_soap_fault(2,
                      'Invalid SOAP Action',
                      'HTTP_SOAPACTION "'||v_soap_action||'" is not valid.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_soap_body then
         ROLLBACK;
         p_soap_fault(3,
                      'Invalid SOAP Body',
                      'SOAP_BODY is empty or could not be parsed.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_hash_required then
         ROLLBACK;
         p_soap_fault(4,
                      'Hash Tag Required',
                      'Hash tag is empty or could not be parsed.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_hash then
         ROLLBACK;
         p_soap_fault(5,
                      'Invalid Hash Value',
                      'Hash could not be validated.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_msg_count then
         ROLLBACK;
         p_soap_fault(6,
                      'One transaction per message',
                      v_msg_count||' transactions were recognized.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_job then
         ROLLBACK;
         p_soap_fault(7,
                      'Job Name Not Recognized',
                      'A job was requested, but the name is not recognized.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_sendtostudentcart then
         ROLLBACK;
         p_soap_fault(8,
                      'SendToStudentCart could not be parsed',
                      'SendToStudentCart was recognized, but was incomplete or incorrectly formatted.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);

--
      when bad_student_id then
         ROLLBACK;
         p_soap_fault(9,
                      'Invalid Student ID',
                      'StudentID "'||v_id_delivered||'" is not valid.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_term then
         ROLLBACK;
         p_soap_fault(10,
                      'Invalid Term Code',
                      'TermCode "'||v_term||'" is not valid.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
     when bad_groupid_required then
         ROLLBACK;
         p_soap_fault(12,
                      'GroupID Required',
                      'GroupID tag is required to process more than ten CRNs.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_report then
         ROLLBACK;
         p_soap_fault(13,
                      'Report Name Not Recognized',
                      'A report was delivered, but the name is not recognized.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when bad_report_payload then
         ROLLBACK;
         p_soap_fault(14,
                      'Report Delivered Without Data',
                      'A report was delivered without any associated data.',
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
      when OTHERS then
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         p_soap_fault(v_sqlcode,
                      v_sqlerrm,
                      v_backtrace,
                      v_receiveddate,
                      v_servicerequest,
                      v_request_soap_body);
--
   END p_services;
--
PROCEDURE p_addfromsearch(term_in        OWA_UTIL.ident_arr,
                          assoc_term_in  OWA_UTIL.ident_arr,
                          sel_crn        OWA_UTIL.ident_arr,
                          add_btn        OWA_UTIL.ident_arr)
--
-- p_addfromsearch wraps the Banner baseline registration procedure
-- bwckcoms.p_addfromsearch to provide registration processing to CSCHED.
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_addfromsearch';
--
      c_system           CONSTANT varchar2(255) := 'P_ADDFROMSEARCH';
      v_sqlcode                   number;
      v_sqlerrm                   varchar2(4000);
      v_backtrace                 varchar2(4000);
--
      v_assoc_term_in_dummy       OWA_UTIL.ident_arr;
      v_assoc_term_in             OWA_UTIL.ident_arr;
      v_sel_crn_dummy             OWA_UTIL.ident_arr;
      v_sel_crn                   OWA_UTIL.ident_arr;
      v_worksheet_button          OWA_UTIL.ident_arr;
      v_crn_dummy                 OWA_UTIL.ident_arr;
      v_rsts_dummy                OWA_UTIL.ident_arr;
      v_settings                  csched_settings%rowtype;
      v_stvterm_rec               stvterm%rowtype;
      v_sorrtrm_rec               sorrtrm%rowtype;
--
      c_web_rsts                  varchar2(2)   := f_stu_getwebregsrsts('R');
--
   BEGIN
-- Validate the current user
      if NOT twbkwbis.f_validuser(g_pidm)
      then
         RETURN;
      end if;
--
      v_crn_dummy(1)  := 'dummy';
      v_rsts_dummy(1) := 'dummy';
--
      v_settings := f_settings;
--
      if add_btn(2) = c_del_cart_button
      then
         -- Inactivate cart rows
         update csched_regcart
            set active_ind    = c_no,
                activity_date = systimestamp
          where pidm = g_pidm
            and term_code = term_in(1);
         COMMIT;
         -- Clear Cart button returns student to URL_LOGOUT
         bwckfrmt.p_open_doc(c_document);
         htp.p('<meta http-equiv="refresh" content="'||c_redirect_seconds||
            ';URL='''||v_settings.url_logout||'''"><br>');
         htp.p('<big><a href="'||v_settings.url_logout||'">'||
            v_settings.text_logout||'</a></big><br><br>');
         twbkwbis.p_closedoc(curr_release);
      elsif add_btn(2) = c_save_cart_button
      then
         -- Save Cart button returns student to URL_LOGOUT
         bwckfrmt.p_open_doc(c_document);
         htp.p('<meta http-equiv="refresh" content="'||c_redirect_seconds||
            ';URL='''||v_settings.url_logout||'''"><br>');
         htp.p('<big><a href="'||v_settings.url_logout||'">'||
            v_settings.text_logout||'</a></big><br><br>');
         twbkwbis.p_closedoc(curr_release);
      else
         -- Record CSCHED_AUDIT registration attempts
         for i in 2..sel_crn.last
         loop
            insert into csched_audit
                      (pidm,
                       term_code,
                       activity_date,
                       crn,
                       rsts_code,
                       add_btn)
               values (g_pidm,
                       term_in(1),
                       systimestamp,
                       substr(sel_crn(i),1,instr(sel_crn(i),' ')-1),
                       c_web_rsts,
                       add_btn(2));
         end loop;
         COMMIT;
         -- Intercept the BADTERM registration error.
         if NOT bwskflib.f_validterm(term_in(1),
                                     v_stvterm_rec,
                                     v_sorrtrm_rec)
         then
            bwckfrmt.p_open_doc(c_document,
                                term_in(1));
            htp.br;
            twbkwbis.p_dispinfo('bwskflib.P_SelDefTerm', 'BADTERM');
            htp.br;
            twbkwbis.p_closedoc(curr_release);
            RETURN;
         end if;
         -- Remove Unselected CRNs
         v_assoc_term_in := assoc_term_in;
         v_sel_crn       := sel_crn;
         for i in 2..term_in.count
         loop
            if sel_crn is null
            then
               v_assoc_term_in.delete(i);
               v_sel_crn.delete(i);
            end if;
         end loop;
         -- Process Registrations
         bwskfreg.p_altpin1(term_in,
                            v_assoc_term_in,
                            v_sel_crn,
                            add_btn,
                            v_crn_dummy,
                            v_rsts_dummy);
      end if;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         bwckfrmt.p_open_doc(c_document);
         htp.br;
         twbkwbis.p_dispinfo(c_document, 'OTHERERROR');
         htp.sample(v_sqlerrm||'<br>'||v_backtrace||'<br><br>');
         twbkwbis.p_closedoc(curr_release);
--
   END p_addfromsearch;
--
PROCEDURE p_regs_internal(p_pidm            number,  -- INTERNAL Processing
                          p_term_code       varchar2,
                          p_settings        csched_settings%rowtype)
--
-- p_regs_internal creates the p_regs Self Service page.  p_regs_internal
-- is called by p_regs (for links from College Scheduler) and p_regs_ssb
-- (for links from within SSB).
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_regs';
--
      type t_regcart_tab          is table of csched_regcart%rowtype
                                     index by binary_integer;
      v_regcart_tab               t_regcart_tab;
      type t_ssbsect_tab          is table of ssbsect%rowtype
                                     index by binary_integer;
      v_ssbsect_tab               t_ssbsect_tab;
      type t_scbcrse_tab          is table of scbcrse%rowtype
                                     index by binary_integer;
      v_scbcrse_tab               t_scbcrse_tab;
      type t_regstat_tab          is table of varchar2(60)
                                     index by binary_integer;
      v_regstat_tab               t_regstat_tab;
--
      c_web_rsts                  varchar2(2)   := f_stu_getwebregsrsts('R');
--
   BEGIN
-- Fetch Cart Records
      select *
        bulk collect into v_regcart_tab
        from csched_regcart
       where pidm       = p_pidm
         and term_code  = p_term_code
         and active_ind = c_yes
       order by groupid,
                crn;
-- Force "Student" mode
      twbkwbis.p_setparam(p_pidm, c_ssb_stufac_ind, c_ssb_stu_ind);
-- Set WebTailor term code
      twbkwbis.p_setparam(p_pidm, c_ssb_term, p_term_code);
-- Verify record count
      if v_regcart_tab.count = 0
      then
         bwckfrmt.p_open_doc(c_document,
                             p_term_code);
         htp.br;
         twbkwbis.p_dispinfo(c_document, 'EMPTYCART');
         htp.br;
         twbkwbis.p_closedoc(curr_release);
         RETURN;
      end if;
-- Fetch Section Data from SSBSECT
      for i in 1..v_regcart_tab.count
      loop
         begin
            select *
              into v_ssbsect_tab(i)
              from ssbsect
             where ssbsect_term_code = v_regcart_tab(i).term_code
               and ssbsect_crn       = v_regcart_tab(i).crn;
         exception
            when NO_DATA_FOUND then
               RAISE_APPLICATION_ERROR(-20009,c_document||' - Section Data Not Available (SSBSECT)');
         end;
      end loop;
-- Fetch Course Data from SCBCRSE
      for i in 1..v_regcart_tab.count
      loop
         begin
            select *
              into v_scbcrse_tab(i)
              from scbcrse a
             where scbcrse_subj_code = v_ssbsect_tab(i).ssbsect_subj_code
               and scbcrse_crse_numb = v_ssbsect_tab(i).ssbsect_crse_numb
               and scbcrse_eff_term  = (select max(scbcrse_eff_term)
                                          from scbcrse
                                         where scbcrse_eff_term  <= v_ssbsect_tab(i).ssbsect_term_code
                                           and scbcrse_subj_code = a.scbcrse_subj_code
                                           and scbcrse_crse_numb = a.scbcrse_crse_numb);
         exception
            when NO_DATA_FOUND then
               RAISE_APPLICATION_ERROR(-20010,c_document||' - Course Data Not Available (SCBCRSE)');
         end;
      end loop;
-- Current Registration
      for i in 1..v_regcart_tab.count
      loop
         begin
            select stvrsts_desc||' on '||
                   to_char(sfrstcr_rsts_date,
                           twbklibs.date_display_fmt)
              into v_regstat_tab(i)
              from stvrsts, sfrstcr
             where stvrsts_code      =  sfrstcr_rsts_code
               and sfrstcr_term_code =  v_regcart_tab(i).term_code
               and sfrstcr_pidm      =  p_pidm
               and sfrstcr_crn       =  v_regcart_tab(i).crn;
         exception
             when NO_DATA_FOUND then
                v_regstat_tab(i) := null;
         end;
      end loop;
-- Display Page
-- Open Document
      bwckfrmt.p_open_doc(c_document,
                          p_term_code);
      htp.br;
      twbkwbis.p_dispinfo(c_document, 'REGCART');
      htp.br;
-- Open Form
      htp.formopen(twbkwbis.f_cgibin || 'csched.p_addfromsearch');
-- Course Table
      twbkfrmt.p_tableopen('DATADISPLAY',
                           cattributes => 'SUMMARY="Registration Cart Records"',
                           ccaption    => 'Classes in the Registration Cart');
-- Course Table Header
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledataheader('Select',
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tabledataheader(twbkfrmt.f_printtext (
         '<ACRONYM title = "Course Reference Number">CRN</ACRONYM>',
         BYPASS_ESC=>'Y'),
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tabledataheader(twbkfrmt.f_printtext (
         '<ABBR title = Subject>Subj</ABBR>',
         BYPASS_ESC=>'Y'),
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tabledataheader(twbkfrmt.f_printtext (
         '<ABBR title = Course>Crse</ABBR>',
         BYPASS_ESC=>'Y'),
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tabledataheader(twbkfrmt.f_printtext (
         '<ABBR title = Section>Sec</ABBR>',
         BYPASS_ESC=>'Y'),
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tabledataheader('Title',
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tabledataheader('Status',
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tabledataheader(null,
                                 cattributes=>'BYPASS_ESC=Y');
      twbkfrmt.p_tablerowclose;
-- Rows
      twbkfrmt.p_formhidden('term_in',       p_term_code);
      twbkfrmt.p_formhidden('assoc_term_in', 'dummy');
      twbkfrmt.p_formhidden('sel_crn',       'dummy');
      twbkfrmt.p_formhidden('add_btn',       'dummy');
--
      for i in 1..v_regcart_tab.count
      loop
         -- Form Parameters
         twbkfrmt.p_formhidden('assoc_term_in', p_term_code);
         -- Table Row
         twbkfrmt.p_tablerowopen;
         twbkfrmt.p_tabledata(
            htf.formcheckbox('sel_crn',
                             v_ssbsect_tab(i).ssbsect_crn || ' ' ||
                                v_ssbsect_tab(i).ssbsect_term_code,
                             cattributes=>'checked="checked"'),
                              cattributes=>'BYPASS_ESC=Y');
         twbkfrmt.p_tabledata(
            twbkfrmt.f_printanchor(
               twbkfrmt.f_encodeurl(
                  twbkwbis.f_cgibin || 'bwckschd.p_disp_listcrse' ||
                     '?'||'term_in=' ||
                     twbkfrmt.f_encode(v_ssbsect_tab(i).ssbsect_term_code) ||
                     c_amp||'subj_in=' ||
                     twbkfrmt.f_encode(v_ssbsect_tab(i).ssbsect_subj_code) ||
                     c_amp||'crse_in=' ||
                     twbkfrmt.f_encode(v_ssbsect_tab(i).ssbsect_crse_numb) ||
                     c_amp||'crn_in=' ||
                     twbkfrmt.f_encode(v_ssbsect_tab(i).ssbsect_crn)),
                  v_ssbsect_tab(i).ssbsect_crn),
                              cattributes=>'BYPASS_ESC=Y');
         twbkfrmt.p_tabledata(v_ssbsect_tab(i).ssbsect_subj_code,
                              cattributes=>'BYPASS_ESC=Y');
         twbkfrmt.p_tabledata(v_ssbsect_tab(i).ssbsect_crse_numb,
                              cattributes=>'BYPASS_ESC=Y');
         twbkfrmt.p_tabledata(v_ssbsect_tab(i).ssbsect_seq_numb,
                              cattributes=>'BYPASS_ESC=Y');
         twbkfrmt.p_tabledata(nvl(v_ssbsect_tab(i).ssbsect_crse_title,
                                  v_scbcrse_tab(i).scbcrse_title),
                              cattributes=>'BYPASS_ESC=Y');
         twbkfrmt.p_tabledata('<b>'||nvl(v_regstat_tab(i),'-')||'</b>',
                              cattributes=>'BYPASS_ESC=Y');
         if v_ssbsect_tab(i).ssbsect_seats_avail <= 0
         then
            twbkfrmt.p_tabledataopen('Section <b>FULL</b>');
            if v_ssbsect_tab(i).ssbsect_wait_capacity > 0
            then
               if v_ssbsect_tab(i).ssbsect_wait_avail <= 0
               then
                  htp.prn(', Waitlist <b>FULL</b>');
               else
                  htp.prn(', Waitlist Available');
               end if;
            end if;
            twbkfrmt.p_tabledataclose;
         else
            twbkfrmt.p_tabledata(null,
                                 cattributes=>'BYPASS_ESC=Y');
         end if;
         twbkfrmt.p_tablerowclose;
      end loop;
-- Course TableFooter
      twbkfrmt.p_tableclose;
      htp.br;
-- Buttons
      htp.formsubmit('ADD_BTN',
                     c_reg_button,
                     cattributes=>'title="'||c_reg_button_title||'"');
      if p_settings.add_to_worksheet_ind = c_yes
      then
          htp.formsubmit('ADD_BTN',
                         c_worksheet_button,
                         cattributes=>'title="'||c_worksheet_button_title||'"');
      end if;
      htp.formsubmit('ADD_BTN',
                     c_save_cart_button,
                     cattributes=>'title="'||c_save_cart_button_title||'"');
      htp.formsubmit('ADD_BTN',
                     c_del_cart_button,
                     cattributes=>'title="'||c_del_cart_button_title||'"');
      htp.formclose;
-- Close Document
      htp.br;
      twbkwbis.p_closedoc(curr_release);
--
--   EXCEPTION
--
--
   END p_regs_internal;  -- INTERNAL Processing
--
PROCEDURE p_regs_ssb(term_in  varchar2 default null)            -- WEB PROCEDURE
--
-- p_regs_ssb calls p_regs_internal to build the p_regs "Registration Cart"
-- page.  p_regs_ssb is intended for links from within Self Service Banner.
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_regs_ssb';
--
      v_term_code                 varchar2(6);  -- Validated Term Code
--
      c_system           CONSTANT varchar2(255)  := 'P_REGS_SSB';
      v_sqlcode                   number;
      v_sqlerrm                   varchar2(4000);
      v_backtrace                 varchar2(4000);
--
   BEGIN
-- Validate the current user
      if NOT twbkwbis.f_validuser(g_pidm)
      then
         RETURN;
      end if;
-- Validate Term Code
      if term_in is null
      then v_term_code := twbkwbis.f_getparam(g_pidm, c_ssb_term);
      else v_term_code := term_in;
      end if;
      if v_term_code is null
      then
         bwskflib.p_seldefterm(v_term_code, c_document);
         RETURN;
      end if;
-- Call p_regs_internal
      p_regs_internal(g_pidm,
                      v_term_code,
                      f_settings);
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         bwckfrmt.p_open_doc(c_document);
         htp.br;
         twbkwbis.p_dispinfo(c_document, 'OTHERERROR');
         htp.sample(v_sqlerrm||'<br>'||v_backtrace||'<br><br>');
         twbkwbis.p_closedoc(curr_release);
--
   END p_regs_ssb;
--
PROCEDURE p_regs(term      varchar2 default null,               -- WEB PROCEDURE
                 opt       varchar2 default null)
--
-- p_regs calls p_regs_internal to build the p_regs "Registration Cart" page.
-- p_regs is intended for links from College Scheduler.
--
   IS
--
      c_document                  varchar2(200) := 'csched.p_regs';
--
      v_settings                  csched_settings%rowtype;
      v_term_code                 varchar2(6);  -- Validated Term Code
--
      c_system           CONSTANT varchar2(255)  := 'P_REGS';
      v_sqlcode                   number;
      v_sqlerrm                   varchar2(4000);
      v_backtrace                 varchar2(4000);
--
   BEGIN
-- Validate the current user
      if NOT twbkwbis.f_validuser(g_pidm)
      then
         RETURN;
      end if;
--
      if  term is null
      and opt  is null
      then
         RAISE_APPLICATION_ERROR(-20035,c_document||' - TERM or OPT Parameter Required');
      end if;
--
      if term is NOT null
      then
         -- Validate term parameter
         begin
            select stvterm_code
              into v_term_code
              from sobterm, stvterm
             where sobterm_term_code = stvterm_code
               and stvterm_code      = term;
         exception
            when NO_DATA_FOUND then
               RAISE_APPLICATION_ERROR(-20013,c_document||' - Invalid TERM Parameter');
         end;
         -- Set WebTailor term code
         twbkwbis.p_setparam(g_pidm, c_ssb_term, v_term_code);
      end if;
-- Get Settings
      v_settings := f_settings;
--
      case upper(opt)
      when 'LOGOUT' then
         --
         bwckfrmt.p_open_doc(c_document);
         --
         case twbkwbis.f_getparam(g_pidm, c_ssb_csmode_ind)
         when c_guest_mode then
            htp.p('<meta http-equiv="refresh" content="'||c_redirect_seconds||
               ';URL='''||nvl(v_settings.url_logout_guest,
                              v_settings.url_logout)||'''"><br>');
            htp.p('<big><a href="'||nvl(v_settings.url_logout_guest,
                                        v_settings.url_logout)||'">'||
               v_settings.text_logout||'</a></big><br><br>');
         when c_advisor_mode then
            htp.p('<meta http-equiv="refresh" content="'||c_redirect_seconds||
               ';URL='''||nvl(v_settings.url_logout_advisor,
                              v_settings.url_logout)||'''"><br>');
            htp.p('<big><a href="'||nvl(v_settings.url_logout_advisor,
                                        v_settings.url_logout)||'">'||
               v_settings.text_logout||'</a></big><br><br>');
         else -- c_student_mode
            htp.p('<meta http-equiv="refresh" content="'||c_redirect_seconds||
               ';URL='''||v_settings.url_logout||'''"><br>');
            htp.p('<big><a href="'||v_settings.url_logout||'">'||
               v_settings.text_logout||'</a></big><br><br>');
         end case;
         --
         twbkwbis.p_closedoc(curr_release);
         --
         RETURN;
        --
      when 'CARTFAILED' then
         --
         bwckfrmt.p_open_doc(c_document);
         htp.p('<meta http-equiv="refresh" content="'||c_redirect_seconds||
            ';URL='''||v_settings.url_cartfailed||'''"><br>');
         htp.p('<big><a href="'||v_settings.url_cartfailed||'">'||
            v_settings.text_cartfailed||'</a></big><br><br>');
         twbkwbis.p_closedoc(curr_release);
         --
         RETURN;
         --
      else
         -- Call p_regs_internal
         p_regs_internal(g_pidm,
                         v_term_code,
                         v_settings);
      end case;
--
   EXCEPTION
--
      when OTHERS then
         v_sqlcode   := sqlcode;
         v_sqlerrm   := substr(dbms_utility.format_error_stack,1,4000);
         v_backtrace := substr(dbms_utility.format_error_backtrace,1,4000);
         ROLLBACK;
         --
         p_record_fault(c_system,
                        v_sqlcode,
                        v_sqlerrm,
                        v_backtrace);
         --
         bwckfrmt.p_open_doc(c_document);
         htp.br;
         twbkwbis.p_dispinfo(c_document, 'OTHERERROR');
         htp.sample(v_sqlerrm||'<br>'||v_backtrace||'<br><br>');
         twbkwbis.p_closedoc(curr_release);
--
   END p_regs;
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--
END csched;        /* Package Body */
--
/
--

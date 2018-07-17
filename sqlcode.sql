
SLOTS PER INTERVIEWER 

SELECT 
	i.*, 
	w.interviewweeklyslot_id, 
	e.employerName, 
	j.role_id, 
	l.zipcode_id
  

FROM question_interviewer i
LEFT JOIN question_interviewer_weeklySlots w
	ON i.id = w.interviewer_id
LEFT JOIN chatproj_employer  e
	ON e.id = i.employer_id
LEFT JOIN question_jobreq j
	ON j.interviewer_id = i.id
LEFT JOIN question_location l
	ON l.id = j.location_id


(ORIGINAL QUERY WITH ALL THE FILTERS: IF NICK ASKS WHY THIS IS CHANGED - EACH INTERVIEWER HAS HUNDREDS OF JOBREQS POSSIBLE SO THAT MAKES THERE BE EVERY POSSIBLE ROLE
FOR THAT EMPLOYER AND EVERY PSSOIBLE LOCATION MAKES THE SIZE TOO LARGE AND THEREFORE NOT PRACTICAL AS WE GROW )



PARSE ERRORS PER USER SESSION (w/incomingsms that caused the error)


SELECT 
 	u.created_at, 
 	u.id, 
 	o.body, 
 	i.body as incoming, 
 	i.timestamp,
	e.employerName, 
	s.status_id, 
	j.status,
	r.title,
    l.name as Location, 
    l.zipcode_id, 
    g.city, 
    g.state
    
FROM chatproj_usersession u 
LEFT JOIN chatproj_outgoingsms o
	ON u.id = o.usersession_ID
LEFT JOIN chatproj_incomingsms i 
	ON i.id = o.incomingTrigger_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus s
	ON s.usersession_id = u.id
LEFT JOIN  question_jobreq j
	ON j.id = s.jobreq_id
LEFT JOIN question_role r
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 
LEFT JOIN geocoder_zipcode g 
	ON g.zipcode = l.zipcode_id
WHERE (o.body = "Let me get back to you very soon" OR substring(o.body, 1, 20) = "Let's try this again" ) AND  e.employerName != 'AllyO' 
GROUP BY u.id 

NEW FIELD 1 = ifelse(body = "Let me get back to you very soon" OR left(body,20) = "Let's try this again",body,null)
ifelse({body} = "Let me get back to you very soon" OR left(body,20) = "Let's try this again",Users,null)

HUMAN ASSIST COUNT W TIME FILTER 

SELECT humanAssist, timeStamp FROM  allyo_db.chatproj_outgoingsms
WHERE humanAssist = 1


POST ATS ERROR , NO INI, TEXT IS SENT 

SELECT 
	o.errorCode, 
	o.timestamp, 
	u.firstname, 
	u.lastName, 
	u.userNumber, 
	u.email, 
	u.locationPreference,
	e.employerName, 
	r.title,
	l.name, 
	g.city, 
	g.state
 
FROM chatproj_outgoingsms o

LEFT JOIN chatproj_usersession u
	ON u.id = o.userSession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us 
	ON us.usersession_ID = u.id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r
	ON r.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id
LEFT JOIN geocoder_zipcode g 
	ON g.zipCode = l.zipCode_id 

WHERE substring(errorCode, 1, 4) =  '2121' OR errorCode = '21610'

TEST FOR JAMES 

SELECT 
	errorCode, 
	timestamp 

FROM chatproj_outgoingsms

WHERE substring(timestamp, 1, 7) = '2018-05'
	AND errorCode IS NOT NULL

PITNEY BOWES USERS 

SELECT DISTINCT 
	u.id, 
	u.extra_data, 
	u.firstName, 
	email, 
	userNumber, 
	u.lastName, 
	e.employerName

FROM chatproj_usersession u
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
WHERE employerName = "Pitney Bowes"

FOREIGN LANGUAGE USERS 

SELECT 
	u.extra_data, 
	u.firstName,
	email, 
    userNumber, 
    u.lastName, 
    e.employerName

FROM chatproj_usersession u
LEFT  JOIN chatproj_employer e
 ON e.id = u.employer_id
WHERE substring(extra_data, 1,15) = '{"user_langauge'

CURRENT HA COUNT BY STATUS TAG 

SELECT 
	u.id AS users, 
	u.created_at AS time, 
	i.humanAssist,  
	us.status_id, 
	s.tag, 
	e.employerName, 
	j.role_id, 
	r.title, 
	l.name as Location, 
	g.city, 
	g.state

FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN dashboard_userstatus us 
	ON us.usersession_id = u.id 
LEFT JOIN dashboard_applicant_prior_userstatus a
	ON a.userStatus_id = us.id 
LEFT JOIN dashboard_status s
	ON s.id = a.status_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 
LEFT JOIN geocoder_zipcode g
	ON g.zipcode = l.zipcode_id

WHERE i.humanAssist = 1

GROUP BY u.id

HA USERS VS TOTAL USERS 

SELECT 
   i.timestamp, 
   i.humanAssist, 
   i.body, 
   i.usersession_id,
   u.employer_id,
   e.employerName, 
   us.status_id, 
   j.role_id, 
   r.title, 
   l.zipcode_id
    
FROM chatproj_incomingsms i
LEFT JOIN  chatproj_usersession u
	ON u.id = i.usersession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us 
	ON us.usersession_id = u.id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id

WHERE i.body != "opened" AND i.humanAssist = 1
GROUP BY u.id 





NUM APPLICANTS 

SELECT 
	du.*,  
    ds.tag,
    ds.order,
    e.employerName,
    u.created_at,
    u.locationPreference, 
    j.role_id, 
    r.title,
    l.zipCode_id, 
    inter.emails, 
    g.city, 
    g.state 
    
FROM dashboard_userstatus du
LEFT JOIN dashboard_applicant_prior_userstatus a 
		ON a.userStatus_id = du.id 
LEFT JOIN  dashboard_status ds
		ON  ds.id = a.status_id 
LEFT JOIN chatproj_employer e
		ON  e.id = ds.employer_id
LEFT JOIN chatproj_usersession u 
		ON u.id = du.userSession_id
LEFT JOIN question_jobreq j
		ON  j.id = du.jobreq_id
LEFT JOIN question_role r
		ON r.id = j.role_id
LEFT JOIN question_location l
		ON l.id = j.location_id
LEFT JOIN question_interviewer inter
		ON inter.id = j.interviewer_id
LEFT JOIN geocoder_zipcode g 
		ON g.zipcode = l.zipCode_id
	
        
WHERE ds.tag != 'No Status' AND ds.tag != "New" 
GROUP BY u.id 

QUICKSIGHT APPLICATION COMPLETERATE COMMAND - SQL QUERY IS SAME AS ABOVE  - REMEMBER THAT BOTH THE USERSESSION COUNT AND THE FULLY COMPLETED COUNT HAVE TO BE DISTINCT
ifelse({tag} <> 'Explored' AND {tag} <> 'Prospect', {userSession_id}, null) 



ifelse(   {tag} = "Interviewed" OR
	      {tag} = "Not Interviewed" OR
          {tag} = "Hired" OR 
          {tag} = "Scheduled" OR
          {tag} = "Opted Out" OR
          {tag} = "Rejected" OR
          {tag} = "Reject" OR
          {tag} = "Hire" OR
          {tag} = "Screened" OR
          {tag} = "Offer Schedule" OR
          {tag} = "Submit Job Offer Request" OR
          {tag} = "Conducted" OR
          {tag} = "Conduct Job Offer" OR
          {tag} = "Cancel Interview" OR
          {tag} = "Phone Interviewed" OR
    	  {tag} ="In-Person Interview" OR
          {tag} = "Offer Accepted" OR
          {tag} = "Found another job" OR
          {tag} = "No Jobs" OR 
          {tag} = "No Show" OR
		  {tag} = "Accept Associate" OR
          {tag} = "Final Interview" OR
          {tag} = "Onsite Interview" OR
          {tag} ="Send Onsite Interview" OR 
          {tag} ="Manually Scheduled" OR
		  {tag} ="Ready for Interview" OR
	   	  {tag} = "Offer Out" OR
		  {tag} = "Interviewing" OR
		  {tag} = "Offer Out" OR
		  {tag} = "Extend Offer" OR
		  {tag} = "Churned" OR 
		  {tag} = "Offer Made" OR
		  {tag} = "Offer Accepted" OR 
	      {tag} = "Applied" OR
		  {tag} = "Application Complete" OR
		  {tag} = "Application Pending" OR
	      {tag} = "Disqualified" OR 
	      {tag} = "Qualifed" OR
		  {tag} = "Voluntarily Churned" OR
		  {tag} = "Assessment Pending" OR
		  {tag} = "Application Received" , 1, 0) 



USER QUESTIONS 

SELECT 
	i.body,
	i.timeStamp, 
    u.id,
    u.firstname, 
    u.lastname,
    u.userNumber,
    e.employerName
    
FROM chatproj_incomingsms i 

LEFT JOIN chatproj_usersession u
	ON i.userSession_id = u.id

LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
    
WHERE body LIKE '%how%' OR body LIKE '%where%' OR body LIKE '%what%'  OR body LIKE '%why%'  OR body LIKE '%who%' 
		OR body LIKE '%?%' OR body LIKE "%do you%" OR body LIKE "%do I%" OR body LIKE "%can I%" 
                            OR body LIKE "%can you%"
	
STATUS STAGES 

SELECT 
s.tag, 
us.userSession_id, 
min(us.connectedOn), 
max(us.connectedOn), 
u.id as Users, 
e.employerName,
j.id, 
r.title,
l.name as Location 


FROM dashboard_status s
LEFT JOIN dashboard_userstatus us
	ON s.id = us.status_id
LEFT JOIN chatproj_usersession u 
	ON u.id = us.usersession_id
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l
	ON l.id = j.location_id


GROUP BY us.usersession_id

2.0 - 
SELECT
	p.*, 
    us.jobreq_id, 
    u.id as Users, 
    s.tag, 
    e.employerName, 
    r.title, 
    l.name as Location, 
    l.zipcode_id
    

FROM dashboard_applicant_prior_userstatus p 
LEFT JOIN dashboard_userstatus us 
	ON us.id = p.userStatus_id 
LEFT JOIN chatproj_usersession u 
	ON u.id = us.userSession_id
LEFT JOIN dashboard_status s
	ON s.id = p.status_id
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role r
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id


	  


NUM OF INTERACTIONS  
SELECT 

u.id, 
u.created_at, 
count(i.body) , 
q.id as ScheduledInterviews, 
e.employerName 


FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN question_selectedinterviewslot q 
	ON q.usersession_id = u.id
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id    
    
WHERE i.body != 'opened'
GROUP BY u.id 

SMS VS WEB CHAT - Shobhit 

SELECT 
	u.id, 
	u.userNumber,
	u.websessionID, 
	u.created_at, 
	e.employerName,
	i.body, 
	us.jobreq_id, 
	r.title as Role, 
	l.name as Location, 
	l.zipcode_id, 
	g.city, 
	g.state

FROM chatproj_usersession u 
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN chatproj_incomingsms i
	ON i.usersession_id = u.id
LEFT JOIN dashboard_userstatus us 
	ON us.userSession_id = u.id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r
	ON r.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id 
LEFT JOIN geocoder_zipcode g 
	ON g.zipCode = l.zipcode_id 

WHERE i.body != "opened" 

GROUP BY u.id 

Quicksight CALCULATED Fields 
	SMS Only - isNull({websessionid})
	WEB - isNotNull({websessionid})

AMOUNT OF NUM OF THANK YOUS 

SELECT 
	i.body, 
	i.usersession_id, 
	i.timeStamp,
	u.employer_id, 
	e.employerName,
	us.jobreq_id, 
	j.id, 
	role.title,
	l.name as Location,
	g.zipcode, 
	g.city, 
	g.state 



FROM chatproj_incomingsms i
LEFT JOIN  chatproj_usersession u 
	ON u.id = i.usersession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us 
	ON us.userSession_id = u.id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role role 
    ON role.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id 
LEFT JOIN geocoder_zipcode g 
	ON g.zipCode = l.zipcode_id

WHERE body != "opened" AND (body LIKE "% ty %" OR body LIKE '%thank%' OR body LIKE "%thx%")


Number of Interviews Completed 

SELECT 
	s.tag, 
	us.status_id, 
	u.id, 
	u.created_at,
	e.employerName, 
	j.role_id, 
	r.title, 
	inter.emails, 
	l.name

FROM dashboard_status s
LEFT JOIN dashboard_userstatus us 
	ON s.id = us.status_id
LEFT JOIN chatproj_usersession u 
	ON u.id = us.userSession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_interviewer inter
	ON inter.id = j.interviewer_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 

WHERE   (tag = "Reject" OR
		tag = "Hired" OR
		tag = "Interviewed" OR 
		tag = "Offer Schedule" OR
		tag = "Interviewing" OR
		tag = "Extend Offer" OR
		tag = "Final Interview" OR
		tag = "Hire" OR
		tag = "Conduct Job Offer" OR
		tag = "Conduct Orientation" OR
		tag = "Conducted" OR
		tag = "Offer Out" OR
		tag = "Offer Made" OR
		tag = "In Person Interview" OR 
		tag = "Phone Interviewed")
        AND us.status_id IS NOT NULL

ORDER BY e.employerName

INTERVIEW COMPLETION RATE - same query as above without the where clause 


COUNT OF RESPONSES BEFORE RECEIVING A JOB OFFER
SELECT 
s.usersession_id, 
i.body, 
i.timeStamp, 
u.created_at, 
us.status_id, 
j.status,
r.title,
l.name as Location




FROM question_selectedinterviewslot s
LEFT JOIN chatproj_incomingsms i
	ON i.usersession_id = s.usersession_id
LEFT JOIN chatproj_usersession u
	ON s.userSession_id = u.id 
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id
LEFT JOIN  question_jobreq j
	ON j.id = s.jobreq_id
LEFT JOIN question_role r
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 


DISQUALIFCATION REASONS TABLE 

SELECT 
	o.body, 
	i.body,
	u.id, 
	us.status_id, 
	s.tag, 
	j.role_id, 
	r.title, 
	l.name AS Location 

FROM chatproj_outgoingsms o 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = o.usersession_id
LEFT JOIN chatproj_usersession u 
	ON o.usersession_id = u.id 
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id 
LEFT JOIN dashboard_status s
	ON s.id = us.status_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id

WHERE s.tag = "Disqualified"


                
                
ifelse({body} = "Let me get back to you very soon" OR left(body,20) = "Let's try this again",Users,null)

        
 THE AMOUNT OF STOPS

SELECT 
	i.body, 
	i.usersession_id, 
	i.timeStamp,
	u.employer_id, 
	e.employerName, 
	us.status_id, 
	j.role_id, 
	r.title, 
	l.name as Location, 
	l.zipCode_id, 
	g.city, 
	g.state 

FROM chatproj_incomingsms i
LEFT JOIN  chatproj_usersession u 
	ON u.id = i.usersession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id 
LEFT JOIN question_jobreq j
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l
	ON l.id = j.location_id
LEFT JOIN geocoder_zipcode g
	ON g.zipCode = l.zipCode_id
	

WHERE Lower(substring(body, 1, 11)) != 'christopher'  AND body LIKE "%stop%"


 THE AMOUNT OF CURSE WORDS 

SELECT 
	i.body, 
	i.usersession_id, 
	i.timeStamp,
	u.employer_id, 
	e.employerName, 
	us.status_id, 
	j.role_id, 
	r.title, 
	l.name as Location, 
	g.city, 
	g.state


FROM chatproj_incomingsms i
LEFT JOIN  chatproj_usersession u 
	ON u.id = i.usersession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id 
LEFT JOIN question_jobreq j
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l
	ON l.id = j.location_id
LEFT JOIN geocoder_zipcode g 
	ON g.zipcode = l.zipCode_id
	

WHERE body != "opened" AND (body LIKE "%fuck%" OR
							body LIKE "%bitch%" OR
							body LIKE "% ass %" OR
							body LIKE "%slut%" OR
							body LIKE "%whore%" OR
							body LIKE "%asshole%" OR
							body LIKE "%douche%" OR
							body LIKE "%douchebag%" OR
							body LIKE "%cunt%"  OR
							body LIKE '%pussy%' OR 
							body LIKE '% dick %' OR 
							body LIKE '%vagina%' OR 
							body LIKE '%cock%'
							)

EXCITEMENT IN INTERACTIONS 

THE AMOUNT OF Excitiement 

SELECT 
	i.body, 
	i.usersession_id, 
	i.timeStamp,
	u.employer_id, 
	e.employerName, 
	us.status_id, 
	j.role_id, 
	r.title, 
	l.name as Location,
	g.city, 
	g.state


FROM chatproj_incomingsms i
LEFT JOIN  chatproj_usersession u 
	ON u.id = i.usersession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id 
LEFT JOIN question_jobreq j
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l
	ON l.id = j.location_id
LEFT JOIN geocoder_zipcode g 
	ON g.zipcode = l.zipcode_id

WHERE body != "opened" AND body LIKE "%!%"

PENDING HA 

SELECT  
	u.id, 
    u.humanAssist, 
    u.userNumber,
    u.lastActive, 
    u.firstname, 
    u.lastname,
    us.status_id, 

    e.employerName, 
    state.script_id, 
    ss.serviceName

FROM chatproj_usersession u
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN conversation_script_scriptstate state
	ON state.usersession_id = u.id 
LEFT JOIN conversation_script_scriptstep ss
	ON state.script_id = ss.id 

    
WHERE humanAssist = 1



DISQUALIFCATION REASONS 

SELECT 
ud.extra_data, 
substring(ud.extra_data, locate("answer", ud.extra_data)) AS constraintAndParam,
substring(ud.extra_data, locate("parameter", ud.extra_data)) AS parameter,
u.id, 
u.created_at, 
e.employerName,
j.role_id, 
r.title, 
l.name,
l.zipcode_id

FROM chatproj_usersessiondetails ud
LEFT JOIN chatproj_usersession u 
	ON u.id = ud.usersession_id
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id 
LEFT JOIN dashboard_status s
	ON s.id = us.status_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id

WHERE ud.extra_data LIKE '%parameter%' 


AVERAGE ALLYO RESPONSE TIME TO MESSAGES 

SELECT 
	o.id, 
      i.body as incoming,
    o.body as outgoing, 
    o.incomingTrigger_id,
    o.timestamp as allyoresponse, 
    i.timestamp as userresponse,
    timestampdiff(MICROSECOND, i.timestamp, o.timestamp)/1000000 as diff,
    u.userNumber, 
    u.websessionid, 
    e.employerName, 
    r.title, 
    l.name, 
    l.zipCode_id, 
    g.city, 
    g.state

  
    
    
FROM chatproj_outgoingsms o 
LEFT JOIN chatproj_incomingsms i 
	ON i.id = o.incomingTrigger_id
LEFT JOIN chatproj_usersession u 
	ON u.id = o.usersession_id
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id 
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 
LEFT JOIN geocoder_zipcode g 
	ON g.zipcode = l.zipcode_id



WHERE substring(o.timestamp, 1, 4) = '2018'
			  AND i.body != "opened" 
              AND substring(o.body, 1, 12) != "Hi. I'm Ally" 


LIMIT 1000000          


AVERAGE USER RESPONSE TIME TO MESSAGES 

SELECT 
	o.id, 
    i.body as incoming,
    o.body as outgoing, 
    o.incomingTrigger_id,
    o.timestamp as allyoresponse, 
    i.timestamp as userresponse,
    timestampdiff(microsecond, o.timestamp, i.timestamp)/1000000 AS  diff,
    e.employerName, 
    u.id as users, 
    u.websessionid, 
    r.title, 
    l.name, 
    l.zipCode_id, 
     g.city, 
    g.state
  
    
    
FROM chatproj_outgoingsms o 
LEFT JOIN chatproj_incomingsms i 
	ON i.id  = o.incomingTrigger_id + 1
LEFT JOIN chatproj_usersession u 
	ON u.id = o.usersession_id 
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id 
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 
LEFT JOIN geocoder_zipcode g 
	ON g.zipCode = l.zipcode_id



WHERE substring(o.timestamp, 1, 4) = '2018'
			  AND i.body != "opened" 
              AND substring(o.body, 1, 12) != "Hi. I'm Ally" 
              AND o.usersession_id = i.userSession_id
           
           
LIMIT 1000000
		
              


QUICKSIGHT WEB QUERY - ifelse(isNull({websessionid}), "No-Web", "Web") 
              
LINKED APPLICANTS VS NON-LINKED 


SELECT  DISTINCT 
u.id AS userID, 
u.created_at, 
i.body,
jc.id AS JobChoice, 
mj.id AS MatchingID

FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 

WHERE i.body != 'opened'  AND u.locationPreference IS NOT NULL

GROUP BY u.id 

CASE 1: ifelse( isNotNull({JobChoice}) AND  isNull({MatchingID}), 1, 0)
CASE 2: isNotNull({MatchingID})
CASE 3: ifelse( isNull({MatchingID}) AND isNull({JobChoice}), 1, 0)
		



NUMBER OF SCHEDULED INTERVIEWS 

SELECT 
	q.id,
	u.created_at,
	q.usersession_id,
    e.employerName,
    j.role_id,
    r.title, 
    l.name, 
    g.city, 
    g.state 
    
FROM allyo_db.question_selectedinterviewslot q
LEFT JOIN allyo_db.chatproj_usersession u
	ON  u.id = q.usersession_id
LEFT JOIN allyo_db.chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN allyo_db.question_jobreq j 
	ON j.id = q.jobReq_id
LEFT JOIN allyo_db.question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id
LEFT JOIN geocoder_zipcode g 
	ON g.zipcode = l.zipcode_id 


QUALIFIED USERS WITH MJR AND WITHOUT 

SELECT 
	q.parameter, 
    q.usersession_id as QualUsers, 
    u.created_at, 
    mj.userSession_id AS MjrPlusQual
    
FROM question_qualification q 
LEFT JOIN chatproj_usersession u
	ON u.id = q.usersession_id
LEFT JOIN question_matchingjobreq mj
	ON mj.userSession_id = q.userSession_id
    
GROUP BY q.usersession_id 

ENGAGED USERS ANALYSIS 

SELECT 
	u.id, 
	u.created_at, 
	e.employerName,
	i.body,
	us.status_id, 
	j.role_id, 
	r.title,
	l.name as Location, 
	l.zipcode_id, 
	g.zipCode, 
	g.city, 
	g.state

FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.userSession_id = u.id 
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN dashboard_userstatus us
	ON us.usersession_id = u.id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobReq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id 
LEFT JOIN geocoder_zipcode g 
	ON g.zipcode = l.zipCode_id
WHERE body != 'opened' 

GROUP BY u.id 


OVERALL FUNNEL 
		

Quicksight queries: 
	LinkOnly - ifelse( isNotNull({JobChoice}) AND  {isValid} = 1 AND isNull({MatchingID}), 1, 0)
	Users who got to Qualificaitons - isNotNull({MatchingID})
	Dropped Before Choosing a Job - ifelse( isNull({MatchingID}) AND isNull({JobChoice}), 1, 0)
	Disqualified - ifelse( locate({extra_data}, "disqual") <> 0, 1, 0) 
        
    
Table Contents 

Employer Identifier, Employer Name, engaged users, none, jconly, mjr, disqualified

SELECT  
u.id AS engagedUsers, 
u.created_at as Time, 
COUNT(i.body) as NumMessages, 
MAX(i.humanAssist) as HAUsers, 
i.timeStamp, 
e.employerName, 
e.employer_identifier, 
jc.id AS JobChoice, 
jc.isValid, 
mj.id AS MatchingID, 
q.id AS Interviews, 
us.extra_data


FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i
	ON i.usersession_id = u.id 
LEFT JOIN chatproj_employer e
        ON e.id = u.employer_id
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 
LEFT JOIN question_selectedinterviewslot q
	ON q.usersession_id = u.id
LEFT JOIN chatproj_usersessiondetails us 
	ON us.usersession_id = u.id 


WHERE i.body != 'opened'   

GROUP BY u.id

HA ANALYSIS FOR ENGAGED USERS THAT DROPPED OFFED

SELECT   
u.id AS userID, 
u.created_at, 
i.body,
i.humanAssist, 
e.employerName, 
e.employer_identifier, 
jc.id AS JobChoice, 
jc.isValid, 
mj.id AS MatchingID, 
q.id AS interviews, 
us.extra_data


FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN chatproj_employer e
        ON e.id = u.employer_id
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 
LEFT JOIN question_selectedinterviewslot q
	ON q.usersession_id = u.id
LEFT JOIN chatproj_usersessiondetails us 
	ON us.usersession_id = u.id 


WHERE i.body != 'opened'  AND mj.id IS NULL AND jc.id IS NULL AND i.humanAssist = 1 

ORDER BY e.employerName


QUICKSIGHT QUERY FOR HA DROP OFF 

ifelse(locate(toLower({body}), 'how') <> 0 OR locate(toLower({body}), 'where') <> 0 OR locate(toLower({body}), 'what') <> 0 OR locate(toLower({body}), 'why') <> 0 
	OR locate(toLower({body}), 'who') <> 0 OR locate(toLower({body}), '?') <> 0 OR locate(toLower({body}), 'do you') <> 0 OR locate(toLower({body}), 'do i') <> 0 OR 
	locate(toLower({body}), 'can i') <> 0 OR locate(toLower({body}), 'can you') <> 0, {body}, null )

body LIKE '%how%' OR body LIKE '%where%' OR body LIKE '%what%'  OR body LIKE '%why%'  OR body LIKE '%who%' 
		OR body LIKE '%?%' OR body LIKE "%do you%" OR body LIKE "%do I%" OR body LIKE "%can I%" 
                            OR body LIKE "%can you%"

DROPPED USERS QUESTIONS 

SELECT   
u.id AS userID, 
u.created_at, 
i.body,
i.humanAssist, 
e.employerName, 
e.employer_identifier, 
jc.id AS JobChoice, 
jc.isValid, 
mj.id AS MatchingID, 
q.id AS interviews, 
us.extra_data


FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN chatproj_employer e
        ON e.id = u.employer_id
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 
LEFT JOIN question_selectedinterviewslot q
	ON q.usersession_id = u.id
LEFT JOIN chatproj_usersessiondetails us 
	ON us.usersession_id = u.id 


WHERE i.body != 'opened'  AND mj.id IS NULL AND jc.id IS NULL AND (body LIKE '%how%' OR body LIKE '%where%' OR body LIKE '%what%'  OR body LIKE '%why%'  OR body LIKE '%who%' 
		OR body LIKE '%?%' OR body LIKE "%do you%" OR body LIKE "%do I%" OR body LIKE "%can I%" 
                            OR body LIKE "%can you%")


LAST QUESTION WE ASKED TO DROPPED USERS

SELECT   
u.id AS userID, 
u.created_at, 
i.body AS incoming,
o.body AS outgoing, 
o.timestamp,
e.employerName, 
e.employer_identifier, 
jc.id AS JobChoice, 
jc.isValid, 
mj.id AS MatchingID, 
q.id AS interviews, 
us.extra_data


FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN chatproj_outgoingsms o 
	ON o.incomingTrigger_id = i.id
LEFT JOIN chatproj_employer e
        ON e.id = u.employer_id
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 
LEFT JOIN question_selectedinterviewslot q
	ON q.usersession_id = u.id
LEFT JOIN chatproj_usersessiondetails us 
	ON us.usersession_id = u.id 


WHERE i.body  != 'opened'  AND mj.id IS NULL AND jc.id IS NULL AND o.timestamp = (SELECT max(o.timeStamp) FROM chatproj_outgoingsms o WHERE u.id = o.usersession_id )



DROPPED OF USERS STEP 

SELECT   
u.id AS userID, 
u.created_at, 
i.body,
e.employerName, 
e.employer_identifier, 
jc.id AS JobChoice, 
mj.id AS MatchingID, 
ss.currentstep_id, 
s.serviceName




FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN chatproj_outgoingsms o 
	ON o.incomingTrigger_id = i.id
LEFT JOIN chatproj_employer e
        ON e.id = u.employer_id
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 
LEFT JOIN conversation_script_scriptstate ss
	ON ss.userSession_id = u.id 
LEFT JOIN conversation_script_scriptstep s
	ON s.id= ss.currentstep_id


WHERE i.body  != 'opened'  AND mj.id IS NULL AND jc.id IS NULL 

GROUP BY u.id


COMBINATION OF THE ABOVE TWO 


SELECT   
u.id AS userID, 
u.created_at, 
i.body AS incoming,
o.body AS outgoing, 
o.timestamp,
e.employerName, 
e.employer_identifier, 
jc.id AS JobChoice, 
jc.isValid, 
mj.id AS MatchingID, 
q.id as interviews, 
ss.currentstep_id, 
s.serviceName


FROM chatproj_usersession u 
LEFT JOIN chatproj_incomingsms i 
	ON i.usersession_id = u.id 
LEFT JOIN chatproj_outgoingsms o 
	ON o.incomingTrigger_id = i.id
LEFT JOIN chatproj_employer e
        ON e.id = u.employer_id
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 
LEFT JOIN question_selectedinterviewslot q 
	ON 	q.userSession_id = u.id 
LEFT JOIN conversation_script_scriptstate ss
	ON ss.userSession_id = u.id 
LEFT JOIN conversation_script_scriptstep s
	ON s.id= ss.currentstep_id


WHERE i.body  != 'opened'  AND mj.id IS NULL AND jc.id IS NULL AND o.timestamp = (SELECT max(o.timeStamp) FROM chatproj_outgoingsms o WHERE u.id = o.usersession_id )


CUSTOMER SUCCESS TEST FOR SAHIL AND WILLIAM 

SELECT   
u.id AS userID, 
u.created_at, 
u.websessionId, 
e.employerName, 
e.employer_identifier, 
jc.id AS JobChoice, 
mj.id AS MatchingID, 
ss.currentstep_id, 
s.serviceName




FROM chatproj_usersession u 
LEFT JOIN chatproj_employer e
        ON e.id = u.employer_id
LEFT JOIN question_jobchoice jc
	ON jc.usersession_id = u.id 
LEFT JOIN question_matchingjobreq mj
	ON mj.usersession_id = u.id 
LEFT JOIN conversation_script_scriptstate ss
	ON ss.userSession_id = u.id 
LEFT JOIN conversation_script_scriptservicedata s
	ON s.usersession_id = u.id 


WHERE  s.serviceName = "zipcode" OR s.serviceName = "intro_phone" OR s.serviceName = "city_state"


quicksight query for drops - ifelse( isNull({MatchingID}) AND isNull({JobChoice}), "Dropped", "Not Dropped")

WAIT TIME TO SCHEDULE

SELECT
	p.*, 
    us.jobreq_id, 
    u.id as Users, 
    us.connectedOn, 
	timestampdiff(HOUR, us.created_at, p.updated_at )AS waitTime,
    s.tag, 
    e.employerName, 
    r.title, 
    l.name as Location, 
    l.zipcode_id
    

FROM dashboard_applicant_prior_userstatus p 
LEFT JOIN dashboard_userstatus us 
	ON us.id = p.userStatus_id 
LEFT JOIN chatproj_usersession u 
	ON u.id = us.userSession_id
LEFT JOIN dashboard_status s
	ON s.id = p.status_id
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role r
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id
    
WHERE s.tag = 'Interviewed' OR s.tag = 'Scheduled' 
    


WAIT TIME TO INTERVIEW 2.0 (from creation of userSession)

SELECT 

timestampdiff(HOUR, u.created_at, (sis.interviewWeekByMonDate + interval i.dayOfWeek DAY  + interval i.hour HOUR + interval i.minute MINUTE))/24 AS WaitTime ,
u.created_at, 
u.id as UserId, 
us.jobReq_id, 
a.status_id,  
s.tag,
e.employerName, 
j.role_id, 
r.title, 
l.name AS Location, 
l.zipcode_id, 
g.city, 
g.state 



FROM question_selectedinterviewslot sis
LEFT JOIN question_interviewweeklyslot i 
	ON sis.interviewweeklyslot_id = i.id 
LEFT JOIN chatproj_usersession u 
	ON u.id = sis.userSession_id 
LEFT JOIN dashboard_userstatus us 
	ON us.usersession_id = u.id 
LEFT JOIN dashboard_applicant_prior_userstatus a 
	ON a.userStatus_id = us.id 
LEFT JOIN dashboard_status s
	ON s.id = a.status_id 
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id
LEFT JOIN geocoder_zipcode g 
	ON g.zipCode = l.zipcode_id

WHERE e.employerName = "Maggiano's Little Italy" OR 
	   e.employername = "Arby's" OR 
	  e.employername = "Five Guys" OR 
	  e.employername = "Uncle Maddio's" OR 
	  e.employername = "bfresh" OR 
	  e.employername = "Black Angus" OR
	  e.employername = 'Panda' OR
	  e.employername = "Coffeebean" OR
	  e.employername = 'Sprouts' OR 
	  e.employername = 'St. John Knits' OR 
	  e.employername = "Eastside Marketplace" OR
	  e.employername = "Everything Fresh" OR
	  e.employername = 'Speedway' OR 
	  e.employername = "National Safety Apparel" OR
	  e.employername = 'Hilton' OR
	  e.employername = 'Ocean Resort Casino' OR 
	  e.employername = 'Gateway Casinos' OR
	  e.employername = "G4S" OR
	  e.employername = "SBM" OR
	  e.employername = "GQR" OR 
	  e.employername = 'Smile Bbrands' OR 
	  e.employername = 'Smile Brands Inc' OR 
	  e.employername = 'Beacon Health System' OR 
	  e.employername = 'Premise Health' OR 
	  e.employername = "Graham Healthcare Group" OR 
	  e.employername = "TTEC" OR 
	  e.employername = 'LanguageLine Solutions' OR
	  e.employername = 'FiveStar' OR 
	  e.employername = 'Worldwide Express' OR
	  e.employername = "Pitney Bowes" OR
	  e.employername = "eSolutions" OR 
	  e.employername = "SDLC partners" OR 
	  e.employername = "Octagon Talent Solutions" OR 
	  e.employername = "Prophix" OR
	  e.employername = 'FBISD' OR 
	  e.employername = "Anixter" OR 
	  e.employername = "Speedway" OR 
	  e.employername = "AT&T"
    
GROUP BY u.id 

WAIT TIME TO INTERVIEW 3.0 (from when the applicant prior status updated at field became scheduled)


SELECT 

timestampdiff(HOUR, a.updated_at, (sis.interviewWeekByMonDate + interval i.dayOfWeek DAY  + interval i.hour HOUR + interval i.minute MINUTE))/24 AS WaitTime ,
u.id as UserId, 
u.created_at, 
us.jobReq_id, 
a.status_id,  
s.tag,
e.employerName, 
j.role_id, 
r.title, 
l.name AS Location, 
l.zipcode_id



FROM question_selectedinterviewslot sis
LEFT JOIN question_interviewweeklyslot i 
	ON sis.interviewweeklyslot_id = i.id 
LEFT JOIN chatproj_usersession u 
	ON u.id = sis.userSession_id 
LEFT JOIN dashboard_userstatus us 
	ON us.usersession_id = u.id 
LEFT JOIN dashboard_applicant_prior_userstatus a 
	ON a.userStatus_id = us.id 
LEFT JOIN dashboard_status s
	ON s.id = a.status_id 
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id
    
WHERE s.tag = 'Scheduled' AND substring(a.updated_at, 1, 4) = '2018'  
				AND  timestampdiff(HOUR, a.updated_at, (sis.interviewWeekByMonDate + interval i.dayOfWeek DAY  + interval i.hour HOUR + interval i.minute MINUTE)) >0
                

GROUP BY u.id 


CANCELLATIONS AND RESCHEDULES 

SELECT 
	f.*, 
    u.employer_id, 
    e.employerName, 
    j.role_id, 
    r.title, 
    l.name, 
    l.zipcode_id

FROM question_interviewfeedback f
LEFT JOIN chatproj_usersession u 
	ON f.usersession_id = u.id 
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j 
	ON j.id = f.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 


PERCENT OF CANCELLATIONS 

SELECT 
	a.status_id, 
	s.tag, 
	us.jobReq_id, 
	u.id as Users, 
	f.id as CancelsAndReschedules, 
	e.employerName, 
	j.role_id, 
	r.title, 
	l.name AS Location, 
	l.zipCode_id

FROM dashboard_applicant_prior_userstatus a 
LEFT JOIN dashboard_status s 
	ON s.id = a.status_id 
LEFT JOIN dashboard_userstatus us 
	ON us.id = a.userStatus_id
LEFT JOIN chatproj_usersession u 
	ON u.id = us.usersession_ID
LEFT JOIN question_interviewfeedback f 
	ON f.userSession_id = u.id 
LEFT JOIN chatproj_employer e
	ON e.id = u.employer_id
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id
LEFT JOIN question_location l 
	ON l.id = j.location_id 

WHERE s.tag = 'Scheduled'


LOCATIONS BY EMPLOYER

SELECT 
	e.employerName, 
	l.zipcode_id, 
	l.name, 
	g.city, 
	g.state

FROM chatproj_employer e 
LEFT JOIN question_location l
	ON l.employer_id = e.id 
LEFT JOIN geocoder_zipcode g
	ON g.zipcode = l.zipcode_id


WHERE e.employerName = "Maggiano's Little Italy" OR 
	   e.employername = "Arby's" OR 
	  e.employername = "Five Guys" OR 
	  e.employername = "Uncle Maddio's" OR 
	  e.employername = "bfresh" OR 
	  e.employername = "Black Angus" OR
	  e.employername = 'Panda' OR
	  e.employername = "Coffeebean" OR
	  e.employername = 'Sprouts' OR 
	  e.employername = 'St. John Knits' OR 
	  e.employername = "Eastside Marketplace" OR
	  e.employername = "Everything Fresh" OR
	  e.employername = 'Speedway' OR 
	  e.employername = "National Safety Apparel" OR
	  e.employername = 'Hilton' OR
	  e.employername = 'Ocean Resort Casino' OR 
	  e.employername = 'Gateway Casinos' OR
	  e.employername = "G4S" OR
	  e.employername = "SBM" OR
	  e.employername = "GQR" OR 
	  e.employername = 'Smile Bbrands' OR 
	  e.employername = 'Smile Brands Inc' OR 
	  e.employername = 'Beacon Health System' OR 
	  e.employername = 'Premise Health' OR 
	  e.employername = "Graham Healthcare Group" OR 
	  e.employername = "TTEC" OR 
	  e.employername = 'LanguageLine Solutions' OR
	  e.employername = 'FiveStar' OR 
	  e.employername = 'Worldwide Express' OR
	  e.employername = "Pitney Bowes" OR
	  e.employername = "eSolutions" OR 
	  e.employername = "SDLC partners" OR 
	  e.employername = "Octagon Talent Solutions" OR 
	  e.employername = "Prophix" OR
	  e.employername = 'FBISD' OR 
	  e.employername = "Anixter" OR 
	  e.employername = "Speedway" OR 
	  e.employername = "AT&T"






INDUSTRY CALCULATED FIELD  - Quicksight specific 

ifelse({employerName} = "Maggiano's Little Italy" OR 
	   {employerName} = "Arby's" OR 
	   {employerName} = "Five Guys" OR 
	   {employerName} = "Uncle Maddio's" OR 
	   {employerName} = "bfresh" OR 
	   {employerName} = "Black Angus" OR
	   {employerName} = 'Panda' OR
	   {employerName} = "Coffeebean", "Restauarants", 
	   {employerName} = 'Sprouts' OR 
	   {employerName} = 'St. John Knits' OR 
	   {employerName} = "Eastside Marketplace" OR
	   {employerName} = "Everything Fresh" OR
	   {employerName} = 'Speedway' OR 
	   {employerName} = "National Safety Apparel", 'Retail', 
	   {employerName} = 'Hilton' OR
	   {employerName} = 'Ocean Resort Casino' OR 
	   {employerName} = 'Gateway Casinos', "Hospitality", 
	   {employerName} = "G4S" OR
	   {employerName} = "SBM" OR
	   {employerName} = "GQR", "Staffing", 
	   {employerName} = 'Smile Bbrands' OR 
	   {employerName} = 'Smile Brands Inc' OR 
	   {employerName} = 'Beacon Health System' OR 
	   {employerName} = 'Premise Health' OR 
	   {employerName} = "Graham Healthcare Group", "Healthcare", 
	   {employerName} = "TTEC" OR 
	   {employerName} = 'LanguageLine Solutions', 'BPO', 
	   {employerName} = 'FiveStar' OR 
	   {employerName} = 'Worldwide Express' OR
	   {employerName} = "Pitney Bowes", "Logistics",
	   {employerName} = "eSolutions" OR 
	   {employerName} = "SDLC partners" OR 
	   {employerName} = "Octagon Talent Solutions" OR 
	   {employerName} = "Prophix", 'Technology', 
	   {employerName} = 'FBISD',  "Education", "Other")





LINK SOURCES

SELECT 
	u.id, 
	e.employername, 
	us.connectedOn, 
	j.applicationLink, 
	r.title, 
	l.name, 
	g.city, 
	g.state 

FROM chatproj_usersession u 
LEFT JOIN chatproj_employer e 
	ON e.id = u.employer_id 
LEFT JOIN dashboard_userstatus us 
	ON us.userSession_id = u.id 
LEFT JOIN question_jobreq j 
	ON j.id = us.jobreq_id
LEFT JOIN question_role r 
	ON r.id = j.role_id 
LEFT JOIN question_location l 
	ON l.id = j.location_id
LEFT JOIN geocoder_zipcode g 
	ON g.zipCode = l.zipCode_id

WHERE applicationLink IS NOT NULL 


QUICKSIGHT QUERY FOR ALLYO OR EMPLOYER SPECIFIC 

ifelse(locate)


*Tristan Macy
*12/11/2020

*Data Cleaning: 
DATA center_a;
	INFILE "D:\SAS Project\Center A.csv" DLM="," DSD firstobs=2 missover ;
	INPUT id gender age visit score center;
	center=1;
	FORMAT id gender age visit score center;
	RUN;
	PROC PRINT DATA=center_a;
	RUN;



PROC SORT DATA = center_a;
	BY id visit;
RUN;

*Center A Revised Figure 1


DATA center_a_revised;
	SET center_a;
	BY id;
	ARRAY addids{3} score1-score3;
	RETAIN score1-score3;
	IF (FIRST.id) THEN DO i = 1 TO 3;
		addids{i} = .;
	END;
	addids{visit} = score;
	IF (LAST.id);
	ARRAY addidss{3} score1-score3;
	DO ii = 1 TO 3;
		score = addidss{ii};
		visit = ii;
		OUTPUT;
	END;
	
	DROP score1 score2 score3 i ii;
RUN;
	PROC PRINT DATA=center_a_revised;
	RUN;

*Center B Figure 2

DATA center_b;
	INFILE "D:\SAS Project\Center B.dat" firstobs=2 missover;
	INPUT id gender age visit1 visit2 visit3;
	center=2;
	FORMAT id gender age visit score center;
	RUN;
	PROC PRINT DATA=center_b;
	RUN;

*Center B Figure 3
DATA center_b_revised;
	SET center_b;
	ARRAY array{3} visit1 visit2 visit3;
	DO i = 1 TO 3;
		visit = array{i};
		score = visit;
		visit = i;
		OUTPUT;
		
	END;
	DROP visit1 visit2 visit3 i;
RUN;
	PROC PRINT DATA=center_b_revised;
	RUN;

*Concatenation

DATA combined;
	SET center_a_revised center_b_revised;
 RUN;
	PROC PRINT DATA=combined;
	RUN;

	
	
*Exploration


	
PROC FORMAT;
	VALUE agegrp	low-64 = "Adult"
				65-74 = "Senior"
				75-high = "Elderly";

	VALUE	gen		1 = "Female"
				0 = "Male";

	VALUE	vis		0 = " "
				1 = "0 Months"
				2 = "3 Months"
				3 = "6 Months";

	VALUE	cen		1 = "Center A"
				2 = "Center B";
RUN;

*Figure 5

PROC REPORT DATA=combined;
COLUMN visit gender center,(score,(N Mean STD)) tstat;
DEFINE visit / GROUP FORMAT = vis. "Time of Visit";
DEFINE gender / GROUP FORMAT = gen. "Patient Gender" ;
DEFINE center / ACROSS FORMAT = cen. "Center";
DEFINE score / "SAPS-PD Score";
DEFINE N / FORMAT = 2.0;
DEFINE MEAN / FORMAT= 4.2;
DEFINE STD / FORMAT = 4.2;
DEFINE tstat / COMPUTED FORMAT = 4.2 "Welch's t-statistic";
	 COMPUTE tstat;
	 	tstat = (_c4_-_c7_)/(((_c5_**2)/_c3_)+((_c8_**2)/_c6_))**(.5);
		ENDCOMP;
BREAK AFTER visit / SUMMARIZE STYLE = {BACKGROUND = grey};
COMPUTE AFTER visit;
		visit = "";
	ENDCOMP;


RUN;

*Figure 4


PROC REPORT DATA=combined;
COLUMN visit age center,(score,(N Mean STD)) sddiff;
DEFINE visit / GROUP FORMAT = vis. "Time of Visit";
DEFINE age / GROUP FORMAT = agegrp. "Patient Age Group" ;
DEFINE center / ACROSS FORMAT = cen. "Center";
DEFINE score / "SAPS-PD Score";
DEFINE N / FORMAT = 3.0;
DEFINE MEAN / FORMAT= 4.2;
DEFINE STD / FORMAT = 4.2;
DEFINE sddiff / COMPUTED "One Std Dev Diff?";
COMPUTE sddiff / CHARACTER LENGTH = 3;
		IF( (abs(_c4_-_c7_)/_c5_)  >= 1 | (abs(_c4_-_c7_)/_c8_) >= 1) THEN sddiff = "Yes";
		ELSE sddiff = "No";

	 	
		ENDCOMP;

RBREAK AFTER / SUMMARIZE STYLE = {BACKGROUND = grey};



RUN;



RUN;


*Figure 6-8

PROC SORT DATA = combined;
	BY center id;
RUN;


DATA combined_wide;
	SET combined;
	BY center id;
	ARRAY array2{3} score1-score3;
	RETAIN score1-score3;
	IF (FIRST.id) THEN DO i = 1 TO 3;
		array2{i} = .;
	END;
	array2{visit} = score;
	IF (LAST.id) THEN OUTPUT;
LABEL score1 = "Baseline Observation"
	score2 = "3 Month Observation"
	score3= "6 Month Observation";
	DROP score visit i;

	RENAME score1=visit1 score2=visit2 score3=visit3;
	
RUN;
	PROC PRINT DATA=combined_wide Label;

RUN;

PROC FORMAT;
	VALUE sapspd	. = "Lost to Follow-up"
					0-2 = "Low"
					2<-4 = "Moderate"
					4<-high = "Severe";
RUN;

* Baseline vs. 3 Months;
PROC REPORT DATA = combined_wide MISSING;
	COLUMN visit1 N visit2 perlost;
	DEFINE visit1 / GROUP FORMAT = sapspd. "0 Months";
	DEFINE visit2 / ACROSS FORMAT = sapspd. "3 Months";
	DEFINE perlost / COMPUTED "Percent Lost to Follow-up" FORMAT = PERCENT6.1;
	COMPUTE perlost;
		perlost = _c3_ / _c2_;
	ENDCOMP;
RUN;

* Baseline vs. 6 Months;
PROC REPORT DATA = combined_wide MISSING;
	COLUMN visit1 N visit3 perlost;
	DEFINE visit1 / GROUP FORMAT = sapspd. "0 Months";
	DEFINE visit3 / ACROSS FORMAT = sapspd. "6 Months";
	DEFINE perlost / COMPUTED "Percent Lost to Follow-up" FORMAT = PERCENT6.1;
	COMPUTE perlost;
		perlost = _c3_ / _c2_;
	ENDCOMP;
RUN;

* 3 Months vs. 6 Months;
PROC REPORT DATA = combined_wide MISSING;
	COLUMN visit2 N visit3 perlost;
	DEFINE visit2 / GROUP FORMAT = sapspd. "3 Months";
	DEFINE visit3 / ACROSS FORMAT = sapspd. "6 Months";
	DEFINE perlost / COMPUTED "Percent Lost to Follow-up" FORMAT = PERCENT6.1;
	COMPUTE perlost;
		perlost = _c3_ / _c2_;
	ENDCOMP;
RUN;




*PDF CODE;
ODS PDF FILE = "D:\SAS Project\Tristan Macy\Final.pdf";
PROC REPORT DATA=combined;
COLUMN visit gender center,(score,(N Mean STD)) tstat;
DEFINE visit / GROUP FORMAT = vis. "Time of Visit";
DEFINE gender / GROUP FORMAT = gen. "Patient Gender" ;
DEFINE center / ACROSS FORMAT = cen. "Center";
DEFINE score / "SAPS-PD Score";
DEFINE N / FORMAT = 2.0;
DEFINE MEAN / FORMAT= 4.2;
DEFINE STD / FORMAT = 4.2;
DEFINE tstat / COMPUTED FORMAT = 4.2 "Welch's t-statistic";
	 COMPUTE tstat;
	 	tstat = (_c4_-_c7_)/(((_c5_**2)/_c3_)+((_c8_**2)/_c6_))**(.5);
		ENDCOMP;
BREAK AFTER visit / SUMMARIZE STYLE = {BACKGROUND = grey};
COMPUTE AFTER visit;
		visit = "";
	ENDCOMP;


RUN;
PROC REPORT DATA=combined;
COLUMN visit age center,(score,(N Mean STD)) sddiff;
DEFINE visit / GROUP FORMAT = vis. "Time of Visit";
DEFINE age / GROUP FORMAT = agegrp. "Patient Age Group" ;
DEFINE center / ACROSS FORMAT = cen. "Center";
DEFINE score / "SAPS-PD Score";
DEFINE N / FORMAT = 3.0;
DEFINE MEAN / FORMAT= 4.2;
DEFINE STD / FORMAT = 4.2;
DEFINE sddiff / COMPUTED "One Std Dev Diff?";
COMPUTE sddiff / CHARACTER LENGTH = 3;
		IF( (abs(_c4_-_c7_)/_c5_)  >= 1 | (abs(_c4_-_c7_)/_c8_) >= 1) THEN sddiff = "Yes";
		ELSE sddiff = "No";

	 	
		ENDCOMP;

RBREAK AFTER / SUMMARIZE STYLE = {BACKGROUND = grey};



RUN;

PROC REPORT DATA = combined_wide MISSING;
	COLUMN visit1 N visit2 perlost;
	DEFINE visit1 / GROUP FORMAT = sapspd. "0 Months";
	DEFINE visit2 / ACROSS FORMAT = sapspd. "3 Months";
	DEFINE perlost / COMPUTED "Percent Lost to Follow-up" FORMAT = PERCENT6.1;
	COMPUTE perlost;
		perlost = _c3_ / _c2_;
	ENDCOMP;
RUN;

* Baseline vs. 6 Months;
PROC REPORT DATA = combined_wide MISSING;
	COLUMN visit1 N visit3 perlost;
	DEFINE visit1 / GROUP FORMAT = sapspd. "0 Months";
	DEFINE visit3 / ACROSS FORMAT = sapspd. "6 Months";
	DEFINE perlost / COMPUTED "Percent Lost to Follow-up" FORMAT = PERCENT6.1;
	COMPUTE perlost;
		perlost = _c3_ / _c2_;
	ENDCOMP;
RUN;

* 3 Months vs. 6 Months;
PROC REPORT DATA = combined_wide MISSING;
	COLUMN visit2 N visit3 perlost;
	DEFINE visit2 / GROUP FORMAT = sapspd. "3 Months";
	DEFINE visit3 / ACROSS FORMAT = sapspd. "6 Months";
	DEFINE perlost / COMPUTED "Percent Lost to Follow-up" FORMAT = PERCENT6.1;
	COMPUTE perlost;
		perlost = _c3_ / _c2_;
	ENDCOMP;
RUN;
ODS PDF CLOSE;

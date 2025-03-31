/************************************************************************************************************

	EPID 992 Rural-Urban and Mammography Use

	Name: [Yung-Fang Deng]

************************************************************************************************************/
OPTIONS MERGENOBY=warn NODATE NONUMBER FORMCHAR="|----|+|---+=|-/\<>*";
FOOTNOTE "EPID992_Deng.sas run at %SYSFUNC(DATETIME(), DATETIME.) by Yung-Fang Deng";
/******************************* begin program ******************************/

*	Write a LIBNAME statement to load the dataset: nhis_00001.sas7bdat into SAS;
LIBNAME epid992 'C:\Users\yungfang\Desktop\Graduate\UNC_MPH_EPI\EPID 992';

*Check Dataset;
proc contents data=epid992.nhis_2019_2023;
	TITLE 'PROC CONTENTS of nhis_2019_2023';
run;

************************************************************************************************************/
*	Define the format for variables;
PROC FORMAT;
	VALUE Age_NEWf
		1= 'Age<40'
		2= 'Age 40-49'
		3= 'Age 50-59'
		4= 'Age 60-74'
		5= 'Age>75';
	VALUE MA_EVERf
		0= 'Never had a mammogram'
		1= 'Ever had a mammogram'
		2= 'NIU';
	VALUE MA_2YRf
		1= 'Had mammogram within 2 years'
		2= 'Had mammogram in the last 2-5 years'
		3= 'Had mammogram in the last 5-10 years'
		4= 'NIU';
	VALUE MAf
		0= 'No'
		1= 'Yes';
	VALUE MA_Yf
		1= 'Part of routine physical exam/screening'
		2= 'Because of specific breast problem'
		3= 'Other';
	VALUE MA_Nf
		1= 'Did not need/know needed this test'
		2= 'Doctor did not order/say needed'
		3= 'Have not had any problem'
		4= 'Put it off/did not get around to it'
		5= 'Too expensive/no insurance/cost'
		6= 'Too painful, unpleasant, embarrassing'
		7= 'Outside age range'
		8= 'Do not have doctor'
		9= 'Other reason';
	VALUE RUf
		1= 'Large central/fringe metro'
		2= ' Medium and small metro'
		3= ' Nonmetropolitan';
	VALUE REGIONf
		1= 'Northeast'
		2= 'North Central/Midwest'
		3= 'South'
		4= 'West';
	VALUE FEMALEf
		0= 'Male'
		1= 'Female';
	VALUE RACE_ETHf
		1= 'Non-Hispanic White'
		2= 'Non-Hispanic Black'
		3= 'Non-Hispanic others'
		4= 'Hispanic';	
	VALUE Lanf
		1= 'Only speak English'
		2= 'Spanish or others';
	VALUE Eduf
		1= 'Completed high school or less'
		2= 'Some college or technical School'
		3= 'Completed college'
		4= 'Postgraduate or professional degree';
	VALUE Edu_2f
		1= 'Completed high school or less'
		2= 'Completed Some college, technical School, college, or higher';
	Value CAREf
		1= 'Doctor office, health center, VA'
		2= 'Others (emergency, urgent care, other)'
		3= 'No usual place for care';
	VALUE INS_TYPEf
		1= 'Private insurance'
		2= 'Government insurance'
		3= 'Uninsured';
	VALUE INS_STf
		0 = 'No insurance'
		1 = 'Had insurance';
run;


/********************************************************************************
*						     variables for outcome					        	*	
********************************************************************************/
*	Check for any extreme value and distribution of the variable PRENATAL;
PROC FREQ DATA=epid992.nhis_2019_2023;
	TABLE MAMEV MAMLGYRE MAMEV*MAMLGYRE MAMLY MAMYNOEV2YR / missing;
	TITLE 'Mammogram use';
RUN;
** People who answered MEMEV as "NIU,1,7,8,9" will not be asked for the questions of MAMLGYRE(NIU);

DATA data1;
	SET epid992.nhis_2019_2023;	
*	Create a new variable (MA_EVER) as "Ever had a mammogram" indicator; 
	IF MAMEV in (3,7,8,9) THEN MA_EVER=.;
	ELSE IF MAMEV =1 THEN MA_EVER=0;
	ELSE IF MAMEV =2 THEN MA_EVER=1;
	ELSE MA_EVER=2;
*	Create a new variable (MA_2YR) as "Had a mammogram within 2 years" indicator;
	IF MAMLGYRE in (97,98,99) THEN MA_2YR=.;
	ELSE IF MAMLGYRE in (12,22) THEN MA_2YR=1;
	ELSE IF MAMLGYRE in (32,42) THEN MA_2YR=2;
	ELSE IF MAMEV in (0,1,7,8,9)and MAMLGYRE=0 THEN MA_2YR=4;
	ELSE MA_2YR=3;
*	Create a new variable (MA) as "Had a mammogram within 2 years (No/Yes)" indication (this one is for analysis);
	IF MAMEV in (0,2,7,8,9) and MAMLGYRE in (0,97,98,99) THEN MA=.;
	ELSE IF  MAMEV in (1,2) and MAMLGYRE in (0,32,42,52,53) THEN MA=0;
	ELSE IF MAMEV=2 and MAMLGYRE in (12,22) THEN MA=1;
*	Create a new variable (MA_Y) as "reasons for having the most recent mammogram" indicator;
	IF MAMLY in (0,7,8,9) THEN MA_Y=.;
	ELSE IF MAMLY= 1 THEN MA_Y=1;
	ELSE IF MAMLY=2 THEN MA_Y=2;
	ELSE MA_Y=3;
*	Create a new variable (MA_N) as "reasons for not having a mammogram" indicator;
	IF MAMYNOEV2YR in (0,97,98,99) THEN MA_N=.;
	ELSE IF MAMYNOEV2YR in (1,2) THEN MA_N=1;
	ELSE IF MAMYNOEV2YR in (3) THEN MA_N=2;
	ELSE IF MAMYNOEV2YR in (4) THEN MA_N=3;
	ELSE IF MAMYNOEV2YR in (5) THEN MA_N=4;
	ELSE IF MAMYNOEV2YR in (6) THEN MA_N=5;
	ELSE IF MAMYNOEV2YR in (7) THEN MA_N=6;
	ELSE IF MAMYNOEV2YR in (8,9) THEN MA_N=7;
	ELSE IF MAMYNOEV2YR in (10) THEN MA_N=8;
	ELSE IF MAMYNOEV2YR in (11) THEN MA_N=9;

LABEL MA_EVER="Ever had a mammogram (No/Yes)" MA="Had a mammogram within 2 years (No/Yes)" 
	  MA_Y="reasons for having the most recent mammogram" MA_N="Reason why no mammogram in past 2 years";
FORMAT MA_EVER MA_EVERf. MA_2YR MA_2YRf. MA MAf. MA_Y MA_Yf. MA_N MA_Nf.;
RUN;

*Check coding;
PROC FREQ DATA=data1;
	TABLE MA*MAMEV*MAMLGYRE*MA_2YR*MA_EVER / LIST MISSING;
	TITLE 'Outcomes';
RUN;

PROC FREQ data=data1;
	TABLE MA_Y*MAMLY MA_N*MAMYNOEV2YR /LIST MISSING;
RUN;

/********************************************************************************
*						     variables for exposure					        	*	
********************************************************************************/
*	Check for any extreme value and distribution of the variable;
PROC FREQ data=data1;
	TABLES URBRRL;
	TITLE 'RURAL-URBAN';
RUN;

DATA data2;
	SET data1;
	IF URBRRL in (1,2) THEN RU=1;
	ELSE IF URBRRL=3 THEN RU=2;
	ELSE RU=3;
*	Assign format to "rural-urban classification" indicator; 
LABEL RU="RURAL-URBAN";
FORMAT RU RUf.;
RUN;

*Check coding;
PROC FREQ data=data2;
	TABLES URBRRL*RU;
	TITLE 'Exposure';
RUN;


/********************************************************************************
*						     Variables for covariates					       	*	
********************************************************************************/
*	Check for any extreme value and distribution of the variables;
PROC FREQ data=data2;
	TABLES AGE REGION SEX HISPRACE INTERVLANG EDUC TYPPLSICK USUALPL HINOTCOVE COVERTYPE COVERTYPE65;
RUN;

DATA data3;
	SET data2;
*	Create a new variable (Age_NEW) as "Age" indicator;
	IF AGE in (997,999) THEN Age_NEW=.;
	ELSE IF AGE<40 THEN Age_NEW=1;
	ELSE IF AGE<50 THEN Age_NEW=2;
	ELSE IF AGE<60 THEN Age_NEW=3;
	ELSE IF AGE<75 THEN Age_NEW=4;
	ELSE Age_NEW=5;
*	Create a new variable (FEMALE) as "Sex" indicator;
	IF SEX in (7,8,9) THEN FEMALE=.;
	ELSE IF SEX=1 THEN FEMALE=0;
	ELSE FEMALE=1;
*	Create a new variable (RACE_ETH) as "race/ethnicity" indicator;
	IF HISPRACE=2 THEN RACE_ETH=1;
	ELSE IF HISPRACE=3 THEN RACE_ETH=2;
	ELSE IF HISPRACE in (4,5,6,7) THEN RACE_ETH=3;
	ELSE RACE_ETH=4;
*	Create a new variable (Lan) as "Language" indicator;
	IF INTERVLANG=0 THEN Lan=.;
	ELSE IF INTERVLANG=1 THEN Lan=1;
	ELSE Lan=2;
*	Create a new variable (Edu) as "Education" indicator;
	IF EDUC in (0,997,999) THEN Edu=.;
	ELSE IF EDUC in (102,103,116,201,202) THEN Edu=1;
	ELSE IF EDUC in (301,302,303) THEN Edu=2;
	ELSE IF EDUC =400 THEN Edu=3;
	ELSE Edu=4;
*	Create a new variable (Edu_2) as indicator for analysis;
	IF Edu=. THEN Edu_2=.;
	ELSE IF Edu=1 THEN Edu_2=1;
	ELSE Edu_2=2;
*	Create a new variable (CARE) as "Kind of usual place for medical care" indicator;
	IF TYPPLSICK in (480,500,997,998,999) THEN CARE=.;
	ELSE IF TYPPLSICK in (130,450) THEN CARE=1;
	ELSE IF TYPPLSICK=0 THEN CARE=3;
	ELSE CARE=2;
*	Create a new variable (INS_TYPE) as "Health insurance coverage type" indicator;
	IF COVERTYPE= 5 or COVERTYPE65=7 THEN INS_TYPE=.;
	ELSE IF COVERTYPE= 0 and COVERTYPE65=0 THEN INS_TYPE=.;
	ELSE IF COVERTYPE =1 or COVERTYPE65 in (1,3) THEN INS_TYPE=1;
	ELSE IF COVERTYPE in (2,3) or COVERTYPE65 in (2,4,5) THEN INS_TYPE=2;
	ELSE INS_TYPE=3;
*	Create a new variable (INS_ST) as "Health insurance coverage status" indicator;
	IF HINOTCOVE =9 THEN INS_ST=.;
	ELSE IF HINOTCOVE =2 THEN INS_ST=0;
	ELSE INS_ST=1;

LABEL FEMALE = "sex" RACE_ETH = "Race/Ethnicity" Lan= "Language" Edu="Education attainment"
	  Edu_2="Education attainment" CARE="Kind of usual place for medical care" INS_TYPE="Health insurance coverage type" 
	  INS_ST="Health insurance coverage statu";
FORMAT Age_NEW Age_NEWf. REGION REGIONf. FEMALE FEMALEf. RACE_ETH RACE_ETHf. Lan Lanf. 
	   Edu Eduf. Edu_2 Edu_2f. CARE CAREf. INS_TYPE INS_TYPEf. INS_ST INS_STf.;

RUN;


*Check coding;
PROC FREQ data=data3;
	TABLES Age_NEW*AGE SEX*FEMALE HISPRACE*RACE_ETH INTERVLANG*Lan EDUC*Edu Edu*Edu_2 
		   COVERTYPE*INS_TYPE HINOTCOVE*INS_ST;
	TITLE 'Covariates';
RUN;

PROC FREQ data=data3;tables INS_TYPE*COVERTYPE*COVERTYPE65 CARE*TYPPLSICK*USUALPL/list missing;run;
 
/********************************************************************************
*							Constructing Table 1								*	
********************************************************************************/
***	Population of analysis;
*	Restrict to age 40-74, female, southern region, as well as having outcome data (n=27,371);
DATA data_2019_2023;
	SET data3;
	Where age_new in (2,3,4) and Female=1 and MA~=.;
run;

*Check code;
PROC FREQ data=data_2019_2023;TABLES age_new female MA;run;

*	Missing data for exposure: 0;
PROC FREQ data=data_2019_2023; TABLES RU;run;

*	Missing data for covariates: eduction (n=117), care (n=215), Insurance status (n=36), insurance type (n=45);
PROC FREQ data=data_2019_2023; TABLES Region Edu_2 CARE INS_ST INS_TYPE race_eth;run;


***	Table 1;
/*****Total cohort*****/
proc freq data=data_2019_2023;
	tables age_new RACE_ETH Edu_2 INS_ST INS_TYPE CARE region/ nocum missprint;
	title "Table 1 - categorical covariates";
run;


/******By RU*****/
proc sort data=data_2019_2023;by RU;run;

proc freq data=data_2019_2023;
	by RU;
	tables age_new RACE_ETH Edu_2 INS_ST INS_TYPE CARE region/ nocum missprint;
	title "Table 1 - categorical covariates";
run;


/********************************************************************************
*								Main analysis 									*	
********************************************************************************/
*	N;
proc freq data=data_2019_2023;tables RU/nocum missprint;run;

*	Prevalence (%);
proc sort data=data_2019_2023;by RU;run;
proc freq data=data_2019_2023;
	tables MA / nocum missprint;
	by RU;
run;

* prevalence diff;
/*ODS trace on/off: for finding the wanted output*/
proc genmod data = data_2019_2023 DESCENDING ;
	class RU;
	model MA = RU / link = identity dist = binomial;
	title 'Linear-Risk Model for Mammogram Use';
run;


/********************************************************************************
*							Stratified analysis 								*	
********************************************************************************/
*	Macro (prevalence, prevalence diff;
%macro main_LR_model(dataset= );
PROC SORT DATA=&dataset; BY RU;
PROC FREQ DATA=&dataset;
	TABLES MA / nocum;
	BY RU;
	TITLE "Prevalence by &dataset";
run;

ODS SELECT ParameterEstimates;
PROC GENMOD DATA=&dataset DESCENDING;
	CLASS RU;
	MODEL MA=RU / link = identity dist = binomial;
	TITLE "Prevalence diff";
	TITLE2 "Stratified by &dataset";

RUN;
QUIT;
	
RUN;
%mend main_LR_model;

*	Construct sub-group;
DATA data_2019 data_2021 data_2023 /*for analysis stratified by year*/
	data_2019_W data_2019_B data_2019_O data_2019_H 
	data_2021_W data_2021_B data_2021_O data_2021_H 
	data_2023_W data_2023_B data_2023_O data_2023_H  /*for analysis stratified by race/eth in each year*/
	INS_N INS_Y INS_PRI INS_GOV INS_UN EDU_H EDU_C CARE_DOC CARE_ER CARE_NO REG_N REG_M REG_S REG_W 
	RACE_ETH_W RACE_ETH_B RACE_ETH_O RACE_ETH_H; /*for analysis in 2019-2023 by covariates*/
	SET data_2019_2023;

	IF YEAR=2019 then OUTPUT data_2019;
	IF YEAR=2021 then OUTPUT data_2021;
	IF YEAR=2023 then OUTPUT data_2023;
	IF YEAR=2019 and RACE_ETH=1 then OUTPUT data_2019_W;
	IF YEAR=2019 and RACE_ETH=2 then OUTPUT data_2019_B;
	IF YEAR=2019 and RACE_ETH=3 then OUTPUT data_2019_O;
	IF YEAR=2019 and RACE_ETH=4 then OUTPUT data_2019_H;
	IF YEAR=2021 and RACE_ETH=1 then OUTPUT data_2021_W;
	IF YEAR=2021 and RACE_ETH=2 then OUTPUT data_2021_B;
	IF YEAR=2021 and RACE_ETH=3 then OUTPUT data_2021_O;
	IF YEAR=2021 and RACE_ETH=4 then OUTPUT data_2021_H;
	IF YEAR=2023 and RACE_ETH=1 then OUTPUT data_2023_W;
	IF YEAR=2023 and RACE_ETH=2 then OUTPUT data_2023_B;
	IF YEAR=2023 and RACE_ETH=3 then OUTPUT data_2023_O;
	IF YEAR=2023 and RACE_ETH=4 then OUTPUT data_2023_H;
	IF REGION=1 then OUTPUT REG_N;
	IF REGION=2 then OUTPUT REG_M;
	IF REGION=3 then OUTPUT REG_S;
	IF REGION=4 then OUTPUT REG_W;
	IF INS_ST=0 then OUTPUT INS_N;
	IF INS_ST=1 then OUTPUT INS_Y;
	IF INS_TYPE=1 then OUTPUT INS_PRI;
	IF INS_TYPE=2 then OUTPUT INS_GOV;
	IF INS_TYPE=3 then OUTPUT INS_UN;
	IF Edu_2=1 then OUTPUT EDU_H;
	IF Edu_2=2 then OUTPUT EDU_C;
	IF CARE=1 then OUTPUT CARE_DOC;
	IF CARE=2 then OUTPUT CARE_ER;
	IF CARE=3 then OUTPUT CARE_NO;
	IF RACE_ETH=1 then OUTPUT RACE_ETH_W;
	IF RACE_ETH=2 then OUTPUT RACE_ETH_B;
	IF RACE_ETH=3 then OUTPUT RACE_ETH_O;
	IF RACE_ETH=4 then OUTPUT RACE_ETH_H;

RUN;

DATA REG_N_W REG_N_B REG_N_O REG_N_H; /*for analysis stritified by race/eth in North*/
	SET REG_N;
	IF RACE_ETH=1 then OUTPUT REG_N_W;
	IF RACE_ETH=2 then OUTPUT REG_N_B;
	IF RACE_ETH=3 then OUTPUT REG_N_O;
	IF RACE_ETH=4 then OUTPUT REG_N_H;
RUN;

DATA REG_M_W REG_M_B REG_M_O REG_M_H; /*for analysis stratified by race/eth in Mid*/
	SET REG_M;
	IF RACE_ETH=1 then OUTPUT REG_M_W;
	IF RACE_ETH=2 then OUTPUT REG_M_B;
	IF RACE_ETH=3 then OUTPUT REG_M_O;
	IF RACE_ETH=4 then OUTPUT REG_M_H;
RUN;

DATA REG_S_W REG_S_B REG_S_O REG_S_H; /*for analysis stratified by race/eth in South*/
	SET REG_S;
	IF RACE_ETH=1 then OUTPUT REG_S_W;
	IF RACE_ETH=2 then OUTPUT REG_S_B;
	IF RACE_ETH=3 then OUTPUT REG_S_O;
	IF RACE_ETH=4 then OUTPUT REG_S_H;
RUN;

DATA REG_W_W REG_W_B REG_W_O REG_W_H; /*for analysis stratified by race/eth in West*/
	SET REG_W;
	IF RACE_ETH=1 then OUTPUT REG_W_W;
	IF RACE_ETH=2 then OUTPUT REG_W_B;
	IF RACE_ETH=3 then OUTPUT REG_W_O;
	IF RACE_ETH=4 then OUTPUT REG_W_H;
RUN;

DATA AGE_1 AGE_2 AGE_3;/*for analysis stratified by age*/
	SET data_2019_2023;
	IF Age_NEW=2 then OUTPUT AGE_1;
	IF Age_NEW=3 then OUTPUT AGE_2;
	IF Age_NEW=4 then OUTPUT AGE_3;
RUN;

*Check coding;
proc freq data=data_2019;tables year;run;
proc freq data=data_2021;tables year;run;
proc freq data=data_2023;tables year;run;
proc freq data=INS_N;tables INS_ST;run;
proc freq data=INS_Y;tables INS_ST;run;
proc freq data=INS_PRI;tables INS_TYPE;run;
proc freq data=INS_GOV;tables INS_TYPE;run;
proc freq data=INS_UN;tables INS_TYPE;run;
proc freq data=EDU_H;tables Edu_2;run;
proc freq data=EDU_C;tables Edu_2;run;
proc freq data=CARE_DOC;tables CARE;run;
proc freq data=CARE_ER;tables CARE;run;
proc freq data=CARE_NO;tables CARE;run;
proc freq data=REG_N;tables REGION;run;
proc freq data=REG_M;tables REGION;run;
proc freq data=REG_S;tables REGION;run;
proc freq data=REG_W;tables REGION;run;
proc freq data=RACE_ETH_W;tables RACE_ETH;run;
proc freq data=RACE_ETH_B;tables RACE_ETH;run;
proc freq data=RACE_ETH_O;tables RACE_ETH;run;
proc freq data=RACE_ETH_H;tables RACE_ETH;run;

proc freq data=data_2019_W;tables year race_eth;run;
proc freq data=data_2019_B;tables year race_eth;run;
proc freq data=data_2019_O;tables year race_eth;run;
proc freq data=data_2019_H;tables year race_eth;run;
proc freq data=data_2021_W;tables year race_eth;run;
proc freq data=data_2021_B;tables year race_eth;run;
proc freq data=data_2021_O;tables year race_eth;run;
proc freq data=data_2021_H;tables year race_eth;run;
proc freq data=data_2023_W;tables year race_eth;run;
proc freq data=data_2023_B;tables year race_eth;run;
proc freq data=data_2023_O;tables year race_eth;run;
proc freq data=data_2023_H;tables year race_eth;run;
proc freq data=REG_N_W;tables region race_eth;run;
proc freq data=REG_N_B;tables region race_eth;run;
proc freq data=REG_N_O;tables region race_eth;run;
proc freq data=REG_N_H;tables region race_eth;run;
proc freq data=REG_M_W;tables region race_eth;run;
proc freq data=REG_M_B;tables region race_eth;run;
proc freq data=REG_M_O;tables region race_eth;run;
proc freq data=REG_M_H;tables region race_eth;run;
proc freq data=REG_S_W;tables region race_eth;run;
proc freq data=REG_S_B;tables region race_eth;run;
proc freq data=REG_S_O;tables region race_eth;run;
proc freq data=REG_S_H;tables region race_eth;run;
proc freq data=REG_W_W;tables region race_eth;run;
proc freq data=REG_W_B;tables region race_eth;run;
proc freq data=REG_W_O;tables region race_eth;run;
proc freq data=REG_W_H;tables region race_eth;run;

proc freq data=age_1;tables age_new;run;
proc freq data=age_2;tables age_new;run;
proc freq data=age_3;tables age_new;run;

*	Prevalence diff - 2019-2023, whole US;
%main_LR_model(dataset=RACE_ETH_W)
%main_LR_model(dataset=RACE_ETH_B)
%main_LR_model(dataset=RACE_ETH_O)
%main_LR_model(dataset=RACE_ETH_H)
%main_LR_model(dataset=INS_N)
%main_LR_model(dataset=INS_Y)
%main_LR_model(dataset=INS_PRI)
%main_LR_model(dataset=INS_GOV)
%main_LR_model(dataset=INS_UN)
%main_LR_model(dataset=EDU_H)
%main_LR_model(dataset=EDU_C)
%main_LR_model(dataset=CARE_DOC)
%main_LR_model(dataset=CARE_ER)
%main_LR_model(dataset=CARE_NO)

%main_LR_model(dataset=REG_N)
%main_LR_model(dataset=REG_M)
%main_LR_model(dataset=REG_S)
%main_LR_model(dataset=REG_W)
%main_LR_model(dataset=data_2019)
%main_LR_model(dataset=data_2021)
%main_LR_model(dataset=data_2023)

%main_LR_model(dataset=REG_N_W)
%main_LR_model(dataset=REG_N_B)
%main_LR_model(dataset=REG_N_O)
%main_LR_model(dataset=REG_N_H)
%main_LR_model(dataset=REG_M_W)
%main_LR_model(dataset=REG_M_B)
%main_LR_model(dataset=REG_M_O)
%main_LR_model(dataset=REG_M_H)
%main_LR_model(dataset=REG_S_W)
%main_LR_model(dataset=REG_S_B)
%main_LR_model(dataset=REG_S_O)
%main_LR_model(dataset=REG_S_H)
%main_LR_model(dataset=REG_W_W)
%main_LR_model(dataset=REG_W_B)
%main_LR_model(dataset=REG_W_O)
%main_LR_model(dataset=REG_W_H)
%main_LR_model(dataset=data_2019_W)
%main_LR_model(dataset=data_2019_B)
%main_LR_model(dataset=data_2019_O)
%main_LR_model(dataset=data_2019_H)
%main_LR_model(dataset=data_2021_W)
%main_LR_model(dataset=data_2021_B)
%main_LR_model(dataset=data_2021_O)
%main_LR_model(dataset=data_2021_H)
%main_LR_model(dataset=data_2023_W)
%main_LR_model(dataset=data_2023_B)
%main_LR_model(dataset=data_2023_O)
%main_LR_model(dataset=data_2023_H)

%main_LR_model(dataset=age_1)
%main_LR_model(dataset=age_2)
%main_LR_model(dataset=age_3)

/********************************************************************************
*						 Analysis for reasons									*	
********************************************************************************/
*	Sample size for "ever had mammogram": 24,735
	Missing data for "MA_Y": 14
	Sample size for "ever had but not within 2 yr & never had": 7,336
	Missing data for "MA_N": 2,615;
proc freq data=data_2019_2023;tables MA_EVER MA_EVER*MA_Y MA MA*MA_N;run;

/*****Total cohort*****/
proc freq data=data_2019_2023;
	tables MA_Y MA_N / nocum missprint;
run;

/******By RU*****/
proc sort data=data_2019_2023;by RU;run;

proc freq data=data_2019_2023;
	by RU;
	tables MA_Y MA_N / nocum missprint;
	title "Table 4";
run;

proc freq data=data_2019_2023;tables RU;where MA_N~=.;run;
proc freq data=data_2019_2023;tables RU;where MA_Y~=.;run;

/********************************************************************************
*						Supplemental analysis by race/eth						*	
********************************************************************************/

proc freq data=data_2019_2023;tables HISPRACE;run;

DATA race_A race_In;
	set data_2019_2023;
	IF HISPRACE=4 then OUTPUT race_A;
	IF HISPRACE in (5,6) then OUTPUT race_In;
run;

%main_LR_model(dataset=race_A)
%main_LR_model(dataset=race_In)

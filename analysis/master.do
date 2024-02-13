* **********************************************************************
* Project: multigrade_schools_peru
* Created: FEB 2024
* Stata v.16.1

* Note: If necessary, I edit file path to the project in config.do
* All subsequent files are referred to using dynamic, absolute filepaths
* This file assumes that the globals to root folders have been changed
* in scripts/0_setup.do
* **********************************************************************
* 0 - General setup
* **********************************************************************

* Specify Stata version in use
    global stataVersion 16.1    // set Stata version
    version `$stataVersion'

* Set graph and Stata preferences
    *set scheme plotplain

* Run 0_setup.do - set where setup file is. Must change root globals in scripts/0_setup.do before running. 
* To see username, in Stata, type: dis "`c(username)'"

if "`c(username)'" == "YYY" { 
	include "~/Documents/GitHub/PROJECT/analysis/scripts/stata/0_setup.do"   /* Input your git project folder location*/
}

if "`c(username)'" == "Usuario" { 
	include "~/0_git/multigrade_schools_peru/analysis/scripts/stata/0_setup.do"   /* Input your git project folder location*/
}

**********************************************************************
* 1 - Run code
* **********************************************************************

*Cleaning
 include "${stata}/1_cleaning.do"

 *Regressions
 *include "${stata}/2_regressions.do"

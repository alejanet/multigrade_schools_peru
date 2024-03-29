*=======================================================*
*	 		Import raw school data
*=======================================================*
use 			"$censo/padron.dta", clear 
*Primary schools
keep if 		niv_mod=="B0"
*Multigrade schools
keep if 		cod_car=="1" | cod_car=="2"
*Rural schools
keep if 		area_censo=="2"
*Public schools
keep if 		ges_dep=="A1" | ges_dep=="A2" | ges_dep=="A3" | ges_dep=="A4" 

*Monolingual schools 
preserve
	import 		excel "$censo\Registro Nacional IIEE_EIB_2022.xlsx", cellrange(a2:r28186) firstrow clear
	keep 		FormadeatenciónEIB Estado Códigomodular Anexo
	rename 		(FormadeatenciónEIB Estado Códigomodular Anexo) (f_atencion estado cod_mod anexo)
	save 		"$censo\eib_primaria22", replace
restore 		

merge 1:1 		cod_mod anexo using "$censo\eib_primaria22", keepusing(f_atencion estado)
drop if 		_merge==2
drop 			_merge
*we keep monolingual schools
drop if 		estado!="" // eib==1

merge m:1 		codgeo using "$data\censo_espa", keep(3) nogen

*in order to get a clean merge, we correct misspelling
preserve
	collapse 	(count) tdocente, by(dpto prov)
	replace 	prov="MARAÑON" if strpos(prov, "MARA") & dpto=="HUANUCO"
	replace 	prov="DATEM DEL MARAÑON" if strpos(prov, "MARA") & dpto=="LORETO"
	replace 	prov="FERREÑAFE" if strpos(prov, "FERRE") & dpto=="LAMBAYEQUE"
	replace 	prov="CAÑETE" if strpos(prov, "ETE") & dpto=="LIMA"

	tempfile 	peprov_multig																				
	save 		`peprov_multig'	
restore

* Number multigrade schools per region
preserve 
	collapse 	(count) tdocente, by(dpto )
	tempfile 	pedpto_multig																				
	save 		`pedpto_multig'		
restore

*=======================================================*
*	 			Maps showing provinces
*=======================================================*
*read as .dta
*spshape2dta 	"$censo\PROVINCIAS_inei_geogpsperu_suyopomalia"
*spshape2dta 	"$censo\DEPARTAMENTOS_inei_geogpsperu_suyopomalia"

use 			"$censo\PROVINCIAS_inei_geogpsperu_suyopomalia.dta", clear
rename 			(NOMBDEP NOMBPROV) (dpto prov)

merge 1:1 		dpto prov using `peprov_multig'	// we bring var tdocente (number of schools)
replace 		tdocente=0 if _merge!=3			// provinces with zero multigrade schools==0
drop 			_merge

*********** Individual maps showing provinces of 4 regions ************
foreach z 		in CUSCO AREQUIPA MOQUEGUA CAJAMARCA {
preserve
				keep if 	dpto=="`z'"
				spmap 		tdocente using "$censo\PROVINCIAS_inei_geogpsperu_suyopomalia_shp.dta", id(_ID) fcolor(YlGnBu) ///
							label(xcoord(_CX) ycoord(_CY) label(prov) size(small) position(0 6) length(26) ) ///
							legend(pos(7) ring(1)  size(*1.5) ) legstyle(2)  legtitle("Cantidad de escuelas por provincia") 
				graph 		save "$figures/map_prov_`z'", replace
restore		
}

*********** Unique map showing provinces and regions of Peru ************
*add boundaries
*add centroides for dpto
rename 			(_CX _CY) (_CXprov _CYprov)
rename 			dpto NOMBDEP 
merge m:1 		NOMBDEP  using "$censo\DEPARTAMENTOS_inei_geogpsperu_suyopomalia.dta", keepusing(_CX _CY) // traemos nombres de dpto
keep if 		_merge==3
drop 			_merge

spmap 			tdocente using "$censo\PROVINCIAS_inei_geogpsperu_suyopomalia_shp.dta", id(_ID) fcolor(YlGnBu) clmethod(c) ///
				label(xcoord(_CX) ycoord(_CY) label(NOMBDEP) size(vsmall) position(0 6) length(26) angle(45) color(black)) ///
				legend(pos(7) ring(1)  size(*1.5))  polygon(data("$censo\DEPARTAMENTOS_inei_geogpsperu_suyopomalia_shp.dta") ocolor(gs3) osize(vthin ..) ) ocolor(gs10 ..) osize(vvthin ..) ///
				clbreaks(0 2 24 89 164 506) legstyle(2) legtitle("Cantidad de escuelas por provincia") ///
				legend(label(2 "0 - 2") label(3 "2 - 24" ) label(4 "24 - 89" )  label(5 "89 - 164" )  label(6 "164 - 506" ))
graph	 		save "$figures/map_prov_peru", replace

*=======================================================*
*	 				Map showing regions
*=======================================================*	
use 			"$censo\DEPARTAMENTOS_inei_geogpsperu_suyopomalia.dta", clear
rename 			NOMBDEP  dpto 

merge 1:1 		dpto  using `pedpto_multig'				// we bring var tdocente (number of schools)
replace 		tdocente=0 if _merge!=3					// CALLAO==0
drop 			_merge		
		
spmap 			tdocente using "$censo\DEPARTAMENTOS_inei_geogpsperu_suyopomalia_shp.dta", id(_ID) fcolor(YlGnBu)  ///
				label(xcoord(_CX) ycoord(_CY) label(dpto) size(vsmall) position(0 6) length(26) angle(45) color(black)) ///
				legend( pos(7) ring(1)  size(*1.5))   ocolor(gs3 ..) osize(thin ..) ///
				legstyle(2) legtitle("Cantidad de escuelas por region")
graph	 		save "$figures/map_reg_peru", replace

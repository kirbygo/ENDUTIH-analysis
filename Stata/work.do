*Preamble
*Cambio directorio
* Prueba si el escritorio está en C o en D y establece el necesario
clear all
cap cd "D:\Users\\`c(username)'\Desktop"
if _rc != 0 {
	cd "C:\Users\\`c(username)'\Desktop" 
	*cap ^ else if _rc != 0 {cd "E:\Users\\`c(username)'\Desktop" }
}
*Crear carpeta "Work" en Escritorio
cap mkdir UN_2
cd UN_2

*El directorio base: Carpeta Work en Escritorio
global dir : pwd
cd $dir


*************************************************************** DATA DOWNLOADING
************************************************************************ ENDUTIH
*Descarga de información
*Bajar info de la INEGI, 2018. Y unzip
cap mkdir data
cd data

forvalues i = 2015/2019 {
	copy "https://www.inegi.org.mx/contenidos/programas/dutih/`i'/microdatos/dutih`i'_bd_dbf.zip" "dutih`i'_bd_dbf.zip"
	copy "https://www.inegi.org.mx/contenidos/programas/dutih/`i'/doc/dutih`i'_fd.xlsx" "dutih`i'_fd.xlsx"
	unzipfile dutih`i'_bd_dbf.zip, replace
}
cd $dir

*************************************************************************** INPC
*Bajar INPC del INEGI
cap mkdir inpc
cd inpc
*Entramos aquí:
*https://www.inegi.org.mx/app/indicesdeprecios/Estructura.aspx?idEstructura=112001200090&T=%C3%8Dndices%20de%20Precios%20al%20Consumidor&ST=Clasificaci%C3%B3n%20del%20consumo%20individual%20por%20finalidades(CCIF)%20(quincenal)
*Y descargamos lo que queremos, en excel para quitarle a mano el metadato
*Lo metemos ahí en esa carpetiux
*Es más fácil y rápido que la API, dado que solo es 1 descarga. La mera neta, mano
cd $dir

************************************************************************ BIT IFT
*Bajar BIT del IFT
cap mkdir suscrip
cd suscrip
*lineas telefonía fija
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_LINEAS_HIST_TELFIJA_ITE_VA.csv" "lin_tel_fija.csv"
*acceso internet banda ancha fija
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_ACC_INTER_HIS_ITE_VA.csv" "acc_int_fija.csv"
*acceso tv restringida
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_ACC_TVRES_HIS_ITE_VA.csv" "acc_tv_rest.csv"
*lineas telefonía movil
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_LINEAS_HIST_TELMOVIL_ITE_VA.csv" "lin_tel_mov.csv"
*lineas internet movil
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_LINEAS_HIST_INTMOVIL_ITE_VA.csv" "lin_int_mov.csv"
*acceso a banda ancha fija por velocidad
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_ACC_BAFXV_ITE_VA.csv" "acc_int_fija_por_vel.csv"
*market share TV restringida
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_MARKET_SHARE_TVRES_ITE_VA.csv" "tv_rest_mkt_shr.csv"
*suscriptores TV restringida
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_SUS_TVRES_ITE_VA.csv" "sus_tv_rest.csv"
*suscripciones Banda ancha fija
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_SUS_BAF_ITE_VA.csv" "sus_int_fija.csv"
*OJO. Parece ser que ya no funciona programático ahora :(
*Habrá de hacerse manualmente :(
*Te odio IFT !!!

cd $dir


****************************************************************** DATA CLEANING
*generar directorio donde guarde las bases "limpias"
cd $dir
cap mkdir "db"
************************************************************************ ENDUTIH
* Una vez descargadas las bases HAY QUE PASARLAS A DTA pues en dbf 
* cuando lo importa a stata genera missings sin sentido
* Otros diversos ajustes manuales de bases
* Imposible importar bien DBFs, se hizo con Stat-Transfer
* Te odio STATA!
* Las guardo en .dta en la carpeta db
* Sin embargo, todo está en string. Igual las tenemos que limpiar, Esperancita!

*Importar la base
use "$dir\db\2015-hogares", clear
destring D_R EST_DIS P* UPM_DIS VIV_SEL aream ent hogar nreninfo upm, replace
*rename
*save

*...


*************************************************************************** INPC
clear all
cd $dir
cap mkdir inpc
import excel "inpc\inpc.xls", sheet("stata") firstrow

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Ojo, la info es quincenal
*La fecha real puede usarse como tsset
gen date = datereal
format date %td
gen count = date

save "db\inpc.dta", replace
************************************************************************ BIT IFT
clear all
cd $dir
cap mkdir ift

***********************************1
clear all
import delimited "suscrip\acc_int_fija.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Ojo, la info es mensual
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 2000 a 2012 es ANUAL. De 2013 a 2019 es MENSUAL
duplicates r date k_acceso_internet
*Info por k_acceso_internet

save "ift\acc_int_fija.dta", replace

***********************************2
clear all
import delimited "suscrip\acc_int_fija_por_vel.csv", parselocale(es_MX) 
rename anio year
rename mes month

gen datereal = date(string(month)+"/"+string(year),"MY")
format datereal %td
*Ojo, la info es mensual
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 2013 a 2019 es MENSUAL
duplicates r date concesionario
*Info por concesionario

save "ift\acc_int_fija_por_vel.dta", replace

***********************************3
clear all
import delimited "suscrip\acc_tv_rest.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Ojo, la info es trimestral de 1996 a 2012
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 1996 a 2012 es TRIMESTRAL. De 2013 a 2019 es MENSUAL
duplicates r date concesionario k_acceso k_entidad
*Info por concesionario, tipo de acceso y entidad

save "ift\acc_tv_rest.dta", replace

***********************************4
clear all
import delimited "suscrip\lin_int_mov.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Ojo, la info es trimestral de 2010 a junio de 2013
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 2010 a junio de 2013 es TRIMESTRAL. De junio de 2013 a 2019 es MENSUAL
duplicates r date concesionario
*Info por concesionario o empresa

save "ift\lin_int_mov.dta", replace

***********************************5
clear all
import delimited "suscrip\lin_tel_fija.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 1971 a 1991 es ANUAL nacional.
* De 1992 a 1999 es anual por estado.
* De 2000 a 2019 es mensual por estado.
duplicates r date concesionario entidad
*Info por concesionario o empresa y entidad

save "ift\lin_tel_fija.dta", replace

***********************************6
clear all
import delimited "suscrip\lin_tel_mov.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de diciembre de 1990 a 2012 es TRIMESTRAL.
* De 2013 a 2019 es mensual.
duplicates r date concesionario
*Info por concesionario o empresa.

save "ift\lin_tel_mov.dta", replace

***********************************7
clear all
import delimited "suscrip\sus_tv_rest.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 2013 a 2019 MENSUAL.
duplicates r date concesionario
*Info por concesionario.

save "ift\sus_tv_rest.dta", replace

***********************************8
clear all
import delimited "suscrip\tv_rest_mkt_shr.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 1996 a 2012 es trimestral.
* De de 2013 a 2019 es MENSUAL
duplicates r date grupo
*Info por concesionario.

save "ift\tv_rest_mkt_shr.dta", replace

***********************************9
clear all
import delimited "suscrip\sus_int_fija.csv", parselocale(es_MX) 
rename anio year
rename mes month
gen day = substr(fecha,1,2)
destring day, replace

gen datereal = date(string(day)+"/"+string(month)+"/"+string(year),"DMY")
format datereal %td
*Se usa mes como tsset
gen date = mofd(datereal)
format date %tm
gen count = date

sort date
*Ojo, de 2013 a 2019 es MENSUAL
duplicates r date concesionario
*Info por concesionario.

save "ift\sus_int_fija.dta", replace



********************************************************************************
****************************************************************** DATA ANALYSIS
* generar directorio donde guarde los resultados
cd $dir
cap mkdir "results"

*************************************************************************** INPC
clear all
use "db\inpc.dta"
tsset date
gen nbinpctotal = (inpctotal/inpctotal[1])*100
gen nbinpccom = (inpccom/inpccom[1])*100
gen nbinpccomequipo = (inpccomequipo/inpccomequipo[1])*100
gen nbinpccomserv = (inpccomserv/inpccomserv[1])*100

*Reforma 11 jun 2013
*Ley 14 jul 2014
* Pruebillas
*twoway tsline inpctotal inpccom inpccomequipo inpccomserv, tline(15jun2013) tline(15jul2014)
*twoway tsline nbinpctotal nbinpccom nbinpccomequipo nbinpccomserv, tline(15jun2013) tline(15jul2014)


tw tsline inpctotal inpccom, ///
title("Evolución INPC (General) y el subíndice INPC-Comunicaciones (Base = 15-jul-2018)") ///
ytitle("INPC") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "INPC") label(2 "INPC-Com") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del INEGI, INPC.")
*Salvar
graph export "results\inpc1.png", as(png) wid(1000) replace


tw tsline nbinpctotal nbinpccom, ///
title("Evolución INPC (General) y el subíndice INPC-Comunicaciones (Base = 15-ene-2011)") ///
ytitle("INPC") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "INPC") label(2 "INPC-Com") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del INEGI, INPC.")
*Salvar
graph export "results\inpc2.png", as(png) wid(1000) replace




************************************************************************ BIT IFT
*Hacer una de líneas movil, líneas internet movil, línea fija
* internet fijo y TV de paga
*Necesito carpeta temporal
cd $dir
cap mkdir "tmp"

* Tengo que juntar lo siguiente:

*** TV Restringida
*Ojo, de 2013 a 2019 MENSUAL.
*Info por concesionario.
* "ift\sus_tv_rest.dta"

*** Banda ancha fija
*Ojo, de 2013 a 2019 es MENSUAL
*Info por concesionario.
* "ift\sus_int_fija.dta"

*** Telefonía movil
*Ojo, de diciembre de 1990 a 2012 es TRIMESTRAL.
* De 2013 a 2019 es mensual.
*Info por concesionario o empresa.
* "ift\lin_tel_mov.dta"

*** Internet movil
*Ojo, de 2010 a junio de 2013 es TRIMESTRAL. De junio de 2013 a 2019 es MENSUAL
*Info por concesionario o empresa
* "ift\lin_int_mov.dta"

*** Telefonía fija
*Ojo, de 1971 a 1991 es ANUAL nacional.
* De 1992 a 1999 es anual por estado.
* De 2000 a 2019 es mensual por estado.
*Info por concesionario o empresa y entidad
* "ift\lin_tel_fija.dta"

*Homogéneo a partir de 2014
*Mensual

clear all
use "ift\sus_tv_rest.dta"
keep if year>=2014
collapse (sum) resid=s_residencial_e noresid=s_no_residencial_e ///
ambos=s_ambos_e noespecif=s_no_especificado_e tv_rest=s_total_e, by(date)
save "tmp\l_tv_rest.dta", replace

clear all
use "ift\sus_int_fija.dta"
keep if year>=2014
collapse (sum) resid=s_residencial_e noresid=s_no_residencial_e ///
int_fija=s_total_e, by(date)
save "tmp\l_int_fija.dta", replace

*pospago l es libre y c es controlado
clear all
use "ift\lin_tel_mov.dta"
keep if year>=2014
gen pos = l_pospagoc_e + l_pospagol_e
collapse (sum) tel_mov=l_total_e prepago=l_prepago_e ///
pospago=pos, by(date)
save "tmp\l_tel_mov.dta", replace

clear all
use "ift\lin_int_mov.dta"
keep if year>=2014
gen pos = l_pospagoc_e + l_pospagol_e
collapse (sum) int_mov=l_total_e prepago=l_prepago_e ///
pospago=pos, by(date)
format pospago %12.0g
save "tmp\l_int_mov.dta", replace

clear all
use "ift\lin_tel_fija.dta"
keep if year>=2014
collapse (sum) tel_fija=l_total_e resid=l_residencial_e ///
noresid=l_no_residencial_e, by(date)
save "tmp\l_tel_fija.dta", replace

clear all
use "tmp\l_tel_fija.dta"
keep date tel_fija
merge 1:1 date using "tmp\l_int_mov.dta", keepusing(int_mov) nogen
merge 1:1 date using "tmp\l_tel_mov.dta", keepusing(tel_mov) nogen
merge 1:1 date using "tmp\l_int_fija.dta", keepusing(int_fija) nogen
merge 1:1 date using "tmp\l_tv_rest.dta", keepusing(tv_rest) nogen

foreach perro in tel_fija int_mov tel_mov int_fija tv_rest {
	replace `perro' = `perro'/1000000
}

sort date
graph bar tv_rest tel_fija int_fija tel_mov int_mov, over(date, relabel(1 "Enero 2014" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 "Diciembre 2019")) stack ///
title("Evolución de suscriptores por tipo de servicios finales (mensual, 2014-2019)") ///
ytitle("Suscriptores/líneas (millones)") ysize(2) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "TV restringida") label(2 "Telefonía fija") label(3 "Internet fijo") label(4 "Telefonía movil") label(5 "Internet movil") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.") blabel(total, format(%3.0f) c(black))

graph export "results\suscrip2.png", as(png) wid(1500) replace


graph hbar tv_rest tel_fija int_fija tel_mov int_mov, over(date, relabel(1 "Enero 2014" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 "Diciembre 2019")) stack ///
title("Evolución de suscriptores por tipo de servicios finales (mensual, 2014-2019)") ///
ytitle("Suscriptores/líneas (millones)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "TV restringida") label(2 "Telefonía fija") label(3 "Internet fijo") label(4 "Telefonía movil") label(5 "Internet movil") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.") blabel(total, format(%3.0f) c(black) si(3pt))

graph export "results\suscrip2.png", as(png) wid(1500) replace

gen datereal = dofm(date)
gen half = halfyear(datereal)
gen year = yofd(datereal)
collapse (mean) tel_fija int_mov tel_mov int_fija tv_rest , by(half year)


sort year half
gen semest = halfyearly(string(half)+"-"+string(year) , "HY")
format semest %th
graph bar tv_rest tel_fija int_fija tel_mov int_mov, over(semest, relabel(1 "1er. 2014" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 "2do. 2019")) stack ///
title("Evolución de suscriptores por tipo de servicios finales (semestral, 2014-2019)") ///
ytitle("Suscriptores/líneas (millones)") ysize(2) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "TV restringida") label(2 "Telefonía fija") label(3 "Internet fijo") label(4 "Telefonía movil") label(5 "Internet movil") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.") blabel(total, format(%3.0f) c(black)si(4pt))

graph export "results\suscrip3.png", as(png) wid(1500) replace


graph hbar tv_rest tel_fija int_fija tel_mov int_mov, over(semest, relabel(1 "1er. 2014" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 "2do. 2019")) stack ///
title("Evolución de suscriptores por tipo de servicios finales (semestral, 2014-2019)") ///
ytitle("Suscriptores/líneas (millones)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "TV restringida") label(2 "Telefonía fija") label(3 "Internet fijo") label(4 "Telefonía movil") label(5 "Internet movil") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.") blabel(total, format(%3.0f) c(black) si(4pt))

graph export "results\suscrip4.png", as(png) wid(1500) replace


*Ojo, de 2013 a 2019 es MENSUAL
*Info por concesionario
* "ift\acc_int_fija_por_vel.dta"

clear all
use "ift\acc_int_fija_por_vel.dta"
keep if year>=2013
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo

collapse (sum) a_total_e, by(grupo date)
rename a_total_e t
reshape wide t, i(date) j(grupo) string

sort date

tsset date, m

egen total = rowtotal(tAIRECABLE tALESTRA tAMERICA_MOVIL tATnT tAXESAT tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tEDILAR tELARA tGRUPO_TELEVISA tIENTC tMARCATEL tMAXCOM tMEGACABLE_MCM tNETWEY tSTARGROUP tTELEFONICA tTOTALPLAY tTRANSTELCO tTV_REY tULTRAVISION)

foreach perrito in tAIRECABLE tALESTRA tAMERICA_MOVIL tATnT tAXESAT tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tEDILAR tELARA tGRUPO_TELEVISA tIENTC tMARCATEL tMAXCOM tMEGACABLE_MCM tNETWEY tSTARGROUP tTELEFONICA tTOTALPLAY tTRANSTELCO tTV_REY tULTRAVISION {
	gen p`perrito' = (`perrito'/total)*100
	gen m`perrito' = `perrito'/1000000
}

tw tsline mtAMERICA_MOVIL mtGRUPO_TELEVISA mtMEGACABLE_MCM mtTOTALPLAY, ///
title("Principales grupos en número de accesos BAF") ///
ytitle("Número de accesos (en millones)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "AMX") label(2 "GTV") label(3 "MCM") label(4 "TotPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\BAF1.png", as(png) wid(1000) replace


tw tsline ptAMERICA_MOVIL ptGRUPO_TELEVISA ptMEGACABLE_MCM ptTOTALPLAY, ///
title("Participación de los principales grupos en número de accesos BAF") ///
ytitle("Participación en ´accesos a BAF (%)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "AMX") label(2 "GTV") label(3 "MCM") label(4 "TotPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\BAF2.png", as(png) wid(1000) replace

sort date
graph hbar ptAMERICA_MOVIL ptGRUPO_TELEVISA ptMEGACABLE_MCM ptTOTALPLAY, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019")) stack ///
title("Participación de los principales grupos en accesos BAF (mensual, 2013-2019)") ///
ytitle("Participación en accesos BAF (%)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "AMX") label(2 "GTV") label(3 "MCM") label(4 "TotPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT." "*Las participaciones no suman 100 porque la participación restante se divide en" "diversos concesionarios pequeños.")
*Salvar
graph export "results\BAF3.png", as(png) wid(1500) replace

sort date
gen trend = _n
foreach perrito in tAMERICA_MOVIL tGRUPO_TELEVISA tMEGACABLE_MCM tTOTALPLAY {
	gen log`perrito' = log(`perrito')
}

reg logtAMERICA_MOVIL trend, robust
margins, dydx(*)
marginsplot

reg logtAMERICA_MOVIL trend, robust
estimates store amx
reg logtGRUPO_TELEVISA trend, robust
estimates store gtv
reg logtMEGACABLE_MCM trend, robust
estimates store mcm
reg logtTOTALPLAY trend, robust
estimates store tpl

coefplot (amx, label(AMX)) (gtv, label(GTV)) (mcm, label(MCM)) ///
(tpl, label(Total Play)), drop(_cons) xline(0) scheme(538) legend(region(color(white))) ///
title("Tasa de crecimiento mensual promedio (2013-2019)") ///
subtitle("Accesos de Banda Ancha Fija (BAF) por Grupo de Interés Económico") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT." ///
"* Obtenido a partir de la regresión lny = a + bt + u, para cada grupo." ///
"El degradado en cada punto son intervalos de confianza a 99%.") cismooth xsize(8) ///
mlabel(strofreal(@b*100,"%11.2f")+" %") mlabpos(10)
*Salvar
graph export "results\crecimiento.png", as(png) wid(1500) replace




clear all
use "ift\acc_int_fija_por_vel.dta"
keep if year>=2013
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
sort grupo date
*v1 es 256 kbps a 1.99 Mbps
*v2 es de 2 a 9.99 Mbps
*v3 es de 10 a 100 Mbps
*v4 es más de 100 Mbps

collapse (sum) a_v2_e, by(grupo date)
rename a_v2_e t
reshape wide t, i(date) j(grupo) string

sort date
tsset date, m

egen total = rowtotal(tAIRECABLE tALESTRA tAMERICA_MOVIL tATnT tAXESAT tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tEDILAR tELARA tGRUPO_TELEVISA tIENTC tMARCATEL tMAXCOM tMEGACABLE_MCM tNETWEY tSTARGROUP tTELEFONICA tTOTALPLAY tTRANSTELCO tTV_REY tULTRAVISION)

foreach perrito in tAIRECABLE tALESTRA tAMERICA_MOVIL tATnT tAXESAT tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tEDILAR tELARA tGRUPO_TELEVISA tIENTC tMARCATEL tMAXCOM tMEGACABLE_MCM tNETWEY tSTARGROUP tTELEFONICA tTOTALPLAY tTRANSTELCO tTV_REY tULTRAVISION {
	gen p`perrito' = (`perrito'/total)*100
	gen m`perrito' = `perrito'/1000000
}

graph hbar ptAMERICA_MOVIL ptATnT ptAXTEL ptGRUPO_TELEVISA ptMAXCOM ptMEGACABLE_MCM ptTOTALPLAY, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019")) stack ///
title("Participación de los principales grupos en accesos BAF (mensual, 2013-2019)") ///
subtitle("2 Mbps a 9.99 Mbps") ///
ytitle("Participación en accesos BAF (%)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "AMX") label(2 "AT&T") label(3 "Axtel") label(4 "GTV") label(5 "Maxcom") label(6 "Megacable") label(7 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT." "*Las participaciones no suman 100 porque la participación restante se divide en" "diversos concesionarios pequeños.")
*Salvar
graph export "results\BAF_lento.png", as(png) wid(1500) replace


tw tsline ptAMERICA_MOVIL ptATnT ptAXTEL ptGRUPO_TELEVISA ptMAXCOM ptMEGACABLE_MCM ptTOTALPLAY, ///
title("Participación de los principales grupos en número de accesos BAF") ///
subtitle("2 Mbps a 9.99 Mbps") ///
ytitle("Participación en accesos a BAF (%)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "AMX") label(2 "AT&T") label(3 "Axtel") label(4 "GTV") label(5 "Maxcom") label(6 "Megacable") label(7 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\BAF_lento2.png", as(png) wid(1000) replace

tw tsline mtAMERICA_MOVIL mtATnT mtAXTEL mtGRUPO_TELEVISA mtMAXCOM mtMEGACABLE_MCM mtTOTALPLAY, ///
title("Participación de los principales grupos en número de accesos BAF") ///
subtitle("2 Mbps a 9.99 Mbps. Cifras en millones.") ///
ytitle("Número de accesos a BAF de esa velocidad (millones)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "AMX") label(2 "AT&T") label(3 "Axtel") label(4 "GTV") label(5 "Maxcom") label(6 "Megacable") label(7 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\BAF_lento3.png", as(png) wid(1000) replace



clear all
use "ift\acc_int_fija_por_vel.dta"
keep if year>=2013
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
sort grupo date
*v1 es 256 kbps a 1.99 Mbps
*v2 es de 2 a 9.99 Mbps
*v3 es de 10 a 100 Mbps
*v4 es más de 100 Mbps

collapse (sum) a_v3_e, by(grupo date)
rename a_v3_e t
reshape wide t, i(date) j(grupo) string

sort date
tsset date, m

egen total = rowtotal(tAIRECABLE tALESTRA tAMERICA_MOVIL tATnT tAXESAT tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tEDILAR tELARA tGRUPO_TELEVISA tIENTC tMARCATEL tMAXCOM tMEGACABLE_MCM tNETWEY tSTARGROUP tTELEFONICA tTOTALPLAY tTRANSTELCO tTV_REY tULTRAVISION)

foreach perrito in tAIRECABLE tALESTRA tAMERICA_MOVIL tATnT tAXESAT tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tEDILAR tELARA tGRUPO_TELEVISA tIENTC tMARCATEL tMAXCOM tMEGACABLE_MCM tNETWEY tSTARGROUP tTELEFONICA tTOTALPLAY tTRANSTELCO tTV_REY tULTRAVISION {
	gen p`perrito' = (`perrito'/total)*100
	gen m`perrito' = `perrito'/1000000
}

graph hbar ptAMERICA_MOVIL ptGRUPO_TELEVISA ptMEGACABLE_MCM ptTOTALPLAY, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019")) stack ///
title("Participación de los principales grupos en accesos BAF (mensual, 2013-2019)") ///
subtitle("10 a 100 Mbps") ///
ytitle("Participación en accesos BAF (%)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "AMX") label(2 "GTV") label(3 "Megacable") label(4 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT." "*Las participaciones no suman 100 porque la participación restante se divide en" "diversos concesionarios pequeños.")
*Salvar
graph export "results\BAF_rapido.png", as(png) wid(1500) replace


tw tsline ptAMERICA_MOVIL ptGRUPO_TELEVISA ptMEGACABLE_MCM ptTOTALPLAY, ///
title("Participación de los principales grupos en número de accesos BAF") ///
subtitle("10 a 100 Mbps") ///
ytitle("Participación en accesos a BAF (%)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "AMX") label(2 "GTV") label(3 "Megacable") label(4 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\BAF_rapido2.png", as(png) wid(1000) replace

tw tsline mtAMERICA_MOVIL mtGRUPO_TELEVISA mtMEGACABLE_MCM mtTOTALPLAY, ///
title("Participación de los principales grupos en número de accesos BAF") ///
subtitle("10 a 100 Mbps. Cifras en millones.") ///
ytitle("Número de accesos a BAF de esa velocidad (millones)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "AMX") label(2 "GTV") label(3 "Megacable") label(4 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\BAF_rapido3.png", as(png) wid(1000) replace




clear all
use "ift\acc_int_fija_por_vel.dta"
keep if year>=2013
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
sort grupo date
*v1 es 256 kbps a 1.99 Mbps
*v2 es de 2 a 9.99 Mbps
*v3 es de 10 a 100 Mbps
*v4 es más de 100 Mbps

collapse (sum) a_v1_e a_v2_e a_v3_e a_v4_e (first) year, by(grupo date)
rename a_v1_e v1
rename a_v2_e v2
rename a_v3_e v3
rename a_v4_e v4

collapse (mean) v1 v2 v3 v4, by(grupo year)

bysort year : egen tot_v1 = total(v1)
bysort year : egen tot_v2 = total(v2)
bysort year : egen tot_v3 = total(v3)
bysort year : egen tot_v4 = total(v4)

foreach perrito in v1 v2 v3 v4 {
	gen p_`perrito' = (`perrito'/tot_`perrito')*100
	format p_`perrito' %2.0f
}

keep if year==2019
keep grupo p_v1 p_v2 p_v3 p_v4
egen suma = rowtotal(p_v1 p_v2 p_v3 p_v4)
gsort -suma
keep if suma >=5
drop suma



clear all
use "ift\tv_rest_mkt_shr.dta"
keep if year>=2013 & month==12
drop fecha k_grupo datereal date count month day

reshape wide market_share, i(grupo) j(year)



clear all
use "ift\acc_tv_rest.dta"
*2013 a 2019 mensual 
keep if year>=2013
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
sort grupo date

collapse (sum) a_total_e, by(grupo date)
rename a_total_e t
reshape wide t, i(date) j(grupo) string

sort date
tsset date, m

egen total = rowtotal(tAIRECABLE tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tGRUPO_TELEVISA tMAXCOM tMEGACABLE_MCM tSTARGROUP tTOTALPLAY tTV_REY tULTRAVISION)

foreach perrito in tAIRECABLE tAXTEL tCABLECOM tCABLEVISION_RED tDISH_MVS tGRUPO_TELEVISA tMAXCOM tMEGACABLE_MCM tSTARGROUP tTOTALPLAY tTV_REY tULTRAVISION {
	gen p`perrito' = (`perrito'/total)*100
	gen m`perrito' = `perrito'/1000000
}

graph hbar ptCABLECOM ptCABLEVISION_RED ptDISH_MVS ptGRUPO_TELEVISA ptMEGACABLE_MCM ptSTARGROUP ptTOTALPLAY, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019")) stack ///
title("Participación de los principales grupos en accesos TV Restringida (mensual, 2013-2019)") ///
ytitle("Participación en accesos TV Restringida (%)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "Cablecom") label(2 "Cablevisión") label(3 "Dish-MVS") label(4 "GTV") label(5 "MCM") label(6 "Stargroup") label(7 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT." "*Las participaciones no suman 100 porque la participación restante se divide en" "diversos concesionarios pequeños.")
*Salvar
graph export "results\TV_rest-acc1.png", as(png) wid(1500) replace


tw tsline ptCABLECOM ptCABLEVISION_RED ptDISH_MVS ptGRUPO_TELEVISA ptMEGACABLE_MCM ptSTARGROUP ptTOTALPLAY, ///
title("Participación de los principales grupos en accesos TV Restringida (mensual, 2013-2019)") ///
ytitle("Participación en accesos a TV Restringida (%)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "Cablecom") label(2 "Cablevisión") label(3 "Dish-MVS") label(4 "GTV") label(5 "MCM") label(6 "Stargroup") label(7 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\TV_rest-acc2.png", as(png) wid(1000) replace

tw tsline mtCABLECOM mtCABLEVISION_RED mtDISH_MVS mtGRUPO_TELEVISA mtMEGACABLE_MCM mtSTARGROUP mtTOTALPLAY, ///
title("Participación de los principales grupos en accesos TV Restringida (mensual, 2013-2019)") ///
ytitle("Número de accesos a TV Restringida (millones)") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "Cablecom") label(2 "Cablevisión") label(3 "Dish-MVS") label(4 "GTV") label(5 "MCM") label(6 "Stargroup") label(7 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\TV_rest-acc3.png", as(png) wid(1000) replace



clear all
use "ift\acc_int_fija_por_vel.dta"
keep if year>=2013
*v1 es 256 kbps a 1.99 Mbps
*v2 es de 2 a 9.99 Mbps
*v3 es de 10 a 100 Mbps
*v4 es más de 100 Mbps
rename a_v1_e v1
rename a_v2_e v2
rename a_v3_e v3
rename a_v4_e v4
rename a_total_e totalero
*ERROR. El total reportado es distinto a la suma de v1 v2 v3 v4 desde 2015m4

collapse (sum) v1 v2 v3 v4, by(date)
gen double total = v1 + v2 + v3 + v4

gen pv1 = (v1/total)*100
gen pv2 = (v2/total)*100
gen pv3 = (v3/total)*100
gen pv4 = (v4/total)*100
format pv* %4.2f

replace v1 = v1/1000000
replace v2 = v2/1000000
replace v3 = v3/1000000
replace v4 = v4/1000000

graph hbar pv1 pv2 pv3 pv4, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019")) stack ///
title("Accesos de banda ancha fija por velocidad (mensual, 2013-2019)") ///
ytitle("Porcentaje de accesos (%)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "256kbps-1.99Mbps") label(2 "2-9.99Mbps") label(3 "10-100Mbps") label(4 ">100Mbps") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\porc-vel.png", as(png) wid(1500) replace

graph hbar v1 v2 v3 v4, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019")) stack ///
title("Accesos de banda ancha fija por velocidad (mensual, 2013-2019)") ///
ytitle("Millones de accesos") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "256kbps-1.99Mbps") label(2 "2-9.99Mbps") label(3 "10-100Mbps") label(4 ">100Mbps") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\porc-vel2.png", as(png) wid(1500) replace



* Tengo que juntar lo siguiente:

clear all
use "ift\sus_tv_rest.dta"
keep if year>=2014
collapse (sum) resid=s_residencial_e noresid=s_no_residencial_e ///
ambos=s_ambos_e noespecif=s_no_especificado_e tv_rest=s_total_e, by(grupo date)
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
save "tmp\parti_tv_rest.dta", replace

clear all
use "ift\sus_int_fija.dta"
keep if year>=2014
collapse (sum) resid=s_residencial_e noresid=s_no_residencial_e ///
int_fija=s_total_e, by(grupo date)
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
save "tmp\parti_int_fija.dta", replace

*pospago l es libre y c es controlado
clear all
use "ift\lin_tel_mov.dta"
keep if year>=2014
gen pos = l_pospagoc_e + l_pospagol_e
collapse (sum) tel_mov=l_total_e prepago=l_prepago_e ///
pospago=pos, by(grupo date)
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
save "tmp\parti_tel_mov.dta", replace

clear all
use "ift\lin_int_mov.dta"
keep if year>=2014
gen pos = l_pospagoc_e + l_pospagol_e
collapse (sum) int_mov=l_total_e prepago=l_prepago_e ///
pospago=pos, by(grupo date)
format pospago %12.0g
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
save "tmp\parti_int_mov.dta", replace

clear all
use "ift\lin_tel_fija.dta"
keep if year>=2014
collapse (sum) tel_fija=l_total_e resid=l_residencial_e ///
noresid=l_no_residencial_e, by(grupo date)
replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
save "tmp\parti_tel_fija.dta", replace


clear all
use "tmp\parti_tel_fija.dta"
keep date grupo tel_fija
merge 1:1 date grupo using "tmp\parti_int_mov.dta", keepusing(int_mov) nogen
merge 1:1 date grupo using "tmp\parti_tel_mov.dta", keepusing(tel_mov) nogen
merge 1:1 date grupo using "tmp\parti_int_fija.dta", keepusing(int_fija) nogen
merge 1:1 date grupo using "tmp\parti_tv_rest.dta", keepusing(tv_rest) nogen

tab date
tab grupo

foreach perro in tel_fija int_mov tel_mov int_fija tv_rest {
	replace `perro' = `perro'/1000000
}

rename tel_fija var1
rename int_mov var2
rename tel_mov var3
rename int_fija var4
rename tv_rest var5

reshape long var, i(date grupo) j(tipo) string
destring tipo, replace
reshape wide var, i(date tipo) j(grupo) string

egen total = rowtotal(varAIRBUS varAIRECABLE varALESTRA varAMERICA_MOVIL varATnT varAXESAT varAXTEL varBUENO_CELL varCABLECOM varCABLEVISION_RED varCELMAX varCIERTO varCONVERGIA varDISH_MVS varEDILAR varELARA_COMUNICACIONES varFLASH_MOBILE varFREEDOM varGRUPO_TELEVISA varHER_MOBILE varIENTC varIUSACELL_UNEFON varMARCATEL varMAXCOM varMAZ_TIEMPO varMEGACABLE_MCM varMEGATEL varMIIO varNETWEY varNEUS_MOBILE varNEXTEL varOUI varQBO_CEL varSIMPATI varSIMPLII varSIX_MOVIL varSTARGROUP varTELEFONICA varTELEVISION_INTERNACIONAL varTOKA_MOVIL varTOTALPLAY varTRANSTELCO varTV_REY varULTRAVISION varVADSA varVDT_COMUNICACIONES varVIRGIN_MOBILE varWEEX)

foreach perro in varAIRBUS varAIRECABLE varALESTRA varAMERICA_MOVIL varATnT varAXESAT varAXTEL varBUENO_CELL varCABLECOM varCABLEVISION_RED varCELMAX varCIERTO varCONVERGIA varDISH_MVS varEDILAR varELARA_COMUNICACIONES varFLASH_MOBILE varFREEDOM varGRUPO_TELEVISA varHER_MOBILE varIENTC varIUSACELL_UNEFON varMARCATEL varMAXCOM varMAZ_TIEMPO varMEGACABLE_MCM varMEGATEL varMIIO varNETWEY varNEUS_MOBILE varNEXTEL varOUI varQBO_CEL varSIMPATI varSIMPLII varSIX_MOVIL varSTARGROUP varTELEFONICA varTELEVISION_INTERNACIONAL varTOKA_MOVIL varTOTALPLAY varTRANSTELCO varTV_REY varULTRAVISION varVADSA varVDT_COMUNICACIONES varVIRGIN_MOBILE varWEEX {
	replace `perro' = (`perro'/total)*100
}

gen aver=date
sort date
graph bar varAMERICA_MOVIL varATnT varDISH_MVS varGRUPO_TELEVISA varMEGACABLE_MCM varTELEFONICA varTOTALPLAY if date==719, over(tipo, relabel(1 "Tel. Fija" 2 "Int. Mov." 3 "Tel. Mov." 4 "BAF" 5 "TV Rest.")) stack ///
title("Participación de principales GIE por mercado.") ///
subtitle("Con base en líneas o suscriptores. Diciembre de 2019.") ///
ytitle("Participación (%)") ysize(5) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "AMX") label(2 "AT&T") label(3 "Dish") label(4 "GTV") label(5 "MCM") label(6 "Telefonica") label(7 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.") blabel(total, format(%3.0f) c(black))

graph export "results\part-por-serv.png", as(png) wid(1500) replace



************************************************************************ ENDUTIH
*Año por año para juntarlos
*Homogenizo todo a 2018 (parece ser igual a 2017):
* P5_1 tv-rest: 1 sí 2 no
* P4_5 internet: 1 fija 2 movil 3 ambas 9 no sé
* P5_4 telf fijo: 1 sí 2 no
* P4_1_5 telf cel: 1 sí 2 no

*2019 es dif a 2018
clear all
use "$dir\db\2019-hogares.dta"
keep upm FAC_HOG EST_DIS P5_1 P4_5 P5_5 P4_1_5
rename P5_5 P5_4
destring upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5, replace
gen year=2019
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2019-hog.dta", replace

clear all
use "$dir\db\2018-hogares.dta"
keep upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5
destring upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5, replace
gen year=2018
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2018-hog.dta", replace

clear all
use "$dir\db\2017-hogares.dta"
keep upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5
destring upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5, replace
gen year=2017
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2017-hog.dta", replace

*2016 es diferente a las nuevas
clear all
use "$dir\db\2016-hogares.dta"
keep UPM_DIS factor EST_DIS P5_1_1 P5_1_2 P4_6 P5_1B P4_1_5
rename UPM_DIS upm
rename factor FAC_HOG
rename P4_6 P4_5
rename P5_1B P5_4
gen P5_1 = 2
replace P5_1 = 1 if P5_1_1=="1" | P5_1_2=="1"
destring upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5, replace
keep upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5
gen year=2016
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2016-hog.dta", replace

*2015 es también diferente a 2016 y a las nuevas
clear all
use "$dir\db\2015-hogares.dta"
keep UPM_DIS factor EST_DIS P4_1_7 P4_1_8 P4_6 P4_1_2 P4_1_3 P4_1_9
rename UPM_DIS upm
rename factor FAC_HOG
rename P4_6 P4_5
rename P4_1_9 P4_1_5
gen P5_4 =2
replace P5_4 = 1 if P4_1_2=="1" | P4_1_3=="1"
gen P5_1 = 2
replace P5_1 = 1 if P4_1_7=="1" | P4_1_8=="1"
destring upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5, replace
keep upm FAC_HOG EST_DIS P5_1 P4_5 P5_4 P4_1_5
gen year=2015
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2015-hog.dta", replace


************** Unión
clear all
use "$dir\tmp\2019-hog.dta"
append using "$dir\tmp\2018-hog.dta"
append using "$dir\tmp\2017-hog.dta"
append using "$dir\tmp\2016-hog.dta"
append using "$dir\tmp\2015-hog.dta"

*Variables necesarias
*TV rest
gen TV_rest=0
replace TV_rest=1 if P5_1==1

*Tiene internet
gen intiti = 1
replace intiti = 0 if P4_5==.

*BAF
gen ifija=0
replace ifija=1 if P4_5==1 | P4_5==3

*BAM
gen imovil=0
replace imovil=1 if P4_5==2 | P4_5==3

*telef fija
gen tfija=0
replace tfija=1 if P5_4==1

*telef movil
gen tmovil=0
replace tmovil=1 if P4_1_5==1

* P5_1 tv-rest: 1 sí 2 no
* P4_5 internet: 1 fija 2 movil 3 ambas 9 no sé
* P5_4 telf fijo: 1 sí 2 no
* P4_1_5 telf cel: 1 sí 2 no

*Declaramos la survey
svyset upm [pweight=FAC_HOG], strata(EST_DIS)


************** Graphs
*TV Restringida
svy : total TV_rest, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con TV restringida.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\tvrestnum.png", as(png) wid(1500) replace
graph close

*Porcentajes
svy : proportion TV_rest , over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con TV restringida.") ///
subtitle("TV restringida (%).") gr(TV_rest) ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\tvrestporc.png", as(png) wid(1500) replace name(_mp_2)
graph close

*BAF
svy : total ifija, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con BAF.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\bafnum.png", as(png) wid(1500) replace
graph close

*Porcentajes
svy : proportion ifija , over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con BAF.") ///
subtitle("BAF (%).") gr(ifija) ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\bafporc.png", as(png) wid(1500) replace name(_mp_2)
graph close

*BAM
svy : total imovil, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con BAM.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\bamnum.png", as(png) wid(1500) replace
graph close

*Porcentajes
svy : proportion imovil, over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con BAM.") ///
subtitle("BAM (%).") gr(imovil) ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\bamporc.png", as(png) wid(1500) replace name(_mp_2)
graph close

*tel fija
svy : total tfija, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con telefonía fija.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\telfijnum.png", as(png) wid(1500) replace
graph close

*Porcentajes
svy : proportion tfija , over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con telefonía fija.") ///
subtitle("Telefonía fija (%).") gr(tfija) ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\telfijporc.png", as(png) wid(1500) replace name(_mp_2)
graph close

*tel movil
svy : total tmovil, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con teléfono celular.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\telmovnum.png", as(png) wid(1500) replace
graph close

*Porcentajes
svy : proportion tmovil, over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con teléfono celular.") ///
subtitle("Hogares con al menos un integrante con teléfono celular (%).") gr(tmovil) ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\telmovporc.png", as(png) wid(1500) replace name(_mp_2)
graph close



*JUNTAS
svy : total TV_rest ifija imovil tfija tmovil, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con servicios de telecom.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\juntasnum.png", as(png) wid(1500) replace

*NO HALLE MANERA DE JUNTAR EN PORCENTAJES :(
*Porcentajes
*
svy : proportion TV_rest ifija imovil tfija tmovil, over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con servicios de telecom.") ///
subtitle("Por servicio.") plot(TV_rest ifija imovil tfija tmovil, lab("Sin TV rest" "Con TV rest" "Sin BAF" "Con BAF" "Sin BAM" "Con BAM" "Sin tel. fijo" "Con tel.fijo" "Sin tel. mov." "Con tel. mov.")) ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\juntasporc.png", as(png) wid(1500) replace


* TV_rest ifija tfija
*GRUPO: 0 nada, 1 tvrest 2 ifijo 3 tfijo 4 tvrestifijo 5 tvresttfijo 6 ifijatfija 7 todos
gen grupo = 0
replace grupo=1 if TV_rest==1
replace grupo=2 if ifija==1
replace grupo=3 if tfija==1
replace grupo=4 if TV_rest==1 & ifija==1
replace grupo=5 if TV_rest==1 & tfija==1
replace grupo=6 if tfija==1 & ifija==1
replace grupo=7 if TV_rest==1 & ifija==1 & tfija==1

gen tiene=0
replace tiene=1 if grupo>0

svy : total tiene, over(grupo year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con servicios de telecom.") x(year) ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")



















































**************************HOGARES QUE DISPONEN DE TELEVISOR*********************************
*esto era solo para checar que no hubiera missing en esta variable porque sinoooooooooo estariamos mal
tab hogar, m

*televisor analógico
tab P4_1_2 [fw = factor], m

*televisor digital
tab P4_1_4 [fw = factor]

*ambos
gen tv2tipos = P4_1_2 * P4_1_4
tab tv2tipos [fw = factor]

** tv2tipos=1 significa que tienen ambos tipos de televisores; tv2tipos=2 significa que tienen solo 1 tipo de televisor; tv2tipos=4 significa que no tienen de ningun tipo.
*los que tienen televisor
tab tv2tipos if tv2tipos != 4 [fw = factor]

*de los que tienen solo un tipo de televisor cuáles tienen analógica
tab P4_1_2 if tv2tipos == 2 [fw = factor]

*de los que tienen solo un tipo de televisor cuáles tienen digital
tab P4_1_4 if tv2tipos == 2 [fw = factor]


***************************USUARIOS DE TELEFONÍA CELULAR POR ENTIDAD************************
clear all
use "$dir\db\2015-usuarios.dta"
destring D_R upm VIV_SEL hogar nrenelegi P* UPM_DIS EST_DIS ent aream, replace

*esto era solo para checar que no hubiera missing en esta variable porque sinoooooooooo estariamos mal
tab FAC_PER, m

*Dispone de celuar 
tab P8_1 [fw = FAC_PER],  m

*Dispone de celular por entidad
tab ent P8_1 [fw = FAC_PER]



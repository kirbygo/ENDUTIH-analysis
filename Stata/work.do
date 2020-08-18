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
*IHH TV restringida
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_IHH_TVRES_ITE_VA.csv" "ihh_tv_rest.csv"
*Penetración TV Rest
copy "https://bit.ift.org.mx/descargas/datos/tabs/TD_PENETRACION_H_TVRES_ITE_VA.csv" "pene_tv_rest.csv"
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

***********************************10
clear all
import delimited "suscrip\ihh_tv_rest.csv", parselocale(es_MX) 
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
*Ojo, de 1996 a 2019 es Trimestral.
duplicates r date
*Info por trimestre.

save "ift\ihh_tv_rest.dta", replace

***********************************11
clear all
import delimited "suscrip\pene_tv_rest.csv", parselocale(es_MX) 
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
*Ojo, de 1996 a 2012 es trimestral, de 2013 a 2019 es MENSUAL
duplicates r date
*Info por fecha.

save "ift\pene_tv_rest.dta", replace


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
gen nbinpctv = (inpctv/inpctv[1])*100

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


tw tsline inpctotal inpctv, ///
title("Evolución INPC (General) e INPC TV Restringida (Base = 15-jul-2018)") ///
ytitle("INPC") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "INPC") label(2 "INPC-TV restr.") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del INEGI, INPC.")
*Salvar
graph export "results\inpc3.png", as(png) wid(1000) replace


tw tsline nbinpctotal nbinpctv, ///
title("Evolución INPC (General) e INPC TV Restringida (Base = 15-ene-2011)") ///
ytitle("INPC") ysize(12) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Fecha") xsize(20) tlabel(#12 , angle(25)) ///
scheme(538) legend(label(1 "INPC") label(2 "INPC-TV restr.") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del INEGI, INPC.")
*Salvar
graph export "results\inpc4.png", as(png) wid(1000) replace


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


clear all
use "ift\pene_tv_rest.dta"
keep if year>=2013

graph hbar p_h_tvres_e, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019")) stack ///
title("Penetración de TV restringida por cada 100 hogares (mensual, 2013-2019)") ///
ytitle("Accesos por cada 100 hogares") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\TV_rest-pene.png", as(png) wid(1500) replace


clear all
use "ift\acc_tv_rest.dta"
keep if year>=2013

collapse (sum) accesos=a_total_e, by(date tecno_acceso_tv)
drop if tecno_acceso_tv == "HFC"
replace accesos = accesos/1000000
encode tecno_acceso_tv, generate(jota)
* 1 cable 2 DTH 3 IPTV Terrestre 4 microondas 5 sin información
drop tecno
reshape wide accesos, i(date) j(jota)
drop accesos4 accesos5

graph hbar accesos1 accesos2 accesos3, over(date, relabel(1 "Enero 2013" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 " " 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 " " 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 " " 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 " " 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 " " 81 " " 82 " " 83 " " 84 "Diciembre 2019"))  ///
title("Accesos de TV restringida por tipo de tecnología (mensual, 2013-2019)") ///
ytitle("Millones de accesos") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.") legend( label(1 "Cable") label(2 "Satélite") label(3 "IPTV"))
*Salvar
graph export "results\TV_rest-tecno.png", as(png) wid(1500) replace


clear all
use "ift\sus_tv_rest.dta"
keep if year>=2013
keep if month == 12 | (year==2013 & month==1)

replace grupo = subinstr(grupo,"É","E",5)
replace grupo = subinstr(grupo,"&","n",5)
replace grupo = subinstr(grupo,"Ó","O",5)
replace grupo = subinstr(grupo," ","_",5)
replace grupo = subinstr(grupo,"-","_",5)
tab grupo
sort grupo date
format s_total_e %15.0fc
collapse (sum) s_total_e, by(grupo date)
rename s_total_e u
reshape wide u, i(date) j(grupo) string

drop uAIRECABLE uAXTEL uCABLECOM uCABLEVISION uMAXCOM uSTARGROUP uTV_REY uULTRAVISION

gen ene = _n
tsset ene
gen cdish = (uDISH_MVS - l.uDISH_MVS)/1000
gen cGTV = (uGRUPO_TELEVISA - l.uGRUPO_TELEVISA)/1000
gen cmegacable = (uMEGACABLE_MCM - l.uMEGACABLE_MCM)/1000
gen ctotal = (uTOTALPLAY - l.uTOTALPLAY)/1000

format cdish cGTV cmegacable ctotal %15.0fc

drop in 1
drop uDISH_MVS uGRUPO_TELEVISA uMEGACABLE_MCM uTOTALPLAY ene

graph bar cdish cGTV cmegacable ctotal, over(date, relabel(1 "2013-2014" 2 "2014-2015" 3 "2015-2016" 4 "2016-2017" 5 "2017-2018" 6 "2018-2019")) ///
title("Cambio en número de suscriptores (a diciembre de cada año)") ///
ytitle("Cambio en suscriptores (miles)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "Dish") label(2 "GTV") label(3 "Megacable") label(4 "TotalPlay") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\TV_rest-cambio.png", as(png) wid(1500) replace

gen y = 2013
replace y = 2014 in 2
replace y = 2015 in 3
replace y = 2016 in 4
replace y = 2017 in 5
replace y = 2018 in 6
replace y = 2019 in 7
drop date
reshape long c , i(y) j(usu) string
reshape wide c , i(usu) j(y)

graph bar c2013 c2014 c2015 c2016 c2017 c2018 c2019, over(usu, relabel(1 "GTV" 2 "Dish" 3 "Megacable" 4 "TotalPlay")) ///
title("Cambio en número de suscriptores (a diciembre de cada año)") ///
ytitle("Cambio en suscriptores (miles)") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) legend(label(1 "12-13") label(2 "13-14") label(3 "14-15") label(4 "15-16") label(5 "16-17") label(6 "17-18")label(7 "18-19") region(color(white))) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT." "Para 2013 es el comparativo entre enero 2013 y diciembre del mismo año.")
*Salvar
graph export "results\TV_rest-cambio-2.png", as(png) wid(1500) replace


clear all
use "ift\ihh_tv_rest.dta"
keep if year>=2012

graph bar ihh_tvres_e , over(date, relabel(1 "1T 2012" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 " " 31 " " 32 "4T 2019")) ///
title("Índice de Herfindahl-Hirschman, TV restringida (trimestral)") ///
ytitle("IHH") ysize(4) ylabel(#15 , format(%15.0gc) angle(0)) ///
scheme(538) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información del IFT, BIT.")
*Salvar
graph export "results\TV_rest-ihh.png", as(png) wid(1500) replace


**************************************************************** ENDUTIH Hogares
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

gen TV_rest1 = TV_rest*100
gen ifija1 = ifija*100
gen imovil1 = imovil*100
gen tfija1 = tfija*100
gen tmovil1 = tmovil*100

svy : mean TV_rest1 ifija1 imovil1 tfija1 tmovil1, over(year) level(90)
marginsplot, x(year) title("Porcentaje de hogares con servicios de telecom.") ///
subtitle("Por servicio.") plot( , lab("TV restringida" "Internet fijo" "Internet móvil" "Telefonía fija" "Telefonía móvil")) ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\juntasporcBUENA.png", as(png) wid(1500) replace


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
gen aver=1

svy : total aver, over(grupo year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con servicios de telecom.") x(year) plot(grupo, label("Sin servicios" "TV rest" "BAF" "Tel. fijo" "TV + BAF" "TV + tel" "BAF + tel" "Los 3")) ///
ytitle("Número de hogares") ysize(4) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\todasnum.png", as(png) wid(1500) replace


svy : proportion grupo, over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con servicios de telecom.") ///
subtitle("Por grupos d servicios con que cuentan.") plot(grupo, lab("Sin servicios" "TV rest" "BAF" "Tel. fijo" "TV + BAF" "TV + tel" "BAF + tel" "Los 3")) ///
ytitle("Porcentaje de hogares (%)") ysize(4) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\todasporc.png", as(png) wid(1500) replace




*************************************************************** ENDUTIH Usuarios
*Año por año para juntarlos
*Homogenizo todo:
*2019 EDAD P7_1 (usuarios de internet, si 2 entonces miss val lo siguiente, redundante)
*   P7_11_2 (audiovisuales pago)  P7_11_3 (audiovisuales gratuitos)
*   P7_11_7 (canales abiertos por internet, solo 2019 mejor no lo meto)

*2019 es dif a 2018
clear all
use "$dir\db\2019-usuarios.dta"
keep UPM_DIS FAC_PER EST_DIS edad P7_11_2 P7_11_3
destring UPM_DIS FAC_PER EST_DIS edad P7_11_2 P7_11_3, replace
gen year=2019
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2019-usu.dta", replace

clear all
use "$dir\db\2018-usuarios.dta"
keep UPM_DIS FAC_PER EST_DIS edad P7_11_2 P7_11_3
destring UPM_DIS FAC_PER EST_DIS edad P7_11_2 P7_11_3, replace
gen year=2018
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2018-usu.dta", replace

*2017 no trae EST_DIS. Hay que pegarlo de residentes
clear all
use "$dir\db\2017-residentes.dta"
keep upm VIV_SEL hogar N_REN EST_DIS
destring upm VIV_SEL hogar N_REN EST_DIS, replace
save "$dir\tmp\2017-res.dta", replace

clear all
use "$dir\db\2017-usuarios.dta"
destring upm VIV_SEL hogar N_REN, replace
merge 1:1 upm VIV_SEL hogar N_REN using "$dir\tmp\2017-res.dta"
keep if _merge==3
drop _merge

keep upm FAC_PER EST_DIS edad P7_10_2 P7_10_3
rename P7_10_2 P7_11_2
rename P7_10_3 P7_11_3
rename upm UPM_DIS
destring UPM_DIS FAC_PER EST_DIS edad P7_11_2 P7_11_3, replace
gen year=2017
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2017-usu.dta", replace

*2016
clear all
use "$dir\db\2016-usuarios.dta"
keep UPM_DIS FAC_PER EST_DIS edad P7_8_26 P7_8_27
rename P7_8_26 P7_11_2
rename P7_8_27 P7_11_3
destring UPM_DIS FAC_PER EST_DIS edad P7_11_2 P7_11_3, replace
gen year=2016
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2016-usu.dta", replace

*2015 NO TIENE EDAD. Pegar de residentes
clear all
use "$dir\db\2015-residentes.dta"
keep upm VIV_SEL hogar nren edad
destring upm VIV_SEL hogar nren edad, replace
save "$dir\tmp\2015-res.dta", replace

clear all
use "$dir\db\2015-usuarios.dta"
destring upm VIV_SEL hogar nrenelegi, replace
rename nrenelegi nren
merge 1:1 upm VIV_SEL hogar nren using "$dir\tmp\2015-res.dta"
keep if _merge==3
drop _merge

keep UPM_DIS FAC_PER EST_DIS edad P7_8_21 P7_8_22
rename P7_8_21 P7_11_2
rename P7_8_22 P7_11_3
destring UPM_DIS FAC_PER EST_DIS edad P7_11_2 P7_11_3, replace
gen year=2015
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2015-usu.dta", replace


************** Unión
clear all
use "$dir\tmp\2019-usu.dta"
append using "$dir\tmp\2018-usu.dta"
append using "$dir\tmp\2017-usu.dta"
append using "$dir\tmp\2016-usu.dta"
append using "$dir\tmp\2015-usu.dta"

*Variables necesarias
*gpo edad
*0 - no especif
*1 - 6 a 15 años
*2 - 16 a 35 años
*3 - 36 a 55 años
*4 - 56 o más
gen age = 0 if edad == 98
replace age = 1 if edad>=6 & edad<=15
replace age = 2 if edad>=16 & edad<=35
replace age = 3 if edad>=36 & edad<=55
replace age = 4 if edad>=56 & edad<=97

*usuarios internet
*0 - no usa internet
*1 - sí usa
gen usa = 0 if P7_11_2==.
replace usa = 1 if P7_11_2!=.

*de pago
*. - no usa internet
*0 - no usa pago
*1 - sí usa pago
gen pago = 0 if P7_11_2==.
replace pago = 0 if P7_11_2==2
replace pago = 1 if P7_11_2==1

*gratis
*. - no usa internet
*0 - no usa gratis
*1 - sí usa gratis
gen gratis = 0 if P7_11_3==.
replace gratis = 0 if P7_11_3==2
replace gratis = 1 if P7_11_3==1

*both
*0 - no usa internet
*1 - no lo usa por entretenimiento
*2 - sí usa solo gratis
*3 - sí usa solo pago
*4 - usa ambos
gen both = .
replace both = 0 if P7_11_2==. & P7_11_3==.
replace both = 1 if P7_11_2==2 & P7_11_3==2
replace both = 2 if P7_11_2==2 & P7_11_3==1
replace both = 3 if P7_11_2==1 & P7_11_3==2
replace both = 4 if P7_11_2==1 & P7_11_3==1

gen uno = 1

*Declaramos la survey
svyset UPM_DIS [pweight=FAC_PER], strata(EST_DIS)

************** Graphs
*Usuarios de internet
svy : total usa, over(age year) cformat(%9.0fc) level(90)
marginsplot , x(year) plot(age, label("No especif." "De 6 a 15 años" "De 16 a 35 años" "De 36 a 55" "56 años o más")) title("Usuarios de internet, por rango de edad.") ///
ytitle("Número de usuarios") ysize(4) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\usunum.png", as(png) wid(1500) replace
graph close

*Esto es dificilmente interpretable
*Es el porcentaje de usuarios de internet con respecto de internet de los entrevistados
*Pero entrevistan a los usuarios de telecom (por lo que estos porcentajes salen altos)
/*
gen usa1=usa*100
svy : mean usa1, over(age year) level(90)
marginsplot, x(year) title("Porcentaje de usuarios de internet, por rango de edad.") ///
plot(age, lab("No especif." "De 6 a 15 años" "De 16 a 35 años" "De 36 a 55" "56 años o más")) ///
ytitle("Porcentaje de usuarios (%)") ysize(4) ylabel(#15 , format(%5.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\usuporc.png", as(png) wid(1500) replace
graph close
*/

*pago
svy : total pago, over(age year) cformat(%9.0fc) level(90)
marginsplot , x(year) plot(age, label("No especif." "De 6 a 15 años" "De 16 a 35 años" "De 36 a 55" "56 años o más")) title("Uso de streaming de paga en internet.") ///
ytitle("Usuarios") ysize(4) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\pagonum.png", as(png) wid(1500) replace
graph close

*porcentaje
gen pago1=pago*100
svy, subpop (if usa==1) : mean pago1, over(age year) level(90)
marginsplot, x(year) title("Porcentaje de usuarios de streaming de paga, por rango de edad.") ///
subtitle("Con respecto del total de usuarios de internet.") ///
plot(age, lab("No especif." "De 6 a 15 años" "De 16 a 35 años" "De 36 a 55" "56 años o más")) ///
ytitle("Porcentaje de usuarios (%)") ysize(4) ylabel(#15 , format(%5.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\pagoporc.png", as(png) wid(1500) replace
graph close

*gratis
svy : total gratis, over(age year) cformat(%9.0fc) level(90)
marginsplot , x(year) plot(age, label("No especif." "De 6 a 15 años" "De 16 a 35 años" "De 36 a 55" "56 años o más")) title("Uso de streaming gratuito en internet.") ///
ytitle("Usuarios") ysize(4) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\granum.png", as(png) wid(1500) replace
graph close

*porcentaje
gen gratis1=gratis*100
svy, subpop (if usa==1) : mean gratis1, over(age year) level(90)
marginsplot, x(year) title("Porcentaje de usuarios de streaming gratuito, por rango de edad.") ///
subtitle("Con respecto del total de usuarios de internet.") ///
plot(age, lab("No especif." "De 6 a 15 años" "De 16 a 35 años" "De 36 a 55" "56 años o más")) ///
ytitle("Porcentaje de usuarios (%)") ysize(4) ylabel(#15 , format(%5.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\graporc.png", as(png) wid(1500) replace
graph close

*Grupos de uso
svy : proportion both, over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de usuarios según tipo de streaming, por rango de edad.") ///
plot(both, lab("No usa internet" "No usa serv. de streaming" "Solo servicios gratuitos" "Solo servicios de pago" "Ambos tipos")) ///
ytitle("Porcentaje de usuarios (%)") ysize(4) ylabel(#15 , format(%5.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

graph export "results\both.png", as(png) wid(1500) replace
graph close


























































**************************************************************** ENDUTIH Hogares ADICIONAL PAQUETES
*Año por año para juntarlos
*Homogenizo todo a 2019:
* P5_7_1 - 4 play
* P5_7_2 - 3 play
* P5_7_3 - TV paga y Telefono fijo
* P5_7_4 - TV Paga e internet
* P5_7_5 - Telefono e internet
* P5_7_6 - Solo TV paga
* P5_7_7 - Solo teléfono fijo
* P5_7_8 - Solo internet
* Equivalencias:
/*
paqu		2019		2018-2017	2016		2015
4play		P5_7_1				
3play		P5_7_2		P5_6_1		P5_2_1_1	P5_1_1
tv+telef	P5_7_3		P5_6_2		P5_2_2_1	P5_1_2
tv+int		P5_7_4		P5_6_3		P5_2_3_2	P5_1_3
telef+int	P5_7_5		P5_6_4		P5_2_4_2	P5_1_6
tv			P5_7_6		P5_6_5		P5_2A_1_1	P5_1_4
telef		P5_7_7		P5_6_6		P5_2A_3_1	P5_1_7
int			P5_7_8		P5_6_7		P5_2A_2_1	P5_1_5
*/


*2019
clear all
use "$dir\db\2019-hogares.dta"
keep upm FAC_HOG EST_DIS P5_7_1 P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8
destring upm FAC_HOG EST_DIS P5_7_1 P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8, replace
gen year=2019
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2019-hog-2.dta", replace

*2018
clear all
use "$dir\db\2018-hogares.dta"
drop P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7
rename P5_6_1 P5_7_2
rename P5_6_2 P5_7_3
rename P5_6_3 P5_7_4
rename P5_6_4 P5_7_5
rename P5_6_5 P5_7_6
rename P5_6_6 P5_7_7
rename P5_6_7 P5_7_8
keep upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8
destring upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8, replace
gen year=2018
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2018-hog-2.dta", replace

*2017
clear all
use "$dir\db\2017-hogares.dta"
drop P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7
rename P5_6_1 P5_7_2
rename P5_6_2 P5_7_3
rename P5_6_3 P5_7_4
rename P5_6_4 P5_7_5
rename P5_6_5 P5_7_6
rename P5_6_6 P5_7_7
rename P5_6_7 P5_7_8
keep upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8
destring upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8, replace
gen year=2017
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2017-hog-2.dta", replace

*2016
clear all
use "$dir\db\2016-hogares.dta"
rename P5_2_1_1 P5_7_2
rename P5_2_2_1 P5_7_3
rename P5_2_3_2 P5_7_4
rename P5_2_4_2 P5_7_5
rename P5_2A_1_1 P5_7_6
rename P5_2A_3_1 P5_7_7
rename P5_2A_2_1 P5_7_8
rename UPM_DIS upm
rename factor FAC_HOG
keep upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8
destring upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8, replace
gen year=2016
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2016-hog-2.dta", replace


*2015
clear all
use "$dir\db\2015-hogares.dta"
rename P5_1_1 P5_7_2
rename P5_1_2 P5_7_3
rename P5_1_3 P5_7_4
rename P5_1_6 P5_7_5
rename P5_1_4 P5_7_6
rename P5_1_7 P5_7_7
rename P5_1_5 P5_7_8
rename factor FAC_HOG
keep upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8
destring upm FAC_HOG EST_DIS P5_7_2 P5_7_3 P5_7_4 P5_7_5 P5_7_6 P5_7_7 P5_7_8, replace
gen year=2015
replace EST_DIS = EST_DIS + year*10000
save "$dir\tmp\2015-hog-2.dta", replace


************** Unión
clear all
use "$dir\tmp\2019-hog-2.dta"
append using "$dir\tmp\2018-hog-2.dta"
append using "$dir\tmp\2017-hog-2.dta"
append using "$dir\tmp\2016-hog-2.dta"
append using "$dir\tmp\2015-hog-2.dta"

*NO existe el cuadruplleplay en México. Al menos no en estos encuestados
tab P5_7_1
drop P5_7_1
tab P5_7_2

*Variables necesarias
gen triple = 0
replace triple = 1 if P5_7_2==1
gen tvtel = 0
replace tvtel = 1 if P5_7_3==1
gen tvint = 0
replace tvint = 1 if P5_7_4==1
gen telint = 0
replace telint = 1 if P5_7_5==1
gen tv = 0
replace tv = 1 if P5_7_6==1
gen tel = 0
replace tel = 1 if P5_7_7==1
gen inter = 0
replace inter = 1 if P5_7_8==1

gen sinttrip = 0
replace sinttrip = 1 if tvtel==1 & inter==1
replace sinttrip = 1 if tvint==1 & tel==1
replace sinttrip = 1 if tv==1 & tel==1 & inter==1

gen sintdob = 0
replace sintdob = 1 if tv==1 & tel==1
replace sintdob = 1 if tv==1 & inter==1

gen sintdobtvt = 0
replace sintdobtvt = 1 if tv==1 & tel==1
gen sintdobtvi = 0
replace sintdobtvi = 1 if tv==1 & inter==1
gen sintdobti = 0
replace sintdobti = 1 if tel==1 & inter==1

gen catego=0
replace catego=1 if triple==1
replace catego=2 if tvtel==1
replace catego=3 if tvint==1
replace catego=4 if telint==1
replace catego=5 if tv==1
replace catego=6 if tel==1
replace catego=7 if inter==1
replace catego=8 if sintdobtvt==1
replace catego=9 if sintdobtvi==1
replace catego=10 if sintdobti==1
replace catego=11 if sinttrip==1

* P5_7_2 - 3 play
* P5_7_3 - TV paga y Telefono fijo
* P5_7_4 - TV Paga e internet
* P5_7_5 - Telefono e internet
* P5_7_6 - Solo TV paga
* P5_7_7 - Solo teléfono fijo
* P5_7_8 - Solo internet
*sint doble tv tel_fija
*sint doble tv internet
*sint doble tel internet
*sint triple

gen catego2=0
replace catego2=1 if tv==1
replace catego2=2 if tvint==1 | tvtel==1
replace catego2=3 if triple==1

gen dobletv=0
replace dobletv=1 if tvint==1 | tvtel==1


*Declaramos la survey
svyset upm [pweight=FAC_HOG], strata(EST_DIS)


************** Graphs
*TV Restringida
svy : total triple tvtel tvint tv, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con TV restringida.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

*graph export "results\alexa1.png", as(png) wid(1500) replace
*graph close

*TV Restringida
svy : total triple tvtel tvint tv sinttrip sintdob, over(year) cformat(%9.0fc) level(90)
marginsplot, title("Hogares con TV restringida.") ///
ytitle("Número de hogares") ysize(5) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

*Porcentajes
svy : proportion catego , over(year) level(90) percent
marginsplot, x(year) title("Porcentaje de hogares con TV restringida.") ///
subtitle("TV restringida (%).") ///
ytitle("Porcentaje de hogares (%)") ysize(5) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

*graph export "results\tvrestporc.png", as(png) wid(1500) replace name(_mp_2)
*graph close

la var triple "Triple Play"
la var dobletv "Doble Play (TV)"
la var tv "TV sin paquete"

*TV Restringida
svy : total triple dobletv tv , over(year) cformat(%9.0fc) level(90)
marginsplot, plot(, lab("Triple play" "Doble play TV" "TV sin paquete")) title("Hogares con TV restringida, según el tipo de contratación.") ///
ytitle("Número de hogares") ysize(4) ylabel(#15 , format(%15.0fc) angle(0)) ///
scheme(538) xtitle("Año") legend(label(1 "perro")) ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

*graph export "ale.png", as(png) wid(1500) replace

*Porcentajes
svy : proportion catego2 , over(year) level(90) percent
marginsplot, x(year) plot(, lab("Sin STAR" "TV sin paquete" "Doble play TV" "Triple play")) title("Porcentaje de hogares: TV restringida, según paquete contratado.") ///
subtitle("TV restringida (%).") ///
ytitle("Porcentaje de hogares (%)") ysize(3) ylabel(#15 , format(%5.2fc) angle(0)) ///
scheme(538) xtitle("Año") ///
graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Nota: Elaboración propia con información de la ENDUTIH, INEGI.")

*graph export "ale2.png", as(png) wid(1500) replace

*graph export "results\tvrestporc.png", as(png) wid(1500) replace name(_mp_2)
*graph close
















































































******************************************************** INPC Structural break
clear all
use "db\inpc.dta"
gen time = _n
tsset time

*Hay un error en 2Q nov 2012 a 1Q ene 2013
tsline inpccomserv

replace inpccomserv = . in 46/49

mipolate inpccomserv time, generate(aver) spline

tsline inpccomserv aver
replace inpccomserv = aver
drop aver
*Estacionariedad
dfuller inpccomserv, trend l(1)
dfuller inpccomserv, trend l(30)
pperron inpccomserv, trend l(1)
pperron inpccomserv, trend l(30)

gen difinpccomserv = D.inpccomserv

dfuller difinpccomserv, trend l(1)
dfuller difinpccomserv, trend l(30)
pperron difinpccomserv, trend l(1)
pperron difinpccomserv, trend l(30)
*Esta serie es estacionaria

corrgram inpccomserv
corrgram difinpccomserv

arima inpccomserv, arima(1, 1, 0)

*Pruebas de correcta especificación
*Estabilidad
estat aroots
*Estable porque mod eigenval <1
*Residuales
capture drop res
predict res, r
*Histograma residuales
histogram res, bin(200)
*Correlograma residuales
corrgram res
*Prueba ruido blanco
wntestb res, msize(tiny)
*Sí es ruido blanco porque P(Bartlet)>0.05

gen la1difinpccomserv = l.difinpccomserv

regress difinpccomserv la1difinpccomserv, robust
estat sbsingle , slr gen(Lr_est) ltrim(5) rtrim(5)

tw (line Lr_est date, lw(medthin)) ///
(line inpccomserv date, lw(medthin) yax(2)), ///
title("Cambio estructural desconocido del INPC de servicios de telecomunicaciones") xtitle("Fecha") ysize(12) ytitle("Estadístico LR", axis(1)) ytitle("INPC", axis(2)) ///
ylabel(#10 , format(%15.0gc) angle(0)) xlabel(#6 , angle(0)) xsize(20) ///
scheme(538) legend(label(1 "Estimador LR") label(2 "INPC de serv. telecom."))
graph export "Camb_desc.png", as(png) wid(2000) replace

*Máximos locales en:
* Entre noviembre 2012 y febrero 2013
* 30 de enero de 2015
* de diciembre de 2015 a septiembre de 2017










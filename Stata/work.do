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
ambos=s_ambos_e noespecif=s_no_especificado_e suscrip=s_total_e, by(date)
save "tmp\l_tv_rest.dta"

clear all
use "ift\sus_int_fija.dta"
keep if year>=2014
collapse (sum) resid=s_residencial_e noresid=s_no_residencial_e ///
suscrip=s_total_e, by(date)
save "tmp\l_int_fija.dta"

clear all
use "ift\lin_tel_mov.dta"
keep if year>=2014
collapse (sum) suscrip=l_total_e prepago=l_prepago_e ///
pospagoc=l_pospagoc_e pospagol=l_pospagol_e, by(date)
save "tmp\l_tel_mov.dta"















































































clear all
use "ift\acc_int_fija.dta"
xtset k_acceso_internet date
xtline a_total, ov







































































































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



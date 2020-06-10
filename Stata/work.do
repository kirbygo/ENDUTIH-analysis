
*Stata 16.0 MP
*Windows 10
/*
      ooooooooooooooooooooooooooooooooooooo
      8                                .d88
      8  oooooooooooooooooooooooooooood8888
      8  8888888888888888888888888P"   8888    oooooooooooooooo
      8  8888888888888888888888P"      8888    8              8
      8  8888888888888888888P"         8888    8             d8
      8  8888888888888888P"            8888    8            d88
      8  8888888888888P"               8888    8           d888
      8  8888888888P"                  8888    8          d8888
      8  8888888P"                     8888    8         d88888
      8  8888P"                        8888    8        d888888
      8  8888oooooooooooooooooooooocgmm8888    8       d8888888
      8 .od88888888888888888888888888888888    8      d88888888
      8888888888888888888888888888888888888    8     d888888888
                                               8    d8888888888
         ooooooooooooooooooooooooooooooo       8   d88888888888
        d                       ...oood8b      8  d888888888888
       d              ...oood888888888888b     8 d8888888888888
      d     ...oood88888888888888888888888b    8d88888888888888
     dood8888888888888888888888888888888888b
*/
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------¨
                                *CORRER ESTO SIEMPRE
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
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------


*Bajar info de la INEGI, 2018. Y unzip
cap mkdir data
cd data

forvalues i = 2015/2019 {
	copy "https://www.inegi.org.mx/contenidos/programas/dutih/`i'/microdatos/dutih`i'_bd_dbf.zip" "dutih`i'_bd_dbf.zip"
	copy "https://www.inegi.org.mx/contenidos/programas/dutih/`i'/doc/dutih`i'_fd.xlsx" "dutih`i'_fd.xlsx"
	unzipfile dutih`i'_bd_dbf.zip, replace
}

cd $dir

*Una vez descargadas las bases HAY QUE PASARLAS A CVS desde excel pues en dbf cuando lo importa a stata genera missings sin sentido.

*generar directorio donde guarde las bases "limpias"
cap mkdir "2018 limpias"

*Importar la base
 import delimited using "$dir\dutih2018_bd_dbf\Base de datos\tic_2018_viviendas.csv", clear

*Ver str a int
*destring UPM VIV_SEL P1_1 P1_2 P1_3 P1_4 P1_5_1 P1_5_2 P1_5_3 P2_1 P2_2 ENT FAC_VIV UPM_DIS EST_DIS TLOC ESTRATO P2_3 CD_ENDUTIH, replace

tab p2_3, m

*Que la variable P2_3 sea missing significa que es solo un hogar por vivienda ¿cuántos hogares o grupos de personas tienen gasto separado para comer contando el de usted?
*Por lo que hay que convertir los missings en 1
replace p2_3 = 1 if missing(p2_3)

tab cd_endutih, m
*Que la variable CD_ENDUTIH sea missing significa que no es una ciudad sino que está en zona rural.

*DOMINIO no se destring porque U=urbano R=rural, mejor la hacemos numérica
encode dominio , generate(dominio2)
tab dominio2, nol
*1=rual; 2=urbano 
*Guardar la base limpia
save "$dir\2018 limpias\viviendas_2018.dta", replace
*-----------------------------------------------------------------------------------------
*------------------------AHORA LO MISMO PARA LA BASE DE HOGARES--------------------------- ------------------------------------------------------------------------------------------
*Importar la base
clear all
import delimited using "$dir\dutih2018_bd_dbf\Base de datos\tic_2018_hogares.csv", clear
 
*Ver str a int
*destring UPM VIV_SEL HOGAR P4_1_1 P4_1_2 P4_1_3 P4_1_4 P4_1_5 P4_1_6 P4_2_1 P4_2_2 P4_2_3 P4_3 P4_3A P4_4 P4_5 P4_6_1 P4_6_2 P4_6_3 P4_6_4 P4_6_5 P4_6_6 P4_6A P4_7_1 P4_7_2 P4_7_3 P4_7_4 P4_7A P4_8 P4_8A P5_1 P5_2_1 P5_2_2 P5_3 P5_3A P5_4 P5_5_1 P5_5_2 P5_5_3 P5_5_4 P5_6_1 P5_7_1 P5_8_1 P5_9_1 P5_6_2 P5_7_2 P5_8_2 P5_9_2 P5_6_3 P5_7_3 P5_8_3 P5_9_3 P5_6_4 P5_7_4 P5_8_4 P5_9_4 P5_6_5 P5_7_5 P5_8_5 P5_6_6 P5_7_6 P5_8_6 P5_6_7 P5_7_7 P5_8_7 P5_10_1 P5_10_2 P5_10_3 ENT CD_ENDUTIH FAC_HOG UPM_DIS EST_DIS DOMINIO TLOC ESTRATO, replace

tab cd_endutih, m
*Que la variable CD_ENDUTIH sea missing significa que no es una ciudad sino que está en zona rural o no es ciudad principal. (43732 missing)

*Los missings de las otras preguntas es porque debieron contestar que no tenían el servicio y como son preguntas relacionadas con el servicio por eso son missings.
*P5_3_A ; P4_8A; P4_7A; P4_6A; P4_3A; no tiene numéricos porque son razones.

*DOMINIO no se destring porque U=urbano R=rural, mejor la hacemos numérica
encode dominio , generate(dominio2)
tab dominio2, nol
*1=rual; 2=urbano 
*Guardar la base limpia
save "$dir\2018 limpias\hogares_2018.dta", replace

*-----------------------------------------------------------------------------------------
*------------------------AHORA LO MISMO PARA LA BASE DE RESIDENTES------------------------ ------------------------------------------------------------------------------------------ *Importar la base
clear all
 import delimited using "$dir\dutih2018_bd_dbf\Base de datos\tic_2018_residentes.csv", clear
 

*Ver str a int
*destring UPM VIV_SEL HOGAR NUM_REN PAREN SEXO EDAD P3_7 NIVEL GRADO P3_9_1 P3_9_2 P3_9_3 P3_10 P3_11 P3_12 ENT CD_ENDUTIH FAC_HOG UPM_DIS EST_DIS DOMINIO TLOC ESTRATO, replace 

tab cd_endutih, m 
*Que la variable CD_ENDUTIH sea missing significa que no es una ciudad sino que está en zona rural o en una ciudad principal. 161069 missing values generated.

*DOMINIO no se destring porque U=urbano R=rural, mejor la hacemos numérica
encode dominio , generate(dominio2)
tab dominio2, nol
*1=rual; 2=urbano 
*Guardar la base limpia
save "$dir\2018 limpias\residentes_2018.dta", replace

*-----------------------------------------------------------------------------------------
*------------------------AHORA LO MISMO PARA LA BASE DE USUARIOS------------------------ ------------------------------------------------------------------------------------------ 
*Importar la base
clear all
 import delimited using "$dir\dutih2018_bd_dbf\Base de datos\tic_2018_usuarios.csv", clear
 
*Ver str a int
*destring UPM VIV_SEL HOGAR NUM_REN EDAD P6_1 P6_2_1 P6_2_2 P6_2_3 P6_3 P6_3A P6_4 P6_5 P6_6_1 P6_6_2 P6_6_3 P6_6_4 P6_6_5 P6_6_6 P6_6_7 P6_6A P6_7_1 P6_7_2 P6_7_3 P6_7_4 P6_7_5 P6_7_6 P6_7_7 P6_7_8 P6_7A P6_8_1 P6_8_2 P6_8_3 P6_8_4 P6_8_5 P6_8_6 P6_8_7 P6_8_8 P6_8_9 P6_8_10 P6_8A P6_9_1 P6_9_2 P6_9_3 P6_9_4 P6_9_5 P6_9_6 P6_9A P7_1 P7_2 P7_2A P7_3 P7_4 P7_5_1 P7_5_2 P7_5_3 P7_5_4 P7_5_5 P7_5_6 P7_5_7 P7_5A P7_6 P7_7_1 P7_7_2 P7_7_3 P7_7_4 P7_7_5 P7_7_6 P7_7_7 P7_7_8 P7_7A P7_8_1 P7_8_2 P7_8_3 P7_8_4 P7_8_5 P7_8_6 P7_8_7 P7_8A P7_9_1 P7_9_2 P7_9_3 P7_9_4 P7_9A P7_10_1 P7_10_2 P7_10_3 P7_10_4 P7_10A P7_11_1 P7_11_2 P7_11_3 P7_11_4 P7_11_5 P7_11_6 P7_11_7 P7_11A P7_12 P7_13 P7_14_1 P7_14_2 P7_14_3 P7_14_4 P7_14_5 P7_14_6 P7_14A P7_15_1 P7_15_2 P7_16_1 P7_16_2 P7_16_3 P7_16_4 P7_16_5 P7_16_6 P7_16_7 P7_16_8 P7_16A P7_17 P7_18 P7_19 P7_20_1 P7_20_2 P7_20_3 P7_20_4 P7_20_5 P7_20_6 P7_20_7 P7_20_8 P7_20A P7_21 P7_22_1 P7_22_2 P7_22_3 P7_22_4 P7_22_5 P7_22_6 P7_22_7 P7_22_8 P7_22_9 P7_22_10 P7_22_11 P7_22_12 P7_22A P7_23 P7_24 P7_25_1 P7_25_2 P7_25_3 P7_25_4 P7_25A P7_26 P7_27 P7_27A P7_28 P7_29_1 P7_29_2 P7_29_3 P7_29_4 P7_29_5 P7_29_6 P7_29A P7_30_1 P7_30_2 P7_30_3 P7_30_4 P7_30_5 P7_30A P7_31 P7_32_1 P7_32_2 P7_32_3 P7_32_4 P7_32_5 P7_32A P7_33_1 P7_33_2 P7_33_3 P7_33_4 P7_33_5 P7_33A P7_34_1 P7_34_2 P7_34_3 P7_34_4 P7_34A P7_35 P8_1 P8_2 P8_2A P8_3 P8_4_1 P8_4_2 P8_5_1 P8_5_2 P8_6 P8_7_1 P8_7_2 P8_7_3 P8_8 P8_9 P8_10 P8_11_1 P8_11_2 P8_12 P8_13_1 P8_13_2 P8_14_1 P8_14_2 P8_14_3 P8_14_4 P8_14_5 P8_14_6 P8_14_7 P8_14_8 P8_14A P8_15 P8_16 ENT CD_ENDUTIH FAC_PER UPM_DIS EST_DIS DOMINIO TLOC ESTRATO SEXO NIVEL, replace 

tab cd_endutih, m
*Que la variable CD_ENDUTIH sea missing significa que no es una ciudad sino que está en zona rural o en ciudad no principal. 43732 missing values generated.

*DOMINIO no se destring porque U=urbano R=rural, mejor la hacemos numérica
encode dominio , generate(dominio2)
tab dominio2, nol 
*1=rual; 2=urbano 
tab dominio cd_endutih, m

*Guardar la base limpia
save "$dir\2018 limpias\usuarios_2018.dta", replace

====================================================================================================================================================================================================================================================================================
*------------------------------ESTO DE AQUÍ SE ME HACE QUE NO----                          ----------------VA A SER NECESARIO POR EL MOMENTO PERO LO DEJO POR SI-------------------  ----------------------------------------SE REQUIERE---------------------------------------
*-----------------------------------------------------------------------------------------

*Juntar las bases Hogares con viviendas
clear all
use "$dir\2018 limpias\hogares_2018.dta"
merge m:1 UPM VIV_SEL using "$dir\2018 limpias\viviendas_2018.dta"
drop _merge

*Juntar hogares-viendas-usuarios
merge 1:1 UPM VIV_SEL HOGAR using "$dir\2018 limpias\usuarios_2018.dta"

drop _merge
merge 1:m UPM VIV_SEL HOGAR NUM_REN using "$dir\2018 limpias\residentes_2018.dta"


tab P3_9_2 SEXO [fw = FAC_HOG] if P3_9_2<8

====================================================================================================================================================================================================================================================================================



*Usuarios de internet por sexo
*clear all
*<<<<<<< HEAD
*use "$dir\2018 limpias\usuarios_2018.dta"

*svyset UPM [pw=FAC_PER], strata(EST_DIS) vce(linearized)
*======
*use "$dir\2018 limpias\residentes_2018.dta"
*tab P3_9_2 SEXO [fw = FAC_HOG]
*>>>>>>> c91096d0ba2c5d47d0aa7b54bc57a548175d2238

*svy: tab P7_1 SEXO, format(%11.3g) count se cv ci level(90)

*<<<<<<< HEAD



*----------------------------------------------------------------------------------------------------------------------REPLICAR TABLAS DE LA INEGI--------------------------------------
*-------------------------------------------------------------------------------------------

**************************HOGARES QUE DISPONEN DE TELEVISOR*********************************
clear all
use "$dir\2018 limpias\hogares_2018.dta"

*esto era solo para checar que no hubiera missing en esta variable porque sinoooooooooo estariamos mal
tab fac_hog, m


*televisor analógico
tab p4_1_2 [fw = fac_hog]

*televisor digital
tab p4_1_4 [fw = fac_hog]

*ambos
gen tv2tipos = p4_1_2 * p4_1_4
tab tv2tipos [fw = fac_hog]

** tv2tipos=1 significa que tienen ambos tipos de televisores; tv2tipos=2 significa que tienen solo 1 tipo de televisor; tv2tipos=4 significa que no tienen de ningun tipo.
*los que tienen televisor
tab tv2tipos if tv2tipos != 4 [fw = fac_hog]

*de los que tienen solo un tipo de televisor cuáles tienen analógica
tab p4_1_2 if tv2tipos == 2 [fw = fac_hog]

*de los que tienen solo un tipo de televisor cuáles tienen digital
tab p4_1_4 if tv2tipos == 2 [fw = fac_hog]


***************************USUARIOS DE TELEFONÍA CELULAR POR ENTIDAD************************
clear all
use "$dir\2018 limpias\usuarios_2018.dta"

*esto era solo para checar que no hubiera missing en esta variable porque sinoooooooooo estariamos mal
tab fac_per, m

*Dispone de celuar 
tab p8_1 [fw = fac_per],  m

*Dispone de celular + lo ha usado en los últimos 3 meses
tab p8_1 p8_3 [fw = fac_per]
 
*generar variable de disus (de los que tienen por los que lo han usado en los últimos 3 meses)
 gen disus = 0
 replace disus = 1 if p8_1 * p8_3 == 1
tab disus [fw = fac_per]

*Dispone de celular por entidad
tab ent disus [fw = fac_per]

*Dispone de celular por entidad urbano / rural
table ent disus dominio [fw = fac_per]

*Generar una minibase con solo observaciones por entidad 
gen nodisus = 0 
replace nodisus = 1 if disus == 0

preserve
collapse (sum) disus nodisus  [fw = fac_per], by(ent)
save "$dir\mapas\usuariosnotelefcel.dta", replace
restore


***********************USUARIOS DE TELEF CELULAR POR NIVEL DE ESCOLARIDAD******************
clear all
use "$dir\2018 limpias\usuarios_2018.dta"
 
*generar variable de disus (de los que tienen por los que lo han usado en los últimos 3 meses)
 gen disus = 0
 replace disus = 1 if p8_1 * p8_3 == 1
 
 *Usuarios de telefonia celular
tab disus [fw = fac_per]

*Usuarios de telefonia celular por nivel de escolaridad

table nivel disus [fw = fac_per], f(%15.0fc) row 

*Por grupo de educación qué porcentage lo usa
tab nivel disus [fw = fac_per], row

*Del total de los que tiene telf celular qué % son de cada nivel de escolaridad
tab nivel disus [fw = fac_per], col



















*Usuarios de internet por sexo
clear all
use "$dir\2018 limpias\usuarios_2018.dta"
*svyset UPM_DIS [pw=FAC_PER], strata(EST_DIS) vce(linearized)

svy: tab P7_1 SEXO, format(%11.3g) count se cv ci level(90)
>>>>>>> c91096d0ba2c5d47d0aa7b54bc57a548175d2238
**ya guardé mis cambios






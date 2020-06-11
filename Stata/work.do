
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
*Una vez descargadas las bases HAY QUE PASARLAS A CVS desde excel pues en dbf 
* cuando lo importa a stata genera missings sin sentido.
* Otros diversos ajustes manuales de bases

*generar directorio donde guarde las bases "limpias"
cap mkdir "db"

*Importar la base
use "$dir\db\2015-hogares", clear
destring D_R EST_DIS P* UPM_DIS VIV_SEL aream ent hogar nreninfo upm, replace


**************************HOGARES QUE DISPONEN DE TELEVISOR*********************************
*esto era solo para checar que no hubiera missing en esta variable porque sinoooooooooo estariamos mal
tab hogar, m

*televisor analógico
tab P4_1_2 [fw = hogar], m

*televisor digital
tab P4_1_4 [fw = hogar]

*ambos
gen tv2tipos = P4_1_2 * P4_1_4
tab tv2tipos [fw = hogar]

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






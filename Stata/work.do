
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
*Imposible importar bien DBFs, se hizo con Stat-Transfer

*generar directorio donde guarde las bases "limpias"
cap mkdir "db"

*Importar la base
use "$dir\db\2015-hogares", clear
destring D_R EST_DIS P* UPM_DIS VIV_SEL aream ent hogar nreninfo upm, replace


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



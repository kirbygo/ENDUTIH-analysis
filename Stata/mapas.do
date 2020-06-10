
*Mapas
/*
.
\'~~~-,
 \    '-,_ 
  \ /\    `~'~''\          M E X I C O
  _\ \\          \/~\ 
  \__ \\             \   
     \ \\.             \  
      \ \ \             `~~
       '\\ \.             /
        L \  \            |
         \_\  \           |             _.----,
               |           \           !     /
              '._           \_      __/    _/
                 \_           ''--''    __/
                   \.__                |
                       ''.__  __.._   __\
                            ''     './  `
*/
********************************************************************************
***************************************DISCLAIMER*******************************
*Stata 16.0 MP
*Windows 10
********************************************************************************
******************************************PREAMBULO*****************************
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
********************************************************************************
************************************HACER SOLO UNA VEZ**************************
cd $dir
cap mkdir Mapas
*Descargamos el shape de mapas de INEGI
cd $dir\Mapas

clear all
copy "http://internet.contenidos.inegi.org.mx/contenidos/Productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marc_geo/702825217341_s.zip" ///
 "mexico.zip"
*Abrimos el zip
unzipfile "mexico.zip", replace

*Si queremos juntar varios shapes, hacer lo siguiente:
*Transformamos el shape en QGis
*Porque INEGI los tienen en una proyección (Lambert Cónica)
*Abrir el shp en QGis
*Exportamos en Capa > Guardar Como
*Cambiar el SRC al predeterminado: "EPSG:4326 - WGS 84"
*Esas son las coordenadas tal cual las tiene el google maps (decimales)
*Pero como no es el caso, no es necesario
*Pasamos a dta el mapa estatal

clear all
cd $dir\mapas\conjunto_de_datos
spshape2dta areas_geoestadisticas_estatales, saving("estados")

*movemos a mapas
copy "$dir\mapas\conjunto_de_datos\estados_shp.dta" "$dir\mapas\estados_shp.dta", replace
copy "$dir\mapas\conjunto_de_datos\estados.dta" "$dir\mapas\estados.dta", replace

erase "$dir\mapas\conjunto_de_datos\estados_shp.dta"
erase "$dir\mapas\conjunto_de_datos\estados.dta"



*****Aqui empezamos con el mapa*****
clear all
cd $dir\mapas
use estados

*AQUI HACEMOS LOS MERGES CORRESPONDIENTES CON LO QUE QUERRAMOS METER AL MAPA






merge 1:1 ent using "$dir\mapas\usuariosnotelefcel.dta"

save "$dir\mapas\estados.dta", replace





*arreglamos temas
drop _merge
destring CVE_ENT, replace
rename CVE_ENT ent
replace NOM_ENT = "BC" in 2
replace NOM_ENT = "BCS" in 3
replace NOM_ENT = "Coahuila" in 5
replace NOM_ENT = "CDMX" in 9
replace NOM_ENT = "México" in 15
replace NOM_ENT = "Michoacán" in 16
replace NOM_ENT = "Nuevo León" in 19
replace NOM_ENT = "Querétaro" in 22
replace NOM_ENT = "SLP" in 24
replace NOM_ENT = "Veracruz" in 30
replace NOM_ENT = "Yucatan" in 31
form disus nodisus  %30.0fc
gen pobtotal = 	disus + nodisus
form pobtotal  %30.0fc
gen porcdisus = disus/pobtotal
gen porcnodisus = nodisus/pobtotal
form porcdisus porcnodisus  %9.2f
gen pdisus = porcdisus*100
gen pnodisus = porcnodisus*100
form pdisus pnodisus %9.2fc
save "$dir\mapas\estados.dta", replace

*Ya haces el mapa con todas las opciones del mundo
clear all 
use estados
grmap disus, osize(vvthin ..) ndfcolor(white) ocolor(black) cln(12) lab(x(_CX) y(_CY) l(NOM_ENT) si(tiny) po(0) an(45)) legtitle("Número de usuarios") fcolor(Reds2)   legstyle(2) ti("Usuarios de telefonía celular") sub("2018")
graph export "mapausuariostelefoníacelular.png", as(png) wid(5000) replace

*Mapa con los porcentajes de uuarios de telefonía móvil por población total 
clear all 
use estados
grmap pdisus, osize(vvthin ..) ndfcolor(white) ocolor(black) cln(12) lab(x(_CX) y(_CY) l(NOM_ENT) si(tiny) po(0) an(45)) legtitle("Porcentaje") fcolor(Reds2)   legstyle(2) ti("Usuarios de telefonía celular por población") sub("2018")
graph export "mapaporcusuariostelefoníacelular2.png", as(png) wid(5000) replace




*Para guardar el mapa*****
graph export "mapausuariostelefoníacelular.png", as(png) wid(5000) replace

********************************************************************************
*************************************MAPAS
cd $dir\mapas
clear all

use estados
grmap, osize(vthin ..) ndfcolor(white) ocolor(black)


*Prod Nal
grmap, osize(vthin ..) ndfcolor(white) ocolor(black) 

graph export "mapadealgo.png", as(png) wid(5000) replace

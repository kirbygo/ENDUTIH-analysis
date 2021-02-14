*Preamble
*Cambio directorio
* Prueba si el escritorio está en C o en D y establece el necesario
clear all
cd "D:\0kirbygo\Desktop\telecom_new"

*El directorio base: Carpeta Work en Escritorio
global dir : pwd
cd $dir


******************************************************************** INCOME PPP
clear all
import excel telecom_new.xlsx, sheet("bdStata") firstrow

replace id = pais + "-" + empresa

encode id, g(id1)

format fecha %td

replace fecha = fecha + td(30dec1899)
gen time = hofd(fecha)
format time %th

xtset id1 time, h

xtline ing_usd_ppp, over ///
title("Income of the main telecom providers in Latin America, PPP-adjusted") ///
ytitle("Income USD (PPP-adjusted), millions") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the IFT, OECD and financial statements.")
*Salvar
graph export "inc-ppp.png", as(png) wid(4000) replace

gen ing_usd_ppp_lin = (ing_usd_ppp*1000000)/lineas

xtline ing_usd_ppp_lin, over ///
title("Income per line of the main telecom providers in Latin America, PPP-adjusted") ///
ytitle("Income USD (PPP-adjusted), per line") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the IFT, OECD and financial statements.")
*Salvar
graph export "inc-ppp-line.png", as(png) wid(4000) replace

******************************************* Total mobile suscriptions

clear all
import excel "D:\0kirbygo\Desktop\telecom_new\OECD.xlsx", sheet("Stata") firstrow
reshape long datapersus susperhundhab sus, i(country) j(year)
encode country, g(id)

xtset id year,y

xtline susperhundhab if id==4 | id==5 | id==6 | id==11 | id==12 | id==18 | id==24 | id==28 | id==30 | id==33 | id==36 | id==37 | id==38 , over ///
title("Total mobile broadband subscriptions per 100 inhabitants") ///
ytitle("Sus per 100 inhab") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the OECD.")

graph export "susperhab.png", as(png) wid(4000) replace

xtline datapersus if id==4 | id==5 | id==6 | id==11 | id==12 | id==18 | id==24 | id==28 | id==30 | id==33 | id==36 | id==37 | id==38 , over ///
title("Mobile data usage per mobile broadband suscription") ///
ytitle("GB per sus") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the OECD.")

graph export "datapersus.png", as(png) wid(4000) replace


****************************************** OCDE prices
clear all
import excel "D:\0kirbygo\Desktop\telecom_new\OECD2.xlsx", sheet("Stata") firstrow
reshape long low med high, i(country) j(year)
encode country, g(id)

xtset id year,y

xtline low if id==4 | id==5 | id==10 | id==11 | id==17 | id==22 | id==26 | id==28 | id==31 | id==34 | id==35 | id==36 , over ///
title("Mobile broadband basket price (low users, 100 calls + 500 MB + VAT), 2016-2017") ///
ytitle("USD PPP-adjusted") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the OECD.")

graph export "low.png", as(png) wid(4000) replace

xtline med if id==4 | id==5 | id==10 | id==11 | id==17 | id==22 | id==26 | id==28 | id==31 | id==34 | id==35 | id==36 , over ///
title("Mobile broadband basket price (mid users, 300 calls + 1 GB + VAT), 2016-2017") ///
ytitle("USD PPP-adjusted") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the OECD.")

graph export "med.png", as(png) wid(4000) replace

xtline high if id==4 | id==5 | id==10 | id==11 | id==17 | id==22 | id==26 | id==28 | id==31 | id==34 | id==35 | id==36 , over ///
title("Mobile broadband basket price (high users, 900 calls + 2 GB + VAT), 2016-2017") ///
ytitle("USD PPP-adjusted") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the OECD.")

graph export "high.png", as(png) wid(4000) replace






************************************** AMERICA MOVIL STOCK PRICES

clear all
import delimited "D:\0kirbygo\Desktop\telecom_new\AMX.csv"

gen fecha = date(date,"YMD")
format fecha %td
gen fechanum=fecha

gen year = yofd(fecha)
gen month = mofd(fecha)
drop if year ==2009

gen prepo = 0
replace prepo = 1 if fecha>=19788

bysort prepo : egen media = mean(close)

tsset fecha, d
tsline close media, tline(19788) ttext(14 19788 "Substantial power declared (March 6th, 2014)", place(west) orient(vertical) size(vsmall)) ///
legend(label(1 "AMX price") label(2 "Price mean") region(color(white))) ///
title("AMX stock price index") ///
ytitle("Price (USD)") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#6 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the NYSE.")

graph export "AMX.png", as(png) wid(4000) replace




**************************** America movil stock prices counterfactual
clear all
import delimited "D:\0kirbygo\Desktop\telecom_new\AMX.csv"

gen fecha = date(date,"YMD")
format fecha %td
gen fechanum=fecha

gen year = yofd(fecha)
gen month = mofd(fecha)
drop if year ==2009

*calendarito
bcal create "stockcal.stbcal", from(fecha) replace
bcal load stockcal
generate bcaldate = bofd("stockcal",fecha)
assert !missing(bcaldate) if !missing(fecha)
format %tbstockcal bcaldate

tsset bcaldate

gen trend= _n

corrgram close
gen dclose = D.close
gen ldclose = L.dclose
gen lclose = L.close
corrgram dclose

*Chistoso, es ruido blanco en 1as dif haha
*wntestb dclose

*arima close, arima(1,1,0)

* Que según esto el cambio ocurrió en 24-11-2014 (23-1-2015, si lo corres en niveles) reg close lclose ene, robust

gen dvolume = D.volume
gen dhigh = D.high
gen dlow = D.low

gen neg = 0
replace neg=1 if dclose<0


gen dow = dow(fecha)
gen moy = month(fecha)
tab dow, g(m)
tab moy, g(mo)

reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11, robust
estat sbsingle, ltrim(30) rtrim(48)
*bcaldate empieza en ceros
*18 abril 2018 gana amparo tarifa cero Telmex Telnor
*16 agosto 2017 gana amparo tarifa cero Telcel
*19 febrero 2015 pierde primer amparo de tarifa cero
*1 enero 2015 YA EMPIEZA TARIFA CERO
*14 julio 2014 LFTyR (art 141 dice que tarifa prepo debe ser cero)
*6 marzo 2014 preponderancia 1050 en obs, bcaldate es 1049
*11 jun 2013 reforma telecom, 865 en obs, 864 en bcaldate


estat sbknown, break(1049)
estat sbknown, break(864)

tsline close, ///
tline(1050) ttext(14 1050 "Substantial power declared (March 6th, 2014)", place(west) orient(vertical) size(vsmall)) ///
tline(865) ttext(14 865 "Telecom reform (June 11th, 2013)", place(west) orient(vertical) size(vsmall)) ///
tline(1259) ttext(14 1259 "Begining of zero inx price (Jan 1st, 2015)", place(west) orient(vertical) size(vsmall)) ///
tline(1139) ttext(14 1139 "New Federal Law of Telecom (July 14th, 2014)", place(west) orient(vertical) size(vsmall)) ///
legend(label(1 "AMX price") label(2 "Price mean") region(color(white))) ///
title("AMX stock price index") ///
ytitle("Price (USD)") ysize(10) ylabel(#15 , format(%15.0gc) angle(0)) ///
ttitle("Date") xsize(20) tlabel(#18 , angle(25)) ///
scheme(538) graphregion(color(white) icolor(white)) plotregion(color(white) icolor(white)) ///
note("Source: Prepared by authors with data of the NYSE.")

graph export "AMX-timeline.png", as(png) wid(4000) replace

gen prepo = 0
*Prepo 6 marzo 2014 obs 1050
replace prepo = 1 if fecha>=19788

gen prepo2 = 0
replace prepo2 = 1 if fecha>=19520
*19520 es 11 jun 2013 es obs 865

gen prepo3 = 0
replace prepo3 = 1 if year>=2015
*2 ene 2015 es obs 1259

gen prepo4 = 0
replace prepo4 = 1 if fecha>=19918
*14 julio 2014 LFTyR obs 1139, fecha 19918


reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo==0, robust
estimates store model1
reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo2==0, robust
estimates store model2
reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo3==0, robust
estimates store model3
reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo4==0, robust
estimates store model4

putdocx begin
putdocx paragraph
putdocx text ("Resultados del modelo según el corte"), bold
putdocx paragraph
estimates table model2 model1 model4 model3, b(%10.3f) star stats(N r2 r2_a) varlabel allbaselevels
putdocx table tbl1 = etable
putdocx save "regress.docx", replace

*******PREPO
reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo==0, robust

cap drop perro y
predict perro

gen y = .
replace y = close in 1049
local enesota = _N
forvalues i = 1050/`enesota' {
	local j = `i' - 1
	replace y = y[`j'] + perro[`i'] in `i'
}

tsline y close, ///
title("Prediction if AMX stock had kept its behaviour pre-dominance declared") ///
ttitle("Date") ytitle("AMX stock (USD)") ysize(12) ///
ylabel(#10 , format(%15.0gc) angle(0)) xlabel(#12 , angle(25)) xsize(20) ///
scheme(538) legend(label(2 "Actual price") label(1 "Prediction")) ///
tlabel(#18 , angle(25))

graph export "prepo.png", as(png) wid(4000) replace

*******PREPO2
reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo2==0, robust

cap drop perro y
predict perro

gen y = .
replace y = close in 864
local enesota = _N
forvalues i = 865/`enesota' {
	local j = `i' - 1
	replace y = y[`j'] + perro[`i'] in `i'
}

tsline y close, ///
title("Prediction if AMX stock had kept its behaviour pre-dominance declared") ///
ttitle("Date") ytitle("AMX stock (USD)") ysize(12) ///
ylabel(#10 , format(%15.0gc) angle(0)) xlabel(#12 , angle(25)) xsize(20) ///
scheme(538) legend(label(2 "Actual price") label(1 "Prediction")) ///
tlabel(#18 , angle(25))

graph export "prepo2.png", as(png) wid(4000) replace

*******PREPO3
reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo3==0, robust

cap drop perro y
predict perro

gen y = .
replace y = close in 1258
local enesota = _N
forvalues i = 1259/`enesota' {
	local j = `i' - 1
	replace y = y[`j'] + perro[`i'] in `i'
}

tsline y close, ///
title("Prediction if AMX stock had kept its behaviour pre-dominance declared") ///
ttitle("Date") ytitle("AMX stock (USD)") ysize(12) ///
ylabel(#10 , format(%15.0gc) angle(0)) xlabel(#12 , angle(25)) xsize(20) ///
scheme(538) legend(label(2 "Actual price") label(1 "Prediction")) ///
tlabel(#18 , angle(25))

graph export "prepo3.png", as(png) wid(4000) replace

*******PREPO4
reg dclose ldclose dvolume trend neg m1 m2 m3 m4 mo1 mo2 mo3 mo4 mo5 mo6 mo7 mo8 mo9 mo10 mo11 if prepo4==0, robust

cap drop perro y
predict perro

gen y = .
replace y = close in 1138
local enesota = _N
forvalues i = 1139/`enesota' {
	local j = `i' - 1
	replace y = y[`j'] + perro[`i'] in `i'
}

tsline y close, ///
title("Prediction if AMX stock had kept its behaviour pre-dominance declared") ///
ttitle("Date") ytitle("AMX stock (USD)") ysize(12) ///
ylabel(#10 , format(%15.0gc) angle(0)) xlabel(#12 , angle(25)) xsize(20) ///
scheme(538) legend(label(2 "Actual price") label(1 "Prediction")) ///
tlabel(#18 , angle(25))

graph export "prepo4.png", as(png) wid(4000) replace



































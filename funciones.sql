-- FUNCTION: public.modificarcliente(character varying, character varying, character varying, character varying, character, character varying, character varying, character, integer, character varying, character varying)

-- DROP FUNCTION public.modificarcliente(character varying, character varying, character varying, character varying, character, character varying, character varying, character, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION public.modificarcliente(
	nombre character varying,
	segundonombre character varying,
	priapellido character varying,
	segapellido character varying,
	cedula character,
	tipo character varying,
	direccion character varying,
	telefono character,
	ingreso integer,
	contrasena character varying,
	moneda character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
error text; 

begin
IF not((select "Estado" from "CLIENTE" where "Cedula"=Cedula)='A') then
	return 'no existe un cliente activo con esa cedula'; 
ELSIF not((Tipo='Fisico') or (Tipo ='Juridico')) then   
	return 'El tipo de cliente debe ser Fisico o Juridico';
ELSIF (Tipo = 'Fisico' and PriApellido is not null and SegApellido is not null)or
(Tipo='Juridico' and SegundoNombre is null and PriApellido is null and SegApellido is null )  THEN
    BEGIN
   UPDATE public."CLIENTE"
	SET "Nombre"=Nombre, "SegundoNombre"=SegundoNombre, "PriApellido"=PriApellido, "SegApellido"=SegApellido, "Cedula"=Cedula, "Tipo"=Tipo, "Direccion"=Direccion, "Telefono "=Telefono, "Ingreso"=Ingreso,"Contrasena"=Contrasena, "Moneda"=Moneda 
	WHERE "Cedula"=Cedula;
    if not found then
    	return 'no existe un cliente con esa cedula';
    else
        return 'ok';
    end if;
	EXCEPTION when SQLSTATE '23505' then 
    	return 'La cedula indicada pertenece a otro cliente';
     when SQLSTATE '23502' then 
    	return 'ha ingresado valores  nulos no permitidos'; 
     when SQLSTATE '23514' then 
    	GET STACKED DIAGNOSTICS error =CONSTRAINT_NAME;
        if (error='IngresoConstraint') then
    	return 'El ingreso debe ser un numero positivo';
        elsif error='MonedaConstraint' then
        return 'Las monedas validas son Colones, Dolares o Euros';
        end if; 
    END;
else
	return 'Para clientes fisicos los apellidos son requeridos//Para clientes juridicos segundo nombre y los apellidos no se deben agregar';
end if;
end; 

$function$;

ALTER FUNCTION public.modificarcliente(character varying, character varying, character varying, character varying, character, character varying, character varying, character, integer, character varying, character varying)
    OWNER TO postgres;
    
   
-- FUNCTION: public.pmt(numeric, integer, numeric)

-- DROP FUNCTION public.pmt(numeric, integer, numeric);

CREATE OR REPLACE FUNCTION public.pmt(
	interestrate numeric,
	nper integer,
	pv numeric)
    RETURNS money
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
Valor money;
begin
Valor=(InterestRate / 100)
    /(Power(((1 + InterestRate / 100)),Nper)-1)
    * -(-Pv*Power(((1 + InterestRate / 100)),Nper)
    );
return valor::money;
end; 

$function$;

ALTER FUNCTION public.pmt(numeric, integer, numeric)
    OWNER TO postgres;   
   
   
-- FUNCTION: public.calendariopagos(integer, integer)

-- DROP FUNCTION public.calendariopagos(integer, integer);

CREATE OR REPLACE FUNCTION public.calendariopagos(
	numprestamo integer,
	meses integer)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
prestamo "PRESTAMO"%ROWTYPE;
FechaActual date;
saldo money;
cuota money;
inter numeric;
amort money;
Monto money;
MontoInteres money;
cedcliente character(9);
begin
select * into prestamo from "PRESTAMO"  where "Numero"=numprestamo and "Estado"='A';
if not found then
return 'no existe un prestamo con ese numero';
end if;
if (not(select "Estado" from "CLIENTE" where "Cedula"=prestamo."CedCliente")='A') then
return 'Cliente no existe o está inactivo';
end if;
FechaActual=current_date;
saldo=prestamo."SaldoOrig";
inter=prestamo."Interes";
cedcliente=prestamo."CedCliente";

if meses<=0 then 
	return 'el pago debe hacerse en una cantidad de meses diferente';
end if;
LOOP
 FechaActual=FechaActual+ interval '1 month';
 cuota=pmt(inter,meses,saldo::numeric);
MontoInteres=(saldo*inter/100)::money;
amort=cuota - MontoInteres;
saldo=saldo-amort;
 begin
	INSERT INTO public."PAGO"(
		"Monto", "NumPrestamo", "Fecha", "CedCliente", "MontoInteres","PagosRestantes", "Estado")
		VALUES (amort, numprestamo, FechaActual, cedcliente, MontoInteres, meses, 'Pendiente');
    meses=meses-1;
    
    EXIT WHEN Meses<=0;
     EXCEPTION when others then
    	return 'no se pudo crear el calendario';
 end;
END LOOP;
return 'ok';  

end; 

$function$;

ALTER FUNCTION public.calendariopagos(integer, integer)
    OWNER TO postgres;
    
-- FUNCTION: public.reportedemora(character)

-- DROP FUNCTION public.reportedemora(character);

CREATE OR REPLACE FUNCTION public.reportedemora(
	ced character,
	OUT nombrecompleto character varying,
	OUT cedula character,
	OUT numprestamo integer,
	OUT vencidas bigint,
	OUT monto money,
	OUT moneda character varying)
    RETURNS SETOF record 
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE     ROWS 1000.0
AS $function$

declare
fecha date;
cliente "CLIENTE"%ROWTYPE;
nombre character varying;
begin
fecha= current_date;
select * into cliente from "CLIENTE"  where "Cedula"=ced;
if not FOUND then
	return;	
end if;
nombre=cliente."Nombre";
if cliente."Tipo"='Juridio' then
	nombre=cliente."Nombre";
else
	if (cliente."SegundoNombre") is null then
	nombre=CONCAT(cliente."Nombre",' ',cliente."PriApellido",' ',cliente."SegApellido");  
    else
    nombre=CONCAT(cliente."Nombre",' ',cliente."SegundoNombre",' ',cliente."PriApellido",' ',cliente."SegApellido");  
    end if;
end if;
return query select nombre,
ced,"PRESTAMO"."Numero",COUNT("PAGO"."Fecha"),
SUM("PAGO"."Monto"+"PAGO"."MontoInteres"), "PRESTAMO"."Moneda" from "CLIENTE","PRESTAMO","PAGO" 
where "CLIENTE"."Cedula"=ced and "CLIENTE"."Cedula"="PRESTAMO"."CedCliente" and "CLIENTE"."Cedula"="PAGO"."CedCliente" and "PAGO"."NumPrestamo"="PRESTAMO"."Numero"
and "PAGO"."Estado"='Pendiente' and "PRESTAMO"."Estado"='A' and (fecha-"PAGO"."Fecha")>=0 group by "PRESTAMO"."Numero";
  
end; 

$function$;

ALTER FUNCTION public.reportedemora(character)
    OWNER TO postgres;
    
    
-- FUNCTION: public.reportedemorafechas(character)

-- DROP FUNCTION public.reportedemorafechas(character);

CREATE OR REPLACE FUNCTION public.reportedemorafechas(
	ced character,
	OUT nombrecompleto character varying,
	OUT cedula character,
	OUT numprestamo integer,
	OUT vencidas date,
	OUT monto money,
	OUT moneda character varying)
    RETURNS SETOF record 
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE     ROWS 1000.0
AS $function$

declare
fecha date;
cliente "CLIENTE"%ROWTYPE;
nombre character varying;
begin
fecha=current_date;
select * into cliente from "CLIENTE"  where "Cedula"=ced and "Estado"='A';
if not FOUND then
	return;	
end if;
nombre=cliente."Nombre";
if cliente."Tipo"='Juridio' then
	nombre=cliente."Nombre";
else
	if (cliente."SegundoNombre") is null then
	nombre=CONCAT(cliente."Nombre",' ',cliente."PriApellido",' ',cliente."SegApellido");  
    else
    nombre=CONCAT(cliente."Nombre",' ',cliente."SegundoNombre",' ',cliente."PriApellido",' ',cliente."SegApellido");  
    end if;
end if;
return query select nombre,
ced,"PRESTAMO"."Numero","PAGO"."Fecha",
("PAGO"."Monto"+"PAGO"."MontoInteres"), "PRESTAMO"."Moneda" from "CLIENTE","PRESTAMO","PAGO" 
where "CLIENTE"."Cedula"=ced and "CLIENTE"."Cedula"="PRESTAMO"."CedCliente" and "CLIENTE"."Cedula"="PAGO"."CedCliente" and "PAGO"."NumPrestamo"="PRESTAMO"."Numero"
and "PAGO"."Estado"='Pendiente' and "PRESTAMO"."Estado"='A' and (fecha-"PAGO"."Fecha")>=0;
  
end; 

$function$;

ALTER FUNCTION public.reportedemorafechas(character)
    OWNER TO postgres;
    
    
-- FUNCTION: public.reportecomisiones()

-- DROP FUNCTION public.reportecomisiones();

CREATE OR REPLACE FUNCTION public.reportecomisiones(
	OUT nombrecompleto character varying,
	OUT metacolones money,
	OUT metadolares money,
	OUT totalcolones money,
	OUT totaldolares money,
	OUT comisioncolones money,
	OUT comisiondolares money)
    RETURNS SETOF record 
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE     ROWS 1000.0
AS $function$

declare
-- declaracion de variables
asesor "ASESOR"%ROWTYPE;
nombre character varying;
totalcolones money;
totaldolares money;
comisioncolones money;
comisiondolares money;
begin
for asesor in select * from "ASESOR" where "Estado"='A' 
loop
comisioncolones=0::money;
comisiondolares=0::money;
-- construir el nombre completo del asesor
if (asesor."SegNombre") is null then
nombre=CONCAT(asesor."Nombre",' ',asesor."PriApellido",' ',asesor."SegApellido");  
else
nombre=CONCAT(asesor."Nombre",' ',asesor."SegNombre",' ',asesor."PriApellido",' ',asesor."SegApellido");  
end if;
-- cálculo de los creditos totales para el asesor en colones y dolares
totalcolones= sum("PRESTAMO"."SaldoOrig") from "PRESTAMO" where "CedAsesor"=asesor."Cedula" and "Moneda"='Colones' and "Estado"='A';
totaldolares= sum("PRESTAMO"."SaldoOrig") from "PRESTAMO" where "CedAsesor"=asesor."Cedula" and "Moneda"='Dolares'and "Estado"='A';
if totalcolones is null then
	totalcolones=0::money;
end if;
if totaldolares is null then
	totaldolares=0::money;
end if;    
-- se revisa si se llegó a las metas y se obtienen las comisiones en colones y dolares 
if totalcolones>=asesor."MetaColones" then 
	comisioncolones=(totalcolones*0.03)::money;
end if;
if totaldolares>=asesor."MetaDolares" then 
	comisiondolares=(totaldolares*0.03)::money;
end if;
-- retorno de la tabla con el reporte en si sobre lo conseguido por los asesores
return query select distinct nombre,asesor."MetaColones",asesor."MetaDolares",totalcolones,totaldolares,
comisioncolones,comisiondolares from "ASESOR" where "Estado"='A';
end loop; 

end; 

$function$;

ALTER FUNCTION public.reportecomisiones()
    OWNER TO postgres;
    
    
-- FUNCTION: public.cambiomoneda(money, character varying, character varying)

-- DROP FUNCTION public.cambiomoneda(money, character varying, character varying);

CREATE OR REPLACE FUNCTION public.cambiomoneda(
	entrada money,
	inicial character varying,
	fin character varying)
    RETURNS money
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

begin

case inicial when'Colones' then
	 case fin  when 'Colones' then
    	return entrada;
      when 'Dolares' then
    	return (entrada/582)::money;
      when 'Euros' then
    	return (entrada/650)::money; 
       else 
       	return entrada;
    end case;
 when 'Dolares' then
	case fin when 'Colones' then
    	return (entrada*582)::money;
     when 'Dolares' then
    	return entrada;
     when 'Euros' then
    	return (entrada*0.9)::money; 
      else 
       	return entrada;
    end case;
 when 'Euros' then
	case fin when 'Colones' then
    	return (entrada*650)::money;
     when 'Dolares' then
    	return (entrada/0.9)::money;
    when 'Euros' then
    	return entrada; 
      else 
       	return entrada;
    end case;
else 
	return  entrada;
end case;
end; 

$function$;

ALTER FUNCTION public.cambiomoneda(money, character varying, character varying)
    OWNER TO postgres;
    
    
    
-- FUNCTION: public.cambiomoneda(numeric, character varying, character varying)

-- DROP FUNCTION public.cambiomoneda(numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION public.cambiomoneda(
	entrada numeric,
	inicial character varying,
	fin character varying)
    RETURNS money
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

begin

case inicial when'Colones' then
	 case fin  when 'Colones' then
    	return (entrada::money);
      when 'Dolares' then
    	return (entrada/582)::money;
      when 'Euros' then
    	return (entrada/650)::money; 
       else 
       	return entrada;
    end case;
 when 'Dolares' then
	case fin when 'Colones' then
    	return (entrada*582)::money;
     when 'Dolares' then
    	return entrada::money;
     when 'Euros' then
    	return (entrada*0.9)::money; 
      else 
       	return entrada;
    end case;
 when 'Euros' then
	case fin when 'Colones' then
    	return (entrada*650)::money;
     when 'Dolares' then
    	return (entrada/0.9)::money;
    when 'Euros' then
    	return (entrada)::money; 
      else 
       	return entrada;
    end case;
else 
	return  entrada;
end case;
end; 

$function$;

ALTER FUNCTION public.cambiomoneda(numeric, character varying, character varying)
    OWNER TO postgres;    
    
    
-- FUNCTION: public.transferencia(integer, integer, numeric, character varying)

-- DROP FUNCTION public.transferencia(integer, integer, numeric, character varying);

CREATE OR REPLACE FUNCTION public.transferencia(
	emisora integer,
	receptora integer,
	monto numeric,
	moneda character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
cambioemisora money;
cambioreceptora money;
plata money;
montomoney money;
begin
if monto<=0 then
return 'no se puede realizar transferencia con ese monto';
end if;
if not exists (select * from "CUENTA" where "NumCuenta"=emisora and "Estado"='A') then
	return 'no existe la cuenta emisora';
end if;
if not exists (select * from "CUENTA" where "NumCuenta"=receptora and "Estado"='A') then
	return 'no existe la cuenta receptora';
end if;
begin
plata=cambiomoneda(monto,moneda,(select "Moneda" from "CUENTA" where "NumCuenta"=emisora));
cambioemisora= (select "Saldo" from "CUENTA" where "NumCuenta"=emisora)-plata;
if cambioemisora<0::money then
return 'no hay dinero suficiente en la cuenta emisora';
end if;
plata=cambiomoneda(monto,moneda,(select "Moneda" from "CUENTA" where "NumCuenta"=receptora));
cambioreceptora= (select "Saldo" from "CUENTA" where "NumCuenta"=receptora)+plata;
montomoney=monto::money;
INSERT INTO public."TRANSFERENCIA"(
	"Monto", "Fecha", "CuentaEmisora", "CuentaReceptora", "Moneda")
	VALUES (montomoney, current_date, emisora, receptora, moneda);
exception when others then
	return 'imposible hacer la transferencia';
end;

begin
UPDATE public."CUENTA"
	SET "Saldo"=cambioemisora
	WHERE "NumCuenta"=emisora;
    
UPDATE public."CUENTA"
	SET "Saldo"=cambioreceptora
	WHERE "NumCuenta"=receptora;  
exception when others then
	return 'error';
end;
return 'ok';
end; 

$function$;

ALTER FUNCTION public.transferencia(integer, integer, numeric, character varying)
    OWNER TO postgres;
    
-- FUNCTION: public.pagoprestamoordinariocliente(integer, integer)

-- DROP FUNCTION public.pagoprestamoordinariocliente(integer, integer);

CREATE OR REPLACE FUNCTION public.pagoprestamoordinariocliente(
	cuenta integer,
	prestamo integer)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
fecha date;
cambioemisora money;
monto money;
plata money;
saldo money;
begin

if not exists (select * from "CUENTA" where "NumCuenta"=cuenta and "Estado"='A') then
	return 'no existe la cuenta';
end if;
if not exists (select * from "PRESTAMO" where "Numero"=prestamo and "Estado"='A') then
	return 'no existe el prestamo o ya fue cancelado';
end if;
if not((select "CedCliente" from "CUENTA" where "NumCuenta"=cuenta)=(select "CedCliente" from "PRESTAMO" where "Numero"=prestamo))then
	return 'el prestamo y la cuenta no son del mismo cliente';
end if;

begin
fecha= (select min("Fecha") from "PAGO" where "NumPrestamo"=prestamo and "Estado"='Pendiente')::date;
if (current_date-fecha)<0 then
	return 'no se puede pagar antes de la fecha indicada en el calendario';
end if;
monto=(select "Monto"+"MontoInteres" from "PAGO" where "NumPrestamo"=prestamo and "Fecha"=fecha)::money;
plata=cambiomoneda(monto,(select "Moneda" from "PRESTAMO" where "Numero"=prestamo),(select "Moneda" from "CUENTA" where "NumCuenta"=cuenta));
cambioemisora= (select "Saldo" from "CUENTA" where "NumCuenta"=cuenta)-plata;
if cambioemisora<0::money then
return 'no hay dinero suficiente en la cuenta';
end if;
saldo=(select "SaldoActual" from "PRESTAMO" where "Numero"=prestamo)-(select "Monto" from "PAGO" where "NumPrestamo"=prestamo and "Fecha"=fecha);    
UPDATE public."CUENTA"
	SET "Saldo"=cambioemisora
	WHERE "NumCuenta"=cuenta; 
    
if saldo<=0::money then
    UPDATE public."PRESTAMO"
        SET "Estado"='I'
        WHERE "Numero"=prestamo; 
end if;
UPDATE public."PRESTAMO"
        SET "SaldoActual"=saldo
        WHERE "Numero"=prestamo  ; 
UPDATE public."PAGO"
	SET "Estado"='Pagado'
	WHERE "NumPrestamo"=prestamo and "Fecha"=fecha ; 
exception when others then
	return 'error';

end;
return 'ok';
end; 

$function$;

ALTER FUNCTION public.pagoprestamoordinariocliente(integer, integer)
    OWNER TO postgres;    
    
    
    
-- FUNCTION: public.modificarcalendario(integer, date)

-- DROP FUNCTION public.modificarcalendario(integer, date);

CREATE OR REPLACE FUNCTION public.modificarcalendario(
	prestamo integer,
	fecha date)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
meses int;
FechaActual date;
saldo money;
cuota money;
inter numeric;
amort money;
MontoInteres money;
begin
FechaActual=fecha;
select "SaldoActual" into saldo from "PRESTAMO" where "Numero"=prestamo;
select "Interes" into inter from "PRESTAMO" where "Numero"=prestamo;
select "PagosRestantes" into meses from "PAGO" where "NumPrestamo"=prestamo and "Fecha"=fecha;
LOOP
 cuota=pmt(inter,meses-1,saldo::numeric);
MontoInteres=(saldo*inter/100)::money;
amort=cuota - MontoInteres;
saldo=saldo-amort;
FechaActual=FechaActual+ interval '1 month';
 begin
 	UPDATE public."PAGO"
        SET "Monto"=amort 
        WHERE "NumPrestamo"=prestamo and "Fecha"=FechaActual;
    meses=meses-1;
    
    EXIT WHEN Meses<=1;
     EXCEPTION when others then
    	return 'no se pudo crear el calendario';
 end;
END LOOP;
return 'ok';  

end; 

$function$;

ALTER FUNCTION public.modificarcalendario(integer, date)
    OWNER TO postgres;
    
    
-- FUNCTION: public.pagoprestamoextraordinariocliente(integer, integer, numeric)

-- DROP FUNCTION public.pagoprestamoextraordinariocliente(integer, integer, numeric);

CREATE OR REPLACE FUNCTION public.pagoprestamoextraordinariocliente(
	cuenta integer,
	prestamo integer,
	extra numeric)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
fecha date;
cambioemisora money;
monto money;
plata money;
saldo money;
begin
if extra<=0 then 
	return 'monto incorrecto para el pago';
end if;
if not exists (select * from "CUENTA" where "NumCuenta"=cuenta and "Estado"='A') then
	return 'no existe la cuenta';
end if;
if not exists (select * from "PRESTAMO" where "Numero"=prestamo and "Estado"='A') then
	return 'no existe el prestamo o ya fue cancelado';
end if;
if not((select "CedCliente" from "CUENTA" where "NumCuenta"=cuenta)=(select "CedCliente" from "PRESTAMO" where "Numero"=prestamo))then
	return 'el prestamo y la cuenta no son del mismo cliente';
end if;
if (not(select "Estado" from "CLIENTE" where "Cedula"=(select "CedCliente" from "PRESTAMO" where "Numero"=prestamo))='A') then
return 'Cliente no existe o está inactivo';
end if;
begin

if (select max("Fecha") from "PAGO" where "NumPrestamo"=prestamo and "Estado"='Pagado')is null then
	return 'primero debe cancelar alguna cuota antes de hacer un pago extraordinario';
end if;
fecha=(select max("Fecha") from "PAGO" where "NumPrestamo"=prestamo and "Estado"='Pagado')::date;
if ((select min("Fecha") from "PAGO" where "NumPrestamo"=prestamo and "Estado"='Pendiente') - current_date)<=0 then
	return 'no se puede hacer un pago extraordinario si se debe una cuota';
end if;
if (not(select "Extraordinario" from "PAGO" where "NumPrestamo"=prestamo and "Fecha"=fecha)=0::money) then
	return 'ya se hizo el pago extraordinario posible en este momento';
end if;
monto=extra::money;
plata=cambiomoneda(monto,(select "Moneda" from "PRESTAMO" where "Numero"=prestamo),(select "Moneda" from "CUENTA" where "NumCuenta"=cuenta));
cambioemisora= (select "Saldo" from "CUENTA" where "NumCuenta"=cuenta)-plata;
if cambioemisora<0::money then
return 'no hay dinero suficiente en la cuenta';
end if;
saldo=((select "SaldoActual" from "PRESTAMO" where "Numero"=prestamo)-monto);    
UPDATE public."CUENTA"
	SET "Saldo"=cambioemisora
	WHERE "NumCuenta"=cuenta; 
    
if saldo<=0::money then
    UPDATE public."PRESTAMO"
        SET "Estado"='I'
        WHERE "Numero"=prestamo; 
        
    UPDATE public."PAGO"
        SET "Estado"='Pagado'
        WHERE "NumPrestamo"=prestamo;     
        
end if;
UPDATE public."PRESTAMO"
        SET "SaldoActual"=saldo
        WHERE "Numero"=prestamo; 
UPDATE public."PAGO"
	SET "Extraordinario"=monto
	WHERE "NumPrestamo"=prestamo and "Fecha"=fecha ; 
    

exception when others then
	return 'error';

end;
return modificarcalendario(prestamo,fecha);
end; 

$function$;

ALTER FUNCTION public.pagoprestamoextraordinariocliente(integer, integer, numeric)
    OWNER TO postgres;
    
    
     
-- FUNCTION: public.pagotarjeta(integer, numeric)

-- DROP FUNCTION public.pagotarjeta(integer, numeric);

CREATE OR REPLACE FUNCTION public.pagotarjeta(
	tarjeta integer,
	pago numeric)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

declare
datosTarjeta "TARJETA"%ROWTYPE;
fecha date;
cambioemisora money;
monto money;
plata money;
saldo money;
begin
if monto<=0 then 
	return 'monto incorrecto para el pago';
end if;

select * into datosTarjeta from "TARJETA" where "Numero"=tarjeta and "Estado"='A';
if not found then
	return 'no existe la tarjeta indicada';
end if;
if (not(datosTarjeta."Tipo"='Credito')) then
	return 'tipo de tarjeta no permite pagos';
end if;
if (datosTarjeta."SaldoOrig"=datosTarjeta."SaldoActual") then
	return 'la tarjeta no tiene ninguna deuda';
end if;
if (not(select "Estado" from "CUENTA" where "NumCuenta"=(datosTarjeta."NumCuenta"))='A') then
return 'Cuenta está inactiva';
end if;
begin
fecha=current_date;
plata=pago::money;
cambioemisora= (select "Saldo" from "CUENTA" where "NumCuenta"=cuenta)-plata;
if cambioemisora<0::money then
return 'no hay dinero suficiente en la cuenta';
end if;
saldo=((datosTarjeta."SaldoActual")+plata);    
    
if saldo>= datosTarjeta."SaldoOrig" then
        
      UPDATE public."CUENTA"
        SET "Saldo"=(select "Saldo" from "CUENTA" where "NumCuenta"=cuenta)-(datosTarjeta."SaldoOrig"-datosTarjeta."SaldoActual")
        WHERE "Numero"=tarjeta;
    
    UPDATE public."TARJETA"
        SET "SaldoActual"="SaldoOrig"
        WHERE "Numero"=tarjeta; 
    
	INSERT INTO public."CANCELAR_TARJETA"(
	"Monto", "Fecha", "NumTarjeta")
	VALUES ((datosTarjeta."SaldoOrig"-datosTarjeta."SaldoActual"), fecha, tarjeta);         
else
UPDATE public."CUENTA"
	SET "Saldo"=cambioemisora
	WHERE "NumCuenta"=datosTarjeta."NumCuenta";     
UPDATE public."TARJETA"
        SET "SaldoActual"=saldo
        WHERE "Numero"=tarjeta; 

    
INSERT INTO public."CANCELAR_TARJETA"(
	"Monto", "Fecha", "NumTarjeta")
	VALUES (plata, fecha, tarjeta);    
end if;
    
exception when others then
	return 'error';

end;
return 'ok';
end; 

$function$;

ALTER FUNCTION public.pagotarjeta(integer, numeric)
    OWNER TO postgres;   
    
    

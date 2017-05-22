INSERT INTO public."CLIENTE"(
	"Nombre", "SegundoNombre", "PriApellido", "SegApellido", "Cedula", "Tipo", "Direccion", "Telefono ", "Ingreso",  "Contraseña", "Moneda")
	VALUES ('Ariel',H, 'Mata', 'Vega', '777777777', 'Fisico', 'Orotina', '24289446', 700000,'777','Colones);

INSERT INTO public."CLIENTE"(
	"Nombre", "SegundoNombre", "PriApellido", "SegApellido", "Cedula", "Tipo", "Direccion", "Telefono ", "Ingreso",  "Contraseña", "Moneda")    
VALUES ('Ariel', null, 'perez', 'Vega', '777777778', 'Fisico', 'Orotina', '24289446', 700000,'777','Colones')

INSERT INTO public."CLIENTE"(
	"Nombre", "SegundoNombre", "PriApellido", "SegApellido", "Cedula", "Tipo", "Direccion", "Telefono ", "Ingreso",  "Contraseña", "Moneda")    
VALUES ('L3M', null, null, null, '111111111', 'Juridico', 'Cartago', '60289446', 6000,'777','Dolares')

INSERT INTO public."ROL"(
	"Nombre", "Descripcion")
	VALUES ('Gerente', 'administra el banco');
    
INSERT INTO public."ROL"(
	"Nombre", "Descripcion")
	VALUES ('Servicio al cliente', 'recibe a los clientes');

INSERT INTO public."ASESOR"(
	"Cedula", "FechaNac", "Nombre", "SegNombre", "PriApellido", "SegApellido", "MetaColones", "MetaDolares")
	VALUES (000000000, '12-12-1980', 'pedro', null, 'salas', 'campos', 1000000, 2000);

INSERT INTO public."ASESOR"(
	"Cedula", "FechaNac", "Nombre", "SegNombre", "PriApellido", "SegApellido", "MetaColones", "MetaDolares")
	VALUES ('123456789', '11-09-1990', 'Juan', 'Andres', 'Soto', 'Solis',  100000, 2000);
    
INSERT INTO public."PRESTAMO"(
	"Interes", "SaldoOrig", "SaldoActual", "CedCliente", "CedAsesor",  "Moneda")
	VALUES (2, 1000, 1000, 777777777, 000000000,  'Colones');
    
INSERT INTO public."PRESTAMO"(
	"Interes", "SaldoOrig", "SaldoActual", "CedCliente", "CedAsesor","Moneda")
	VALUES (1.95, 10000, 10000, 777777777, 000000000, 'Dolares');
    
INSERT INTO public."PRESTAMO"(
	"Interes", "SaldoOrig", "SaldoActual", "CedCliente", "CedAsesor","Moneda")
	VALUES (1.95, 200000, 200000, 111111111, 000000000, 'Colones');
    
INSERT INTO public."PRESTAMO"(
	"Interes", "SaldoOrig", "SaldoActual", "CedCliente", "CedAsesor", "Moneda")
	VALUES (3, 300000, 300000, '111111111', '123456789', 'Colones');
    
select calendariopagos(4,3);
select calendariopagos(2,24);
select calendariopagos(3,12);
select calendariopagos(5,12);

 INSERT INTO public."CUENTA"(
	"Tipo", "Moneda", "Descripcion", "CedCliente","Saldo")
	VALUES ('Corriente', 'Colones', 'cuenta corriente', '777777777',1000000);
    
INSERT INTO public."CUENTA"(
	"Tipo", "Moneda", "Descripcion", "CedCliente","Saldo")
	VALUES ('Ahorros', 'Colones', 'cuenta ahorros', '777777777',1000000);
    
select transferencia(3,4,500000,'Colones');

INSERT INTO public."CLIENTE"(
	"Nombre", "SegundoNombre", "PriApellido", "SegApellido", "Cedula", "Tipo", "Direccion", "Telefono ", "Ingreso", "Estado")
	VALUES ('Ariel', null, 'Mata', 'Vega', '777777777', 'F�sico', 'Orotina', '24289446', 700000, 'A');

INSERT INTO public."CUENTA"(
	"Tipo", "Moneda", "Descripcion", "CedCliente", "Estado", "NumCuenta")
	VALUES ('Corriente', 'Colones', 'cuenta corriente', '777777777', 'A');
    
INSERT INTO public."CUENTA"(
	"Tipo", "Moneda", "Descripcion", "CedCliente")
	VALUES ('Ahorros', 'Colones', 'cuenta de ahorros','777777777');
    
INSERT INTO public."TARJETA"(
	"CodigoSeg", "FechaExp", "Saldo", "Tipo", "NumCuenta", "Estado")
	VALUES ('7777', '12-12-2012', 10000, 'D�bito', 1, 'A');
    
INSERT INTO public."ASESOR"(
	"Cedula", "FechaNac", "Nombre", "SegNombre", "PriApellido", "SegApellido", "Estado")
	VALUES ('111111111', '01-01-1980', 'Pedro', null, 'Perez', 'Vega', 'A');
    
INSERT INTO public."ASESOR"(
	"Cedula", "FechaNac", "Nombre", "SegNombre", "PriApellido", "SegApellido", "Estado")
	VALUES ('111111112', '01-01-1980', 'Carlos', 'Alberto', 'Perez', 'Vega', 'I');
    
INSERT INTO public."PRESTAMO"(
	"Interes", "SaldoOrig", "SaldoActual", "CedCliente", "CedAsesor", "Estado")
	VALUES (2.1, 1000000, 1000, '777777777', '111111111', 'A');
    
INSERT INTO public."PAGO"(
	"Monto", "NumPrestamo", "Fecha", "Tipo", "CedCliente")
	VALUES (999000, 1, '07-05-2017', 'Ordinario', '777777777');

INSERT INTO public."ROL"(
	"Nombre", "Descripcion")
	VALUES ('Gerente', 'administra el banco');
    
INSERT INTO public."ROL"(
	"Nombre", "Descripcion")
	VALUES ('Servicio al cliente', 'recibe a los clientes');
    
INSERT INTO public."TRANSFERENCIA"(
	"Monto", "Fecha", "CuentaEmisora", "CuentaReceptora")
	VALUES (70000, '09-05-2017' , 1, 2);
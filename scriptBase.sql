

-- funciones hechas:
-- ingresarusuario y modificarusuario
-- pmt y calendario pagos 
-- reporte de mora con numero de cuotas
-- reporte de mora por fechas
-- reporte comisiones para asesores
-- transferencia 
-- cambiomoneda






-- Database: BancaTec

-- DROP DATABASE "BancaTec";

CREATE DATABASE "BancaTec"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE "BancaTec"
    IS 'base de datos proyecto 2';

-- Table: public."ASESOR"

-- DROP TABLE public."ASESOR";

CREATE TABLE public."ASESOR"
(
    "Cedula" character(9) COLLATE pg_catalog."default" NOT NULL,
    "FechaNac" date NOT NULL,
    "Nombre" character varying(15) COLLATE pg_catalog."default" NOT NULL,
    "SegNombre" character varying(15) COLLATE pg_catalog."default",
    "PriApellido" character varying(15) COLLATE pg_catalog."default" NOT NULL,
    "SegApellido" character varying(15) COLLATE pg_catalog."default" NOT NULL,
    "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    "MetaColones" money NOT NULL,
    "MetaDolares" money NOT NULL,
    CONSTRAINT "ASESOR_pkey" PRIMARY KEY ("Cedula"),
    CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."ASESOR"
    OWNER to postgres;
    
    
-- Table: public."CLIENTE"

-- DROP TABLE public."CLIENTE";

CREATE TABLE public."CLIENTE"
(
    "Nombre" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "SegundoNombre" character varying(20) COLLATE pg_catalog."default",
    "PriApellido" character varying(20) COLLATE pg_catalog."default",
    "SegApellido" character varying(20) COLLATE pg_catalog."default",
    "Cedula" character(9) COLLATE pg_catalog."default" NOT NULL,
    "Tipo" character varying(8) COLLATE pg_catalog."default" NOT NULL,
    "Direccion" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "Telefono " character(8) COLLATE pg_catalog."default" NOT NULL,
    "Ingreso" money NOT NULL,
    "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    "Contrasena" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "Moneda" character varying(7) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Colones'::character varying,
    CONSTRAINT cliente_pkey PRIMARY KEY ("Cedula"),
    CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID,
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Fisico'::text OR "Tipo"::text = 'Juridico'::text) NOT VALID,
    CONSTRAINT "IngresoConstraint" CHECK ("Ingreso" >= 0::money) NOT VALID,
    CONSTRAINT "MonedaConstraint" CHECK ("Moneda"::text = 'Colones'::text OR "Moneda"::text = 'Dolares'::text OR "Moneda"::text = 'Euros'::text) NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."CLIENTE"
    OWNER to postgres;
    
-- Table: public."CUENTA"

-- DROP TABLE public."CUENTA";

CREATE TABLE public."CUENTA"
(
    "Tipo" character varying(9) COLLATE pg_catalog."default" NOT NULL,
    "Moneda" character varying(7) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Colones'::character varying,
    "Descripcion" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "CedCliente" character varying(9) COLLATE pg_catalog."default",
    "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    "NumCuenta" SERIAL,
    "Saldo" money NOT NULL DEFAULT 0,
    CONSTRAINT "CUENTA_pkey" PRIMARY KEY ("NumCuenta"),
    CONSTRAINT "Cliente" FOREIGN KEY ("CedCliente")
        REFERENCES public."CLIENTE" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "SaldoConstraint" CHECK ("Saldo" >= 0::money) NOT VALID,
    CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID,
    CONSTRAINT "MonedaConstraint" CHECK ("Moneda"::text = 'Euros'::text OR "Moneda"::text = 'Colones'::text OR "Moneda"::text = 'Dolares'::text) NOT VALID,
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Ahorros'::text OR "Tipo"::text = 'Corriente'::text)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."CUENTA"
    OWNER to postgres;

    
-- Table: public."PRESTAMO"

-- DROP TABLE public."PRESTAMO";

CREATE TABLE public."PRESTAMO"
(
    "Interes" double precision NOT NULL,
    "SaldoOrig" money NOT NULL,
    "SaldoActual" money NOT NULL,
    "CedCliente" character(9) COLLATE pg_catalog."default" NOT NULL,
    "CedAsesor" character(9) COLLATE pg_catalog."default" NOT NULL,
    "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    "Numero" SERIAL,
    "Moneda" character varying(7) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Colones'::character varying,
    CONSTRAINT "PRESTAMO_pkey" PRIMARY KEY ("Numero"),
    CONSTRAINT "AsesorReference" FOREIGN KEY ("CedAsesor")
        REFERENCES public."ASESOR" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "ClienteReference" FOREIGN KEY ("CedCliente")
        REFERENCES public."CLIENTE" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "SaldoConstraint" CHECK ("SaldoOrig" >= 0::money AND "SaldoActual" <= "SaldoOrig" AND "SaldoActual" >= 0::money) NOT VALID,
    CONSTRAINT "MonedaConstraint" CHECK ("Moneda"::text = 'Colones'::text OR "Moneda"::text = 'Dolares'::text OR "Moneda"::text = 'Euros'::text) NOT VALID
    CONSTRAINT "PRESTAMO_Interes_check" CHECK ("Interes" >= 0::double precision) NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."PRESTAMO"
    OWNER to postgres;
    
-- Table: public."PAGO"

-- DROP TABLE public."PAGO";

CREATE TABLE public."PAGO"
(
    "Monto" money NOT NULL,
    "NumPrestamo" integer NOT NULL,
    "Fecha" date NOT NULL,
    "CedCliente" character(9) COLLATE pg_catalog."default" NOT NULL,
    "MontoInteres" money NOT NULL DEFAULT 0,
    "Estado" character varying(9) COLLATE pg_catalog."default" NOT NULL,
    "PagosRestantes" integer NOT NULL DEFAULT 12,
    "Extraordinario" money NOT NULL DEFAULT 0,
    CONSTRAINT "PAGO_pkey" PRIMARY KEY ("NumPrestamo", "Fecha"),
    CONSTRAINT "ClienteReference" FOREIGN KEY ("CedCliente")
        REFERENCES public."CLIENTE" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "PrestamoReference" FOREIGN KEY ("NumPrestamo")
        REFERENCES public."PRESTAMO" ("Numero") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "EstadoConstraint" CHECK ("Estado"::text = 'Pagado'::text OR "Estado"::text = 'Pendiente'::text) NOT VALID,
    CONSTRAINT "MontoConstraint" CHECK ("Monto" > 0::money) NOT VALID,
    CONSTRAINT "InteresConstraint" CHECK ("MontoInteres" >= 0::money) NOT VALID,
    CONSTRAINT "PagosConstraint" CHECK ("PagosRestantes" >= 1) NOT VALID,
    CONSTRAINT "ExtraordinarioConstraint" CHECK ("Extraordinario" >= 0::money) NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."PAGO"
    OWNER to postgres;
    
-- Table: public."ROL"

-- DROP TABLE public."ROL";

CREATE TABLE public."ROL"
(
    "Nombre" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "Descripcion" character varying(100) COLLATE pg_catalog."default" NOT NULL,
	"Estado" "char" NOT NULL DEFAULT 'A'::"char",
	CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID,
    CONSTRAINT "ROL_pkey" PRIMARY KEY ("Nombre")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."ROL"
    OWNER to postgres;
    
-- Table: public."TARJETA"

-- DROP TABLE public."TARJETA";

CREATE TABLE public."TARJETA"
(
    "CodigoSeg" character(3) COLLATE pg_catalog."default" NOT NULL,
    "FechaExp" date NOT NULL,
    "Saldo" money DEFAULT 0,
    "Tipo" character varying(7) COLLATE pg_catalog."default" NOT NULL,
    "NumCuenta" integer NOT NULL,
    "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    "Numero" SERIAL,
    CONSTRAINT "TARJETA_pkey" PRIMARY KEY ("Numero"),
    CONSTRAINT "CuentaReference" FOREIGN KEY ("NumCuenta")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "SaldoConstraint" CHECK ("Saldo" >= 0::money) NOT VALID,
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Credito'::text OR "Tipo"::text = 'Debito'::text) NOT VALID,
    CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."TARJETA"
    OWNER to postgres;
    
-- Table: public."MOVIMIENTO"

-- DROP TABLE public."MOVIMIENTO";

CREATE TABLE public."MOVIMIENTO"
(
    "Tipo" character varying(8) COLLATE pg_catalog."default" NOT NULL,
    "Fecha" date NOT NULL,
    "Monto" money NOT NULL,
    "NumCuenta" integer NOT NULL,
    "Moneda" character varying(7) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Colones'::character varying,
	"ID" SERIAL PRIMARY KEY,
	"Estado" "char" NOT NULL DEFAULT 'A'::"char",
    CONSTRAINT "CuentaReference" FOREIGN KEY ("NumCuenta")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
	CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID,
    CONSTRAINT "MonedaConstraint" CHECK ("Moneda"::text = 'Colones'::text OR "Moneda"::text = 'Dolares'::text OR "Moneda"::text = 'Euros'::text) NOT VALID,
    CONSTRAINT "MontoConstraint" CHECK ("Monto" > 0::money) NOT VALID,
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Deposito'::text OR "Tipo"::text = 'Retiro'::text) NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."MOVIMIENTO"
    OWNER to postgres;
    
    
-- Table: public."TRANSFERENCIA"

-- DROP TABLE public."TRANSFERENCIA";

CREATE TABLE public."TRANSFERENCIA"
(
    "Monto" money NOT NULL,
    "Fecha" date NOT NULL,
    "CuentaEmisora" integer NOT NULL,
    "CuentaReceptora" integer NOT NULL,
    "Moneda" character varying(7) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Colones'::character varying,
	"ID" SERIAL PRIMARY KEY,
	"Estado" "char" NOT NULL DEFAULT 'A'::"char",
    CONSTRAINT "EmisorReference" FOREIGN KEY ("CuentaEmisora")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "ReceptorReference" FOREIGN KEY ("CuentaReceptora")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
	CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID,
    CONSTRAINT "CuentasConstraint" CHECK ("CuentaEmisora" <> "CuentaReceptora"),
    CONSTRAINT "MonedaConstraint" CHECK ("Moneda"::text = 'Colones'::text OR "Moneda"::text = 'Dolares'::text OR "Moneda"::text = 'Euros'::text) NOT VALID,
    CONSTRAINT "MontoConstraint" CHECK ("Monto" > 0::money) NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."TRANSFERENCIA"
    OWNER to postgres;
    
-- Table: public."EMPLEADO"

-- DROP TABLE public."EMPLEADO";

CREATE TABLE public."EMPLEADO"
(
    "Cedula" character(9) COLLATE pg_catalog."default" NOT NULL,
    "Sucursal" character varying(20) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Cartago'::character varying,
    "Nombre" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "SegNombre" character varying(20) COLLATE pg_catalog."default",
    "PriApellido" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "SegApellido" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "Contrasena" character varying(20) COLLATE pg_catalog."default" NOT NULL,
	"Estado" "char" NOT NULL DEFAULT 'A'::"char",
    CONSTRAINT "EMPLEADO_X_pkey" PRIMARY KEY ("Cedula")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."EMPLEADO"
    OWNER to postgres;
    
    
-- Table: public."COMPRA"

-- DROP TABLE public."COMPRA";

CREATE TABLE public."COMPRA"
(
    "NumTarjeta" integer NOT NULL,
    "Comercio" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "Monto" money NOT NULL,
    "Moneda" character varying(7) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Colones'::character varying,
	"ID" SERIAL PRIMARY KEY,
	"Estado" "char" NOT NULL DEFAULT 'A'::"char",
    CONSTRAINT "TarjetaConstraint" FOREIGN KEY ("NumTarjeta")
        REFERENCES public."TARJETA" ("Numero") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."COMPRA"
    OWNER to postgres;
 
 
-- Table: public."CANCELAR_TARJETA"

-- DROP TABLE public."CANCELAR_TARJETA";

CREATE TABLE public."CANCELAR_TARJETA"
(
    "Monto" money NOT NULL,
    "Fecha" date NOT NULL,
    "NumTarjeta" integer NOT NULL,
	"ID" SERIAL PRIMARY KEY,
	"Estado" "char" NOT NULL DEFAULT 'A'::"char",
    CONSTRAINT "TarjetaConstraint" FOREIGN KEY ("NumTarjeta")
        REFERENCES public."TARJETA" ("Numero") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "MontoConstraint" CHECK ("Monto" > 0::money) NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."CANCELAR_TARJETA"
    OWNER to postgres;
    

-- Table: public."EMPLEADO_ROL"

-- DROP TABLE public."EMPLEADO_ROL";

CREATE TABLE public."EMPLEADO_ROL"
(
    "CedulaEmpledo" character(9) COLLATE pg_catalog."default" NOT NULL,
    "NombreRol" character varying(50) COLLATE pg_catalog."default" NOT NULL,
	"ID" SERIAL PRIMARY KEY,
	"Estado" "char" NOT NULL DEFAULT 'A'::"char",
    CONSTRAINT "EmpleadoReference" FOREIGN KEY ("CedulaEmpledo")
        REFERENCES public."EMPLEADO" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "RolReference" FOREIGN KEY ("NombreRol")
        REFERENCES public."ROL" ("Nombre") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."EMPLEADO_ROL"
    OWNER to postgres;

-- Database: BancaTec

-- DROP DATABASE "BancaTec";

CREATE DATABASE "BancaTec"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Mexico.1252'
    LC_CTYPE = 'Spanish_Mexico.1252'
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
    "Ingreso" integer NOT NULL,
   "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    CONSTRAINT cliente_pkey PRIMARY KEY ("Cedula"),
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'F�sico'::text OR "Tipo"::text = 'Jur�dico'::text) NOT VALID,
    CONSTRAINT "IngresoConstraint" CHECK ("Ingreso" >= 0) NOT VALID,
    CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID
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
    "NumCuenta" integer NOT NULL DEFAULT nextval('"CUENTA_NumCuenta_seq"'::regclass),
    CONSTRAINT "CUENTA_pkey" PRIMARY KEY ("NumCuenta"),
    CONSTRAINT "Cliente" FOREIGN KEY ("CedCliente")
        REFERENCES public."CLIENTE" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Ahorros'::text OR "Tipo"::text = 'Corriente'::text),
    CONSTRAINT "MonedaConstraint" CHECK ("Moneda"::text = 'Euros'::text OR "Moneda"::text = 'Colones'::text OR "Moneda"::text = 'Dolares'::text) NOT VALID,
    CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."CUENTA"
    OWNER to postgres;
  -- Table: public."PAGO"

-- DROP TABLE public."PAGO";

CREATE TABLE public."PAGO"
(
    "Monto" bigint NOT NULL,
    "NumPrestamo" integer NOT NULL,
    "Fecha" date NOT NULL,
    "Tipo" character varying(14) COLLATE pg_catalog."default" NOT NULL,
    "CedCliente" character(9) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "PAGO_pkey" PRIMARY KEY ("NumPrestamo"),
    CONSTRAINT "ClienteReference" FOREIGN KEY ("CedCliente")
        REFERENCES public."CLIENTE" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "PrestamoReference" FOREIGN KEY ("NumPrestamo")
        REFERENCES public."PRESTAMO" ("Numero") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "MontoConstraint" CHECK ("Monto" > 0),
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Ordinario'::text OR "Tipo"::text = 'Extraordinario'::text)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."PAGO"
    OWNER to postgres;
    
   -- Table: public."PRESTAMO"

-- DROP TABLE public."PRESTAMO";

CREATE TABLE public."PRESTAMO"
(
    "Interes" double precision NOT NULL,
    "SaldoOrig" bigint NOT NULL,
    "SaldoActual" bigint NOT NULL,
    "CedCliente" character(9) COLLATE pg_catalog."default" NOT NULL,
    "CedAsesor" character(9) COLLATE pg_catalog."default" NOT NULL,
    "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    "Numero" integer NOT NULL DEFAULT nextval('"PRESTAMO_Numero_seq"'::regclass),
    CONSTRAINT "PRESTAMO_pkey" PRIMARY KEY ("Numero"),
    CONSTRAINT "AsesorReference" FOREIGN KEY ("CedAsesor")
        REFERENCES public."ASESOR" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "ClienteReference" FOREIGN KEY ("CedCliente")
        REFERENCES public."CLIENTE" ("Cedula") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "SaldoOConstraint" CHECK ("SaldoOrig" > 0 AND "SaldoActual" <= "SaldoActual")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."PRESTAMO"
    OWNER to postgres;
    
    -- Table: public."ROL"

-- DROP TABLE public."ROL";

CREATE TABLE public."ROL"
(
    "Nombre" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "Descripcion" character varying(100) COLLATE pg_catalog."default" NOT NULL,
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
    "CodigoSeg" character(4) COLLATE pg_catalog."default" NOT NULL,
    "FechaExp" date NOT NULL,
    "Saldo" bigint NOT NULL,
    "Tipo" character varying(7) COLLATE pg_catalog."default" NOT NULL,
    "NumCuenta" integer NOT NULL,
    "Estado" "char" NOT NULL DEFAULT 'A'::"char",
    "Numero" integer NOT NULL DEFAULT nextval('"TARJETA_Numero_seq"'::regclass),
    CONSTRAINT "TARJETA_pkey" PRIMARY KEY ("Numero"),
    CONSTRAINT "CuentaReference" FOREIGN KEY ("NumCuenta")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "EstadoConstraint" CHECK ("Estado" = 'A'::"char" OR "Estado" = 'I'::"char") NOT VALID,
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Cr�dito'::text OR "Tipo"::text = 'D�bito'::text) NOT VALID
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
    CONSTRAINT "CuentaReference" FOREIGN KEY ("NumCuenta")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "TipoConstraint" CHECK ("Tipo"::text = 'Depósito'::text OR "Tipo"::text = 'Retiro'::text)
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
    CONSTRAINT "EmisorReference" FOREIGN KEY ("CuentaEmisora")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "ReceptorReference" FOREIGN KEY ("CuentaReceptora")
        REFERENCES public."CUENTA" ("NumCuenta") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "CuentasConstraint" CHECK ("CuentaEmisora" <> "CuentaReceptora")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."TRANSFERENCIA"
    OWNER to postgres;
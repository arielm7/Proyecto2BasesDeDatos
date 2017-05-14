CREATE OR REPLACE FUNCTION ingresarCliente(
	 Nombre character varying(20),
    SegundoNombre character varying(20),
    PriApellido character varying(20),
    SegApellido character varying(20),
    Cedula character(9),
    Tipo character varying(8) ,
    Direccion character varying(100),
    Telefono  character(8),
    Ingreso integer ,
    Contrasena character varying(20) ,
    Moneda character varying(7) )
    RETURNS character varying(20) AS $$
declare
error text; 

begin
IF not((Tipo='Fisico') or (Tipo ='Juridico')) then   
	return 'El tipo de cliente debe ser Fisico o Juridico';
ELSIF (Tipo = 'Fisico' and PriApellido is not null and SegApellido is not null)or
(Tipo='Juridico' and SegundoNombre is null and PriApellido is null and SegApellido is null )  THEN
    BEGIN
    INSERT INTO public."CLIENTE"(
        "Nombre", "SegundoNombre", "PriApellido", "SegApellido", "Cedula", "Tipo", "Direccion", "Telefono ", "Ingreso","Contrasena", "Moneda")
        VALUES (Nombre, SegundoNombre, PriApellido,SegApellido, Cedula, Tipo,Direccion, Telefono, Ingreso, Contrasena, Moneda);
        return 'ok';
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
end; $$ language plpgsql;
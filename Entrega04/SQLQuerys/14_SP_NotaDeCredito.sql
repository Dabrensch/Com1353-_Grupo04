---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Generar nota de credito para la devolucion de un producto

---------------------------------------------------------------------
USE Com1353G04
GO

---------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Venta.GenerarNotaDeCredito
	@idDetalleVenta INT,
	@cantidad INT,
	@motivo VARCHAR(150),
	@cambioProducto BIT
AS
BEGIN
	IF IS_MEMBER('Supervisor') = 0
    BEGIN
		RAISERROR ('No tiene permisos para generar una nota de crédito.', 16, 1);
		RETURN;
    END

    DECLARE @error VARCHAR(MAX) = '';

	-- Validaciones
	IF NOT EXISTS (SELECT 1 FROM Venta.DetalleVenta WHERE idDetalleVenta = @idDetalleVenta)
		SET @error = @error + 'No existe un detalle de venta con el ID especificado. ';
	ELSE
	BEGIN
		DECLARE @estadoFactura CHAR;
		SELECT @estadoFactura = v.estado
		FROM Venta.Venta v 
		JOIN Venta.DetalleVenta dv ON v.idVenta = dv.idVenta
		WHERE dv.idDetalleVenta = @idDetalleVenta;

		IF @estadoFactura <> 'P'
			SET @error = @error + 'No se puede generar una nota de crédito porque la factura no está pagada.'
	END

	IF LTRIM(RTRIM(@motivo)) = ''
        SET @error = @error + 'El motivo no puede estar vacío. ';

	IF @cantidad <= 0
        SET @error = @error + 'La cantidad debe ser mayor a 0. ';
	
	-- Informar errores si los hubo 
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
		-- Obtener la cantidad vendida, el monto y el idProducto en la venta original
		DECLARE @cantidadVendida INT, @precioUnitario DECIMAL(10,2), @idProducto INT;
		SELECT @cantidadVendida = cantidad, @precioUnitario = precioUnitarioAlMomentoDeLaVenta, @idProducto = idProducto
		FROM Venta.DetalleVenta WHERE idDetalleVenta = @idDetalleVenta;

		-- Comprobar si la cantidad a devolver supera la cantidad vendida
		IF @cantidad > @cantidadVendida
		BEGIN
			RAISERROR ('La cantidad a devolver supera la cantidad vendida.', 16, 1);
			RETURN;
		END

		-- Obtener la suma de las cantidades de notas de crédito ya generadas para este detalle de venta
		DECLARE @cantidadNotasCredito INT = 0;
		SELECT @cantidadNotasCredito = COALESCE(SUM(cantidad), 0)
		FROM Venta.NotaDeCredito 
		WHERE idDetalleVenta = @idDetalleVenta;

		-- Comprobar si ya hay notas de crédito para este detalle que haga que supere la cantidad vendida
		IF @cantidad + @cantidadNotasCredito > @cantidadVendida
		BEGIN
			RAISERROR ('La cantidad a devolver junto con notas de crédito previas supera la cantidad vendida.', 16, 1);
			RETURN;
		END

		DECLARE @comprobante CHAR(8) = CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS CHAR(8))

		-- Insertar nota de credito
		IF @cambioProducto = 0
		BEGIN
			INSERT INTO Venta.NotaDeCredito(idDetalleVenta, comprobante, motivo, fecha, hora, monto, cantidad)
			VALUES (@idDetalleVenta, @comprobante, @motivo, CAST(GETDATE() AS DATE), CAST(GETDATE() AS TIME), @precioUnitario * @cantidad, @cantidad)
		END
		ELSE
		BEGIN
			INSERT INTO Venta.NotaDeCredito(idDetalleVenta, comprobante, motivo, fecha, hora, idProductoCambio, cantidad)
			VALUES (@idDetalleVenta, @comprobante, @motivo, CAST(GETDATE() AS DATE), CAST(GETDATE() AS TIME), @idProducto, @cantidad)
		END
	END
END
GO


---------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Sistema.CrearRoles
AS
BEGIN
	-- Crear roles
	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor' AND type = 'R')
	BEGIN
		CREATE ROLE Supervisor;
	END

	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Empleado' AND type = 'R')
	BEGIN
		CREATE ROLE Empleado;
	END

	-- Crear login
	IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_supervisor')
	BEGIN
		CREATE LOGIN usuario_supervisor WITH PASSWORD = 'contraseñaSupervisor';
	END

	IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_empleado')
	BEGIN
		CREATE LOGIN usuario_empleado WITH PASSWORD = 'contraseñaEmpleado';
	END

	-- Crear usuarios
	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuario_supervisor')
	BEGIN
		CREATE USER usuario_supervisor FOR LOGIN usuario_supervisor;
	END

	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuario_empleado')
	BEGIN
		CREATE USER usuario_empleado FOR LOGIN usuario_empleado;
	END

	-- Asignar roles
	IF NOT EXISTS (SELECT * FROM sys.database_role_members WHERE role_principal_id = USER_ID('Supervisor') AND member_principal_id = USER_ID('usuario_supervisor'))
	BEGIN
		ALTER ROLE Supervisor ADD MEMBER usuario_supervisor;
	END

	IF NOT EXISTS (SELECT * FROM sys.database_role_members WHERE role_principal_id = USER_ID('Empleado') AND member_principal_id = USER_ID('usuario_empleado'))
	BEGIN
		ALTER ROLE Empleado ADD MEMBER usuario_empleado;
	END

	-- Asignar permisos al supervisor
	IF NOT EXISTS (SELECT * FROM sys.database_permissions 
				   WHERE grantee_principal_id = USER_ID('Supervisor') 
				   AND major_id = OBJECT_ID('Venta.NotaDeCredito') 
				   AND permission_name = 'INSERT')
	BEGIN
		GRANT INSERT ON Venta.NotaDeCredito TO Supervisor;
	END

	IF NOT EXISTS (SELECT * FROM sys.database_permissions 
				   WHERE grantee_principal_id = USER_ID('Supervisor') 
				   AND major_id = OBJECT_ID('Venta.NotaDeCredito') 
				   AND permission_name = 'SELECT')
	BEGIN
		GRANT SELECT ON Venta.NotaDeCredito TO Supervisor;
	END

	IF NOT EXISTS (SELECT * FROM sys.database_permissions 
                   WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('Supervisor') 
                   AND major_id = OBJECT_ID('Venta.DetalleVenta') 
                   AND permission_name = 'SELECT')
    BEGIN
        GRANT SELECT ON Venta.DetalleVenta TO Supervisor;
    END

    IF NOT EXISTS (SELECT * FROM sys.database_permissions 
                   WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('Supervisor') 
                   AND major_id = OBJECT_ID('Venta.Venta') 
                   AND permission_name = 'SELECT')
    BEGIN
        GRANT SELECT ON Venta.Venta TO Supervisor;
    END

    IF NOT EXISTS (SELECT * FROM sys.database_permissions 
                   WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('Supervisor') 
                   AND major_id = OBJECT_ID('Venta.GenerarNotaDeCredito') 
                   AND permission_name = 'EXECUTE')
    BEGIN
        GRANT EXECUTE ON Venta.GenerarNotaDeCredito TO Supervisor;
    END


	-- Denegar permisos al empleado
	IF NOT EXISTS (SELECT * FROM sys.database_permissions 
				   WHERE grantee_principal_id = USER_ID('Empleado') 
				   AND major_id = OBJECT_ID('Venta.NotaDeCredito') 
				   AND permission_name = 'INSERT')
	BEGIN
		DENY INSERT ON Venta.NotaDeCredito TO Empleado;
	END

	IF NOT EXISTS (SELECT * FROM sys.database_permissions 
                   WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('Empleado') 
                   AND major_id = OBJECT_ID('Venta.GenerarNotaDeCredito') 
                   AND permission_name = 'EXECUTE')
    BEGIN
        DENY EXECUTE ON Venta.GenerarNotaDeCredito TO Empleado;
    END
END;


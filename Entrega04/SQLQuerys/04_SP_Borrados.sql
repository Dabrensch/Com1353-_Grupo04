---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Genere store procedures para manejar los borrados logicos y la reactivación

-- Borrados logicos
-- Los borrados logicos se realizan actualizando el campo de estado en las tablas que permiten este tipo de operación,
-- manteniendo el registro para futuros informes. 
-- Además, cuando el borrado afecta a varias tablas, se aplica un borrado lógico en cascada, 
-- utilizando transacciones para asegurar que todos los cambios se realicen de manera coherente y controlada. 

-- Reactivación
-- La reactivación consiste en actualizar el campo de estado en las tablas que contienen registros previamente desactivados.
-- Antes de activar un registro, se verifica si los registros asociados están activos.
-- Si los registros asociados no están activos, el proceso de reactivación no se lleva a cabo y se solicita que se active primero lo relacionado.

---------------------------------------------------------------------
USE Com1353G04
GO

------------------------- BORRADOS LOGICOS --------------------------  

---------------------------------------------------------------------
-- PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.BorrarProducto (@idProducto INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Producto.Producto WHERE idProducto = @idProducto)
	BEGIN
		RAISERROR('No existe un producto con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Inactivar producto
    UPDATE Producto.Producto
    SET estado = 0
    WHERE idProducto = @idProducto;
END
GO


---------------------------------------------------------------------
-- CATEGORIA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.BorrarCategoriaProducto (@idCategoriaProducto INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE idCategoriaProducto = @idCategoriaProducto)
	BEGIN
		RAISERROR('No existe una categoria de producto con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Iniciar transaccion, ya que se van a modificar varias tablas
    BEGIN TRANSACTION;
    BEGIN TRY
		-- Inactivar los productos asociados
		UPDATE Producto.Producto
        SET estado = 0
        WHERE idCategoriaProducto = @idCategoriaProducto;

        -- Inactivar la categoria de producto
        UPDATE Producto.CategoriaProducto
        SET estado = 0
        WHERE idCategoriaProducto = @idCategoriaProducto;

        COMMIT;
    END TRY
    BEGIN CATCH
		ROLLBACK;
		PRINT 'Se produjo un error, no se pudo realizar el borrado.';
		THROW;
	END CATCH
END
GO


---------------------------------------------------------------------
-- LINEA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.BorrarLineaProducto (@idLineaProducto INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Producto.LineaProducto WHERE idLineaProducto = @idLineaProducto)
	BEGIN
		RAISERROR('No existe una linea de producto con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Iniciar transaccion, ya que se van a modificar varias tablas
    BEGIN TRY
        -- Inactivar los productos asociados a las categorías de esta línea de producto
		UPDATE Producto.Producto
        SET estado = 0
        WHERE idCategoriaProducto IN (
            SELECT idCategoriaProducto FROM Producto.CategoriaProducto WHERE idLineaProducto = @idLineaProducto
        );

		-- Inactivar las categorías asociadas a esta línea de producto
        UPDATE Producto.CategoriaProducto
        SET estado = 0
        WHERE idLineaProducto = @idLineaProducto;

        -- Inactivar la linea de producto
        UPDATE Producto.LineaProducto
        SET estado = 0
        WHERE idLineaProducto = @idLineaProducto;

    END TRY
    BEGIN CATCH
		ROLLBACK;
		PRINT 'Se produjo un error, no se pudo realizar el borrado.';
		THROW;
	END CATCH
END
GO


---------------------------------------------------------------------
-- EMPLEADO --

CREATE OR ALTER PROCEDURE Empleado.BorrarEmpleado (@legajoEmpleado INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Empleado.Empleado WHERE legajoEmpleado = @legajoEmpleado)
	BEGIN
		RAISERROR('No existe un empleado con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Abrir la llave simétrica
	OPEN SYMMETRIC KEY EmpleadoLlave
		DECRYPTION BY CERTIFICATE CertificadoEmpleado;

	-- Inactivar empleado
    UPDATE Empleado.Empleado
    SET fechaBaja = ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, CONVERT(VARCHAR(10), GETDATE(), 120)))
    WHERE legajoEmpleado = @legajoEmpleado;

	-- Cerrar la llave simétrica
	CLOSE SYMMETRIC KEY EmpleadoLlave;
END
GO


---------------------------------------------------------------------
-- SUCURSAL --

CREATE OR ALTER PROCEDURE Sucursal.BorrarSucursal 
	@idSucursal INT,
	@idSucursalNueva INT = NULL
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE idSucursal = @idSucursal)
	BEGIN
		RAISERROR('No existe una sucursal con el ID especificado.', 16, 1)  
		RETURN;  
	END

	IF @idSucursalNueva IS NOT NULL AND @idSucursal = @idSucursalNueva
	BEGIN
		RAISERROR('La sucursal nueva no puede ser la sucursal que desea borrar.', 16, 1)  
		RETURN;  
	END

	IF @idSucursalNueva IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE idSucursal = @idSucursalNueva)
	BEGIN
		RAISERROR('No existe una sucursal nueva con el ID especificado.', 16, 1)  
		RETURN;  
	END
	
	IF @idSucursalNueva IS NOT NULL AND (SELECT estado FROM Sucursal.Sucursal WHERE idSucursal = @idSucursalNueva) = 0
	BEGIN
		RAISERROR('La sucursal nueva esta inactiva.', 16, 1)  
		RETURN;  
	END

	-- Iniciar transaccion, ya que se van a modificar varias tablas
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Quitar asignacion de los empleados de la sucursal
		UPDATE Empleado.Empleado
		SET idSucursal = @idSucursalNueva
		WHERE idSucursal = @idSucursal;

        -- Inactivar la sucursal
        UPDATE Sucursal.Sucursal
        SET estado = 0
        WHERE idSucursal = @idSucursal;

        COMMIT;
    END TRY
    BEGIN CATCH
		ROLLBACK;
		PRINT 'Se produjo un error, no se pudo realizar el borrado.';
		THROW;
    END CATCH
END
GO


---------------------------------------------------------------------
-- METODO DE PAGO --

CREATE OR ALTER PROCEDURE Venta.BorrarMetodoPago (@idMetodoPago INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Venta.MetodoPago WHERE idMetodoPago = @idMetodoPago)
	BEGIN
		RAISERROR('No existe un metodo de pago con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Inactivar el metodo de pago
    UPDATE Venta.MetodoPago
    SET estado = 0
    WHERE idMetodoPago = @idMetodoPago;
END
GO


--------------------------- REACTIVACION ----------------------------  

---------------------------------------------------------------------
-- PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.ReactivarProducto (@idProducto INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Producto.Producto WHERE idProducto = @idProducto)
	BEGIN
		RAISERROR('No existe un producto con el ID especificado.', 16, 1)  
		RETURN;  
	END

    -- Verificar si la categoría está activa
    DECLARE @idCategoriaProducto INT;

    SELECT @idCategoriaProducto = idCategoriaProducto
    FROM Producto.Producto 
    WHERE idProducto = @idProducto;

    IF EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE idCategoriaProducto = @idCategoriaProducto AND estado = 0)
    BEGIN
        RAISERROR('La categoria asociada a este producto está desactivada. Primero debe activar la categoria.', 16, 1)
        RETURN;
    END

	-- Activar producto
    UPDATE Producto.Producto
    SET estado = 1
    WHERE idProducto = @idProducto;
END
GO


---------------------------------------------------------------------
-- CATEGORIA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.ReactivarCategoriaProducto (@idCategoriaProducto INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE idCategoriaProducto = @idCategoriaProducto)
	BEGIN
		RAISERROR('No existe una categoria de producto con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Verificar si la linea está activa
    DECLARE @idLineaProducto INT;

    SELECT @idLineaProducto = idLineaProducto
    FROM Producto.CategoriaProducto
    WHERE idCategoriaProducto = @idCategoriaProducto;

    IF EXISTS (SELECT 1 FROM Producto.LineaProducto WHERE idLineaProducto = @idLineaProducto AND estado = 0)
    BEGIN
        RAISERROR('La línea asociada a esta categoría está desactivada. Primero debe activar la línea.', 16, 1)
        RETURN;
    END

    -- Activar la categoria de producto
    UPDATE Producto.CategoriaProducto
    SET estado = 1
    WHERE idCategoriaProducto = @idCategoriaProducto;
END
GO


---------------------------------------------------------------------
-- LINEA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.ReactivarLineaProducto (@idLineaProducto INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Producto.LineaProducto WHERE idLineaProducto = @idLineaProducto)
	BEGIN
		RAISERROR('No existe una linea de producto con el ID especificado.', 16, 1)  
		RETURN;  
	END

    -- Activar la categoria de producto
    UPDATE Producto.LineaProducto
    SET estado = 1
    WHERE idLineaProducto = @idLineaProducto;
END
GO


---------------------------------------------------------------------
-- EMPLEADO --

CREATE OR ALTER PROCEDURE Empleado.ReactivarEmpleado (@legajoEmpleado INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Empleado.Empleado WHERE legajoEmpleado = @legajoEmpleado)
	BEGIN
		RAISERROR('No existe un empleado con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Activar empleado
    UPDATE Empleado.Empleado
    SET fechaBaja = NULL
    WHERE legajoEmpleado = @legajoEmpleado;
	-- En mi sistema la fecha de alta representa el ingreso original del empleado, por lo tanto se mantiene igual al reactivarlo.
END
GO


---------------------------------------------------------------------
-- SUCURSAL --

CREATE OR ALTER PROCEDURE Sucursal.ReactivarSucursal (@idSucursal INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE idSucursal = @idSucursal)
	BEGIN
		RAISERROR('No existe una sucursal con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Activar sucursal
    UPDATE Sucursal.Sucursal
    SET estado = 1
    WHERE idSucursal = @idSucursal;
END
GO


---------------------------------------------------------------------
-- METODO DE PAGO --

CREATE OR ALTER PROCEDURE Venta.ReactivarMetodoPago (@idMetodoPago INT)
AS
BEGIN
	-- Comprobar que existe el ID
    IF NOT EXISTS (SELECT 1 FROM Venta.MetodoPago WHERE idMetodoPago = @idMetodoPago)
	BEGIN
		RAISERROR('No existe un metodo de pago con el ID especificado.', 16, 1)  
		RETURN;  
	END

	-- Activar el metodo de pago
    UPDATE Venta.MetodoPago
    SET estado = 1
    WHERE idMetodoPago = @idMetodoPago;
END
GO
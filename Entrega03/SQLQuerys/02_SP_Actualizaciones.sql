---------------------------------------------------------------------
-- Fecha de entrega: 28/02/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Genere store procedures para manejar las actualizaciones

---------------------------------------------------------------------
USE Com1353G04
GO

-------------------------- ACTUALIZACIONES --------------------------

---------------------------------------------------------------------
-- LINEA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.ActualizarLineaProducto
    @idLineaProducto INT,
    @nombre VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Producto.LineaProducto WHERE idLineaProducto = @idLineaProducto)
        SET @error = @error + 'No existe una línea con el ID especificado. ';

    IF LTRIM(RTRIM(@nombre)) = '' 
        SET @error = @error + 'El nombre no puede estar vacío. ';

	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
        -- Actualización
        UPDATE Producto.LineaProducto
        SET nombre = @nombre
        WHERE idLineaProducto = @idLineaProducto;
	END
END
GO


---------------------------------------------------------------------
-- CATEGORIA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.ActualizarCategoriaProducto
    @idCategoriaProducto INT,
    @nombre VARCHAR(50) = NULL,
    @idLineaProducto INT = NULL 
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE idCategoriaProducto = @idCategoriaProducto)
        SET @error = @error + 'No existe una categoría de producto con el ID especificado. ';
    
    IF @idLineaProducto IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Producto.LineaProducto WHERE idLineaProducto = @idLineaProducto)
        SET @error = @error + 'No existe una línea con el ID especificado. ';
    
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
        SET @error = @error + 'El nombre no puede estar vacío.';
	
	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
        -- Actualización
        UPDATE Producto.CategoriaProducto
        SET 
            nombre = COALESCE(@nombre, nombre),
            idLineaProducto = COALESCE(@idLineaProducto, idLineaProducto)
        WHERE idCategoriaProducto = @idCategoriaProducto;
	END
END
GO


---------------------------------------------------------------------
-- PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.ActualizarProducto
    @idProducto INT,
    @nombre VARCHAR(100) = NULL, 
    @precio DECIMAL(10,2) = NULL, 
    @precioReferencia DECIMAL(10,2) = NULL, 
    @unidadReferencia CHAR(2) = NULL,
    @fecha DATETIME = NULL, 
    @descripcionUnidad VARCHAR(50) = NULL,
    @idCategoriaProducto INT = NULL
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Producto.Producto WHERE idProducto = @idProducto)
        SET @error = @error + 'No existe un producto con el ID especificado. ';
    
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '' 
        SET @error = @error + 'El nombre no puede ser vacío. ';
    
    IF @precio IS NOT NULL AND @precio <= 0
        SET @error = @error + 'El precio debe ser mayor a 0. ';
    
    IF @precioReferencia IS NOT NULL AND @precioReferencia <= 0
        SET @error = @error + 'El precio de referencia debe ser mayor a 0. ';
    
    IF @unidadReferencia IS NOT NULL AND LTRIM(RTRIM(@unidadReferencia)) = '' 
        SET @error = @error + 'La unidad de referencia no puede estar vacía. ';
    
    IF @descripcionUnidad IS NOT NULL AND LTRIM(RTRIM(@descripcionUnidad)) = '' 
        SET @error = @error + 'La descripción unidad no puede estar vacía. ';
    
    IF @idCategoriaProducto IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE idCategoriaProducto = @idCategoriaProducto)
        SET @error = @error + 'No existe una categoría de producto con el ID especificado. ';
    	
	-- Informar errores si los hubo 
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
        -- Actualización
        UPDATE Producto.Producto
        SET 
            nombre = COALESCE(@nombre, nombre),
            precio = COALESCE(@precio, precio),
            precioReferencia = COALESCE(@precioReferencia, precioReferencia),
            unidadReferencia = COALESCE(@unidadReferencia, unidadReferencia),
            fecha = COALESCE(@fecha, fecha),
            descripcionUnidad = COALESCE(@descripcionUnidad, descripcionUnidad),
            idCategoriaProducto = COALESCE(@idCategoriaProducto, idCategoriaProducto)
        WHERE idProducto = @idProducto;
	END
END
GO


---------------------------------------------------------------------
-- CLIENTE --

CREATE OR ALTER PROCEDURE Cliente.ActualizarCliente
    @idCliente INT,
    @cuil CHAR(13) = NULL,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @telefono CHAR(10) = NULL,
    @genero CHAR(6) = NULL,  
    @tipoCliente CHAR(6) = NULL
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Cliente.Cliente WHERE idCliente = @idCliente)
        SET @error = @error + 'No existe un cliente con el ID especificado. ';
    
    IF @cuil IS NOT NULL AND Sistema.ValidarCUIL(@cuil) = 0
        SET @error = @error + 'El CUIL es inválido. ';
    
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '' 
        SET @error = @error + 'El nombre no puede estar vacío. ';
    
    IF @apellido IS NOT NULL AND LTRIM(RTRIM(@apellido)) = '' 
        SET @error = @error + 'El apellido no puede estar vacío. ';
    
    IF @telefono IS NOT NULL AND LTRIM(RTRIM(@telefono)) = '' 
        SET @error = @error + 'El teléfono no puede estar vacío. ';
    
    IF @genero IS NOT NULL AND @genero NOT IN ('Female', 'Male')
        SET @error = @error + 'El género debe ser Female o Male. ';
    
    IF @tipoCliente IS NOT NULL AND @tipoCliente NOT IN ('Member', 'Normal')
        SET @error = @error + 'El tipo de cliente debe ser Member o Normal. ';
    	
	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
        -- Actualización
        UPDATE Cliente.Cliente
        SET 
            cuil = COALESCE(@cuil, cuil),
            nombre = COALESCE(@nombre, nombre),
            apellido = COALESCE(@apellido, apellido),
            telefono = COALESCE(@telefono, telefono),
            genero = COALESCE(@genero, genero),
            tipoCliente = COALESCE(@tipoCliente, tipoCliente)
        WHERE idCliente = @idCliente;
	END
END
GO


---------------------------------------------------------------------
-- SUCURSAL --

CREATE OR ALTER PROCEDURE Sucursal.ActualizarSucursal
    @idSucursal INT,
    @ciudad VARCHAR(50) = NULL,
    @sucursal VARCHAR(50) = NULL,
    @direccion VARCHAR(100) = NULL,
    @telefono CHAR(10) = NULL,
    @horario CHAR(50) = NULL
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE idSucursal = @idSucursal)
        SET @error = @error + 'No existe una sucursal con el ID especificado. ';
    
    IF @ciudad IS NOT NULL AND LTRIM(RTRIM(@ciudad)) = '' 
        SET @error = @error + 'La ciudad no puede estar vacía. ';
    
    IF @sucursal IS NOT NULL AND LTRIM(RTRIM(@sucursal)) = '' 
        SET @error = @error + 'La sucursal no puede estar vacía. ';
    
    IF @direccion IS NOT NULL AND LTRIM(RTRIM(@direccion)) = '' 
        SET @error = @error + 'La dirección no puede estar vacía. ';
    
    IF @telefono IS NOT NULL AND LTRIM(RTRIM(@telefono)) = '' 
        SET @error = @error + 'El teléfono no puede estar vacío. ';
    
    IF @horario IS NOT NULL AND LTRIM(RTRIM(@horario)) = '' 
        SET @error = @error + 'El horario no puede estar vacío. ';
    	
	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
        -- Actualización
        UPDATE Sucursal.Sucursal
        SET 
            ciudad = COALESCE(@ciudad, ciudad),
            sucursal = COALESCE(@sucursal, sucursal),
            direccion = COALESCE(@direccion, direccion),
            telefono = COALESCE(@telefono, telefono),
            horario = COALESCE(@horario, horario)
        WHERE idSucursal = @idSucursal;
	END
END
GO


---------------------------------------------------------------------
-- EMPLEADO --

CREATE OR ALTER PROCEDURE Empleado.ActualizarEmpleado
    @legajoEmpleado INT,
    @cuil CHAR(13) = NULL,
    @nombre VARCHAR(30) = NULL,
    @apellido VARCHAR(30) = NULL,
    @direccion VARCHAR(100) = NULL,
    @emailPersonal VARCHAR(70) = NULL,
    @emailEmpresa VARCHAR(70) = NULL,
    @turno VARCHAR(16) = NULL,
    @cargo VARCHAR(30) = NULL,
    @idSucursal INT = NULL
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Empleado.Empleado WHERE legajoEmpleado = @legajoEmpleado)
        SET @error = @error + 'No existe un empleado con el legajo especificado. ';
    
    IF @cuil IS NOT NULL AND Sistema.ValidarCUIL(@cuil) = 0
        SET @error = @error + 'El CUIL es inválido. ';
    
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
        SET @error = @error + 'El nombre no puede estar vacío. ';
    
    IF @apellido IS NOT NULL AND LTRIM(RTRIM(@apellido)) = ''
        SET @error = @error + 'El apellido no puede estar vacío. ';
    
    IF @emailPersonal IS NOT NULL AND LTRIM(RTRIM(@emailPersonal)) = ''
        SET @error = @error + 'El email personal no puede estar vacío. ';
    
    IF @emailEmpresa IS NOT NULL AND LTRIM(RTRIM(@emailEmpresa)) = ''
        SET @error = @error + 'El email de la empresa no puede estar vacío. ';
    
    IF @turno IS NOT NULL AND @turno NOT IN ('TM', 'TT', 'Jornada completa')
        SET @error = @error + 'El turno debe ser TM, TT o Jornada completa. ';
    
    IF @cargo IS NOT NULL AND LTRIM(RTRIM(@cargo)) = ''
        SET @error = @error + 'El cargo no puede estar vacío. ';
    
    IF @idSucursal IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE idSucursal = @idSucursal)
        SET @error = @error + 'No existe una sucursal con el ID especificado. ';
    	
	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
		-- Abrir la llave simétrica
        OPEN SYMMETRIC KEY EmpleadoLlave
            DECRYPTION BY CERTIFICATE CertificadoEmpleado;

        -- Actualización
        UPDATE Empleado.Empleado
        SET 
            cuil = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @cuil)), cuil),
            cuilHash = COALESCE(HASHBYTES('SHA2_256', CONVERT(VARBINARY, @cuil)), cuilHash),
            nombre = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @nombre)), nombre),
            apellido = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @apellido)), apellido),
            direccion = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @direccion)), direccion),
            emailPersonal = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @emailPersonal)), emailPersonal),
            emailEmpresa = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @emailEmpresa)), emailEmpresa),
            turno = COALESCE(@turno, turno),
            cargo = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @cargo)), cargo),
            idSucursal = COALESCE(@idSucursal, idSucursal)
        WHERE legajoEmpleado = @legajoEmpleado;

        -- Cerrar la llave simétrica
        CLOSE SYMMETRIC KEY EmpleadoLlave;
    END
END
GO


---------------------------------------------------------------------
-- METODO DE PAGO --

CREATE OR ALTER PROCEDURE Venta.ActualizarMetodoPago
    @idMetodoPago INT,
    @nombre VARCHAR(30)
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Venta.MetodoPago WHERE idMetodoPago = @idMetodoPago)
        SET @error = @error + 'No existe un método de pago con el ID especificado. ';
    
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
        SET @error = @error + 'El nombre no puede estar vacío. ';
    
	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        -- Actualización
        UPDATE Venta.MetodoPago
        SET 
        nombre = @nombre
        WHERE idMetodoPago = @idMetodoPago;
    END
END
GO


---------------------------------------------------------------------
-- VENTA --

CREATE OR ALTER PROCEDURE Venta.ActualizarVenta
    @idVenta INT,
    @fecha DATE = NULL,
    @hora TIME = NULL,
    @identificadorPago VARCHAR(30) = NULL,
    @legajoEmpleado INT = NULL,
    @idCliente INT = NULL,
	@idSucursal INT = NULL,
    @nroFactura CHAR(11) = NULL,
    @idMetodoPago INT = NULL,
    @tipoFactura CHAR = NULL,
    @estado CHAR = NULL,
    @total DECIMAL(10,2) = NULL
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Venta.Venta WHERE idVenta = @idVenta)
        SET @error = @error + 'No existe una venta con el ID especificado. ';
	
	IF @idCliente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Cliente.Cliente WHERE idCliente = @idCliente)
        SET @error = @error + 'No existe un cliente con el ID especificado. ';

	IF @idSucursal IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE idSucursal = @idSucursal)
        SET @error = @error + 'No existe una sucursal con el ID especificado. ';

	IF @legajoEmpleado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Empleado.Empleado WHERE legajoEmpleado = @legajoEmpleado)
        SET @error = @error + 'No existe un empleado con el ID especificado. ';

	IF @idMetodoPago IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Venta.MetodoPago WHERE idMetodoPago = @idMetodoPago)
        SET @error = @error + 'No existe un metodo de pago con el ID especificado. ';
	
    IF @tipoFactura IS NOT NULL AND @tipoFactura NOT IN ('A', 'B', 'C')
        SET @error = @error + 'El tipo de factura debe ser A, B o C. ';
    
    IF @estado IS NOT NULL AND @estado NOT IN ('E', 'P', 'C')
        SET @error = @error + 'El estado debe ser E, P o C. ';
    
    IF @total IS NOT NULL AND @total <= 0
        SET @error = @error + 'El total debe ser mayor a 0. ';

	IF @nroFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]' -- ej: 750-67-8428
        SET @error = @error + 'El Nro de factura no es valido, debe ser xxx-xx-xxxx. ';
    
    -- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        -- Actualización
        UPDATE Venta.Venta
        SET 
            fecha = COALESCE(@fecha, fecha),
            hora = COALESCE(@hora, hora),
            identificadorPago = COALESCE(@identificadorPago, identificadorPago),
            legajoEmpleado = COALESCE(@legajoEmpleado, legajoEmpleado),
            idCliente = COALESCE(@idCliente, idCliente),
			idSucursal = COALESCE(@idSucursal, idSucursal),
            nroFactura = COALESCE(@nroFactura, nroFactura),
            idMetodoPago = COALESCE(@idMetodoPago, idMetodoPago),
			tipoFactura = COALESCE(@tipoFactura, tipoFactura),
			estado = COALESCE(@estado, estado),
			total = COALESCE(@total, total)
        WHERE idVenta = @idVenta;
    END
END
GO


---------------------------------------------------------------------
-- DETALLE DE VENTA --

CREATE OR ALTER PROCEDURE Venta.ActualizarDetalleVenta
    @idDetalleVenta INT,
    @idProducto INT = NULL,
    @cantidad INT = NULL,
    @precioUnitarioAlMomentoDeLaVenta DECIMAL(10,2) = NULL,
    @subtotal DECIMAL(10,2) = NULL
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Venta.DetalleVenta WHERE idDetalleVenta = @idDetalleVenta)
        SET @error = @error + 'No existe un detalle de venta con el ID especificado. ';
    
    IF @cantidad IS NOT NULL AND @cantidad <= 0
        SET @error = @error + 'La cantidad debe ser mayor a 0. ';
    
    IF @precioUnitarioAlMomentoDeLaVenta IS NOT NULL AND @precioUnitarioAlMomentoDeLaVenta <= 0
        SET @error = @error + 'El precio unitario debe ser mayor a 0. ';
    
    IF @subtotal IS NOT NULL AND @subtotal <= 0
        SET @error = @error + 'El subtotal debe ser mayor a 0. ';
    
    -- Si hay errores, lanzar el RAISERROR
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        -- Actualización
        UPDATE Venta.DetalleVenta
        SET 
            idProducto = COALESCE(@idProducto, idProducto),
            cantidad = COALESCE(@cantidad, cantidad),
            precioUnitarioAlMomentoDeLaVenta = COALESCE(@precioUnitarioAlMomentoDeLaVenta, precioUnitarioAlMomentoDeLaVenta),
            subtotal = COALESCE(@subtotal, subtotal)
        WHERE idDetalleVenta = @idDetalleVenta;
    END
END
GO

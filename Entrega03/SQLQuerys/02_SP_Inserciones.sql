---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Genere store procedures para manejar la inserción

---------------------------------------------------------------------
USE Com1353G04
GO

---------------------------- INSERCIONES ----------------------------

---------------------------------------------------------------------
-- FUNCIONES --

CREATE OR ALTER FUNCTION Sistema.ValidarCUIL (@cuil VARCHAR(13))
RETURNS BIT
AS
BEGIN
    IF @cuil LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
    BEGIN
        RETURN 1;
    END
	RETURN 0;
END;
GO


---------------------------------------------------------------------
-- LINEA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.InsertarLineaProducto
    @nombre VARCHAR(50)
AS
BEGIN
    -- Validaciones
    IF LTRIM(RTRIM(@nombre)) = '' 
    BEGIN
        RAISERROR('El nombre no puede estar vacío.', 16, 1);
        RETURN;
    END

    -- Inserción
    INSERT INTO Producto.LineaProducto (nombre, estado)
    VALUES (@nombre, 1);
END
GO


---------------------------------------------------------------------
-- CATEGORIA DE PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.InsertarCategoriaProducto
	@nombre VARCHAR(50),
	@idLineaProducto INT
AS
BEGIN
    -- Validaciones
    DECLARE @error VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Producto.LineaProducto WHERE idLineaProducto = @idLineaProducto)
        SET @error = @error + 'No existe una linea de producto con el ID especificado. ';
	ELSE
	BEGIN
		IF (SELECT estado FROM Producto.LineaProducto WHERE idLineaProducto = @idLineaProducto) = 0
			SET @error = @error + 'La linea de producto esta inactiva. ';
	END

    IF LTRIM(RTRIM(@nombre)) = ''
        SET @error = @error + 'El nombre no puede estar vacío. ';
   

	-- Informar errores si los hubo 
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
		-- Inserción
		INSERT INTO Producto.CategoriaProducto(nombre, idLineaProducto, estado) 
		VALUES (@nombre, @idLineaProducto, 1)
	END
END
GO


---------------------------------------------------------------------
-- PRODUCTO --

CREATE OR ALTER PROCEDURE Producto.InsertarProducto
    @nombre VARCHAR(100), 
    @precio DECIMAL(10,2), 
    @precioReferencia DECIMAL(10,2) = NULL, 
    @unidadReferencia VARCHAR(10) = NULL,
    @fecha DATETIME = NULL, 
    @descripcionUnidad VARCHAR(50) = NULL,
    @idCategoriaProducto INT 
AS
BEGIN
    -- Validaciones
    DECLARE @error VARCHAR(MAX) = '';

    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '' 
        SET @error = @error + 'El nombre no puede ser vacío. ';
    
    IF @precio <= 0
        SET @error = @error + 'El precio debe ser mayor a 0. ';
    
    IF @precioReferencia IS NOT NULL AND @precioReferencia <= 0
        SET @error = @error + 'El precio de referencia debe ser mayor a 0. ';
    
    IF @unidadReferencia IS NOT NULL AND LTRIM(RTRIM(@unidadReferencia)) = '' 
        SET @error = @error + 'La unidad de referencia no puede estar vacía. ';
    
    IF @descripcionUnidad IS NOT NULL AND LTRIM(RTRIM(@descripcionUnidad)) = '' 
        SET @error = @error + 'La descripción unidad no puede estar vacía. ';
    
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE idCategoriaProducto = @idCategoriaProducto)
        SET @error = @error + 'No existe una categoría de producto con el ID especificado. ';
   	ELSE
	BEGIN
		IF (SELECT estado FROM Producto.CategoriaProducto WHERE idCategoriaProducto = @idCategoriaProducto) = 0
			SET @error = @error + 'La categoría de producto esta inactiva. ';
	END

	-- Informar errores si los hubo 
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
		-- Inserción
		INSERT INTO Producto.Producto (nombre, precio, precioReferencia, unidadReferencia, fecha, descripcionUnidad, idCategoriaProducto, estado)
		VALUES (@nombre, @precio, @precioReferencia, @unidadReferencia, @fecha, @descripcionUnidad, @idCategoriaProducto, 1)
	END

END
GO


---------------------------------------------------------------------
-- CLIENTE --

CREATE OR ALTER PROCEDURE Cliente.InsertarCliente
	@cuil CHAR(13),
	@nombre VARCHAR(50),
	@apellido VARCHAR(50),
	@telefono CHAR(10),
	@genero CHAR(6),  
	@tipoCliente CHAR(6)
AS
BEGIN
	
	DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones  
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
        -- Insercion
        INSERT INTO Cliente.Cliente(cuil, nombre, apellido, telefono, genero, tipoCliente) 
		VALUES (@cuil, @nombre, @apellido, @telefono, @genero, @tipoCliente)
	END
END
GO


---------------------------------------------------------------------
-- SUCURSAL --

CREATE OR ALTER PROCEDURE Sucursal.InsertarSucursal
	@ciudad VARCHAR(50),
	@sucursal VARCHAR(50),
	@direccion VARCHAR(100),
	@telefono CHAR(10),
	@horario CHAR(50)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
    IF LTRIM(RTRIM(@ciudad)) = '' 
        SET @error = @error + 'La ciudad no puede estar vacía. ';
    
    IF LTRIM(RTRIM(@sucursal)) = '' 
        SET @error = @error + 'La sucursal no puede estar vacía. ';
    
    IF LTRIM(RTRIM(@direccion)) = '' 
        SET @error = @error + 'La dirección no puede estar vacía. ';
    
    IF LTRIM(RTRIM(@telefono)) = '' 
        SET @error = @error + 'El teléfono no puede estar vacío. ';
    
    IF LTRIM(RTRIM(@horario)) = '' 
        SET @error = @error + 'El horario no puede estar vacío. ';
    	
	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
	BEGIN
		-- Inserción
		INSERT INTO Sucursal.Sucursal(ciudad, sucursal, direccion, telefono, horario, estado) 
		VALUES (@ciudad, @sucursal, @direccion, @telefono, @horario, 1)
	END
END
GO


---------------------------------------------------------------------
-- EMPLEADO --

CREATE OR ALTER PROCEDURE Empleado.InsertarEmpleado
    @legajoEmpleado INT,
    @cuil CHAR(13),
    @nombre VARCHAR(30),
    @apellido VARCHAR(30),
    @direccion VARCHAR(100),
    @emailPersonal VARCHAR(70),
    @emailEmpresa VARCHAR(70),
    @turno VARCHAR(17),
    @cargo VARCHAR(30),
    @fechaAlta DATE,
    @idSucursal INT
AS
BEGIN
-- Validaciones
	DECLARE @error VARCHAR(MAX) = '';
    
	IF Sistema.ValidarCUIL(@cuil) = 0
		SET @error = @error + 'El CUIL es inválido. ';
    
	IF LTRIM(RTRIM(@nombre)) = ''
		SET @error = @error + 'El nombre no puede estar vacío. ';
    
	IF LTRIM(RTRIM(@apellido)) = ''
		SET @error = @error + 'El apellido no puede estar vacío. ';
    
	IF LTRIM(RTRIM(@emailPersonal)) = ''
		SET @error = @error + 'El email personal no puede estar vacío. ';
    
	IF LTRIM(RTRIM(@emailEmpresa)) = ''
		SET @error = @error + 'El email de la empresa no puede estar vacío. ';
    
	IF @turno NOT IN ('TM', 'TT', 'Jornada completa')
		SET @error = @error + 'El turno debe ser TM, TT o Jornada completa. ';
    
	IF LTRIM(RTRIM(@cargo)) = ''
		SET @error = @error + 'El cargo no puede estar vacío. ';
    
	IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE idSucursal = @idSucursal)
		SET @error = @error + 'No existe una sucursal con el ID especificado. ';
    ELSE
	BEGIN
		IF (SELECT estado FROM Sucursal.Sucursal WHERE idSucursal = @idSucursal) = 0
			SET @error = @error + 'La sucursal esta inactiva. ';
	END

	-- Informar errores si los hubo
	IF @error <> ''
		RAISERROR(@error, 16, 1);
	ELSE
	BEGIN
		-- Inserción

		-- Abrir la llave simétrica
		OPEN SYMMETRIC KEY EmpleadoLlave
			DECRYPTION BY CERTIFICATE CertificadoEmpleado;

		INSERT INTO Empleado.Empleado (
			legajoEmpleado, 
			cuil,  -- Almacena el CUIL encriptado
			cuilHash,        -- Almacena el hash del CUIL
			nombre, 
			apellido, 
			direccion, 
			emailPersonal, 
			emailEmpresa, 
			turno, 
			cargo, 
			fechaAlta, 
			idSucursal
		)
		VALUES (
			@legajoEmpleado, 
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @cuil)), 
			HASHBYTES('SHA2_256', CONVERT(VARBINARY, @cuil)), 
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @nombre)),
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @apellido)),
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @direccion)),
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @emailPersonal)),
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @emailEmpresa)),
			@turno,
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, @cargo)),
			ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, CONVERT(VARCHAR(10), @fechaAlta, 120))),  
			@idSucursal
		);

		-- Cerrar la llave simétrica
		CLOSE SYMMETRIC KEY EmpleadoLlave;
	END
END;
GO


---------------------------------------------------------------------
-- METODO DE PAGO --

CREATE OR ALTER PROCEDURE Venta.InsertarMetodoPago
    @nombre VARCHAR(30)
AS
BEGIN
	-- Validaciones
    IF LTRIM(RTRIM(@nombre)) = '' 
    BEGIN
        RAISERROR('El nombre no puede estar vacio.', 16, 1);
        RETURN;
    END

    -- Inserción
    INSERT INTO Venta.MetodoPago (nombre, estado)
    VALUES (@nombre, 1);
END
GO


---------------------------------------------------------------------
-- VENTA --

CREATE OR ALTER PROCEDURE Venta.InsertarVenta
	@nroFactura CHAR(11),
    @tipoFactura CHAR,
    @estado CHAR,
    @fecha DATE,
    @hora TIME,
    @total DECIMAL(10,2),
	@identificadorPago VARCHAR(30),
    @legajoEmpleado INT,
    @idCliente INT,
    @idSucursal INT,
    @idMetodoPago INT,
	@idVentaGenerada INT OUTPUT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones
	IF @nroFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]' -- ej: 750-67-8428
        SET @error = @error + 'El Nro de factura no es valido, debe ser xxx-xx-xxxx. ';

    IF @tipoFactura NOT IN ('A', 'B', 'C')
        SET @error = @error + 'El tipo de factura debe ser A, B o C. ';
    
    IF @estado NOT IN ('E', 'P', 'C')
        SET @error = @error + 'El estado debe ser E, P o C. ';
    
    IF @total <= 0
        SET @error = @error + 'El total debe ser mayor a 0. ';
    	
	-- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
		-- Inserción
		INSERT INTO Venta.Venta (nroFactura, tipoFactura, estado, fecha, hora, total, identificadorPago, legajoEmpleado, idSucursal, idCliente, idMetodoPago)
		VALUES (@nroFactura, @tipoFactura, @estado, @fecha, @hora, @total, @identificadorPago, @legajoEmpleado, @idSucursal, @idCliente, @idMetodoPago);

		SET @idVentaGenerada = SCOPE_IDENTITY();
	END
END
GO


---------------------------------------------------------------------
-- DETALLE DE VENTA --

CREATE OR ALTER PROCEDURE Venta.InsertarDetalleVenta
    @idVenta INT,
    @idProducto INT,
    @cantidad INT,
    @precioUnitarioAlMomentoDeLaVenta DECIMAL(10,2)
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = '';

    -- Validaciones  
    IF @cantidad IS NOT NULL AND @cantidad <= 0
        SET @error = @error + 'La cantidad debe ser mayor a 0. ';
    
    IF @precioUnitarioAlMomentoDeLaVenta IS NOT NULL AND @precioUnitarioAlMomentoDeLaVenta <= 0
        SET @error = @error + 'El precio unitario debe ser mayor a 0. ';
    
    
    -- Informar errores si los hubo
    IF @error <> ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
		-- Inserción
		INSERT INTO Venta.DetalleVenta (idVenta, idProducto, cantidad, precioUnitarioAlMomentoDeLaVenta, subtotal)
		VALUES (@idVenta, @idProducto, @cantidad, @precioUnitarioAlMomentoDeLaVenta, @cantidad * @precioUnitarioAlMomentoDeLaVenta);
	END
END
GO



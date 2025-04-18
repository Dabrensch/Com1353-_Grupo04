﻿---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557
   -- Turri, Teo Francis 42819058

---------------------------------------------------------------------
-- Consigna: Realice los SP para importar toda la información de los archivos a la base de datos

---------------------------------------------------------------------
USE Com1353G04
GO

---------------------------- IMPORTACIONES --------------------------  

---------------------------------------------------------------------
-- SUCURSALES --

CREATE OR ALTER PROCEDURE Sucursal.ImportarSucursales
    @RutaArchivo NVARCHAR(1024)
AS
BEGIN	
    -- Tabla temporal para almacenar los datos importados
	CREATE TABLE #DatosSucursalArchivo (
		Ciudad VARCHAR(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
		Sucursal VARCHAR(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
		Direccion VARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
		Telefono CHAR(10) COLLATE Modern_Spanish_CI_AS NOT NULL,
		Horario VARCHAR(50) COLLATE Modern_Spanish_CI_AS NOT NULL
	);


	BEGIN TRY
		-- Comando para importar datos desde el archivo Excel
		DECLARE @CargaDatosArchivo NVARCHAR(1024) = '
			INSERT INTO #DatosSucursalArchivo (Ciudad, Sucursal, Direccion, Horario, Telefono)
			SELECT Ciudad, [Reemplazar por] AS Sucursal, direccion, Horario, Telefono
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
							 ''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES; IMEX=1;'', 
							 ''SELECT * FROM [sucursal$]'');
		';
    
		-- Intentamos ejecutar la consulta
		EXEC sp_executesql @CargaDatosArchivo;

		PRINT 'El archivo Excel es válido y los datos fueron cargados correctamente.';
	END TRY
	BEGIN CATCH
		-- Si ocurre un error (por ejemplo, archivo inválido), capturamos el mensaje de error
		RAISERROR (
			'Error: El archivo no es v�lido o no se puede acceder.',
			10,
			1
		);
		THROW;
	END CATCH
    
    -- Actualizar registros existentes si hay cambios
    UPDATE target
    SET
        target.Sucursal = source.Sucursal,
        target.Direccion = source.Direccion,
        target.Horario = source.Horario,
        target.Telefono = source.Telefono

    FROM Sucursal.Sucursal AS target
    JOIN #DatosSucursalArchivo AS source ON target.Ciudad = source.Ciudad AND target.sucursal = source.Sucursal
    WHERE target.Sucursal != source.Sucursal 
       OR target.Direccion != source.Direccion 
       OR target.Horario != source.Horario 
       OR target.Telefono != source.Telefono;

    -- Insertar nuevos registros si no existen
    INSERT INTO Sucursal.Sucursal (Ciudad, Sucursal, Direccion, Horario, Telefono, Estado)
    SELECT source.Ciudad, source.Sucursal, source.Direccion, source.Horario, source.Telefono, 1
    FROM #DatosSucursalArchivo AS source
    WHERE NOT EXISTS (
        SELECT 1 FROM Sucursal.Sucursal AS target
        WHERE target.Ciudad = source.Ciudad AND target.Sucursal = source.Sucursal
    );



	DROP TABLE #DatosSucursalArchivo;
	
END;
GO


---------------------------------------------------------------------
-- METODOS DE PAGO --

CREATE OR ALTER PROCEDURE Venta.ImportarMetodosDePago
	@RutaArchivo NVARCHAR(1024)
AS
BEGIN
	-- Tabla temporal para almacenar los datos importados
    CREATE TABLE #DatosMedioPagoArchivo (
        nombre VARCHAR(30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    );

	BEGIN TRY
		-- Comando para importar datos desde el archivo Excel
		DECLARE @CargaDatosArchivo NVARCHAR(1024) = '
			INSERT INTO #DatosMedioPagoArchivo
			SELECT F2 AS MedioPago
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
							 ''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES; IMEX=1;'',
							 ''SELECT * FROM [medios de pago$]'');
		';
    
		-- Intentamos ejecutar la consulta
		EXEC sp_executesql @CargaDatosArchivo;

		PRINT 'El archivo Excel es v�lido y los datos fueron cargados correctamente.';
	END TRY
	BEGIN CATCH
		-- Si ocurre un error (por ejemplo, archivo inv�lido), capturamos el mensaje de error
		RAISERROR (
			'Error: El archivo no es v�lido o no se puede acceder.',
			10,
			1
		);
		THROW;
	END CATCH;
	  -- Actualizar registros existentes si hay cambios
    UPDATE target
    SET
        target.nombre = source.nombre
    FROM Venta.MetodoPago AS target
    JOIN #DatosMedioPagoArchivo AS source ON target.nombre = source.nombre

    -- Insertar nuevos registros si no existen
    INSERT INTO Venta.MetodoPago (nombre, estado)
    SELECT source.nombre, 1
    FROM #DatosMedioPagoArchivo AS source
    WHERE NOT EXISTS (
        SELECT 1 FROM Venta.MetodoPago AS target
        WHERE target.nombre = source.nombre
    );


	DROP TABLE #DatosMedioPagoArchivo;
  
END;
GO


---------------------------------------------------------------------
-- EMPLEADOS --

CREATE OR ALTER PROCEDURE Empleado.ImportarEmpleados
	@RutaArchivo NVARCHAR(1024)
AS
BEGIN
	-- Tabla temporal para almacenar los datos importados
	CREATE TABLE #DatosEmpleados (
		legajo INT,
		nombre VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
		apellido VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
		direccion VARCHAR(100) COLLATE Modern_Spanish_CI_AS,
		emailPersonal VARCHAR(70) COLLATE Modern_Spanish_CI_AS,
		emailEmpresa VARCHAR(70) COLLATE Modern_Spanish_CI_AS,
		cargo VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
		idSucursal INT,
		turno VARCHAR(16) COLLATE Modern_Spanish_CI_AS,
		cuil CHAR(13) COLLATE Modern_Spanish_CI_AS,
		fechaAlta DATE
	);
	

	BEGIN TRY
		DECLARE @CargaDatosArchivo NVARCHAR(1024) = '
			INSERT INTO #DatosEmpleados (legajo, nombre, apellido, direccion, emailPersonal, 
										emailEmpresa, cargo, turno, cuil, idSucursal, fechaAlta)

			SELECT [Legajo/ID], Nombre, Apellido, Direccion, [email personal], [email empresa], Cargo, Turno, 
			(SELECT Sistema.GenerarCUIL(Excel.DNI, Excel.[Nombre])),
			(SELECT idSucursal FROM Sucursal.Sucursal WHERE Sucursal.Sucursal.sucursal = Excel.Sucursal COLLATE Modern_Spanish_CI_AS
																AND Sucursal.Sucursal.estado = 1),
			GETDATE()
			
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
							 ''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES; IMEX=1;'',
							 ''SELECT * FROM [Empleados$]  WHERE [Legajo/ID] IS NOT NULL '') AS Excel;
		';

		-- Intentamos ejecutar la consulta
		EXEC sp_executesql @CargaDatosArchivo;
	
		PRINT 'El archivo Excel es v�lido y los datos fueron cargados correctamente.';
	END TRY

	BEGIN CATCH
		-- Si ocurre un error (por ejemplo, archivo inv�lido), capturamos el mensaje de error
		RAISERROR (
			'Error: El archivo no es v�lido o no se puede acceder.',
			10,
			1
		);
		THROW;
	END CATCH;

	-- Abrir la llave simétrica
	OPEN SYMMETRIC KEY EmpleadoLlave
		DECRYPTION BY CERTIFICATE CertificadoEmpleado;

	-- Actualizar empleados existentes (encriptando los datos)
	UPDATE target
	SET
		target.nombre = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.nombre)), target.nombre),
		target.apellido = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.apellido)), target.apellido),
		target.direccion = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.direccion)), target.direccion),
		target.emailPersonal = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.emailPersonal)), target.emailPersonal),
		target.emailEmpresa = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.emailEmpresa)), target.emailEmpresa),
		target.cargo = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.cargo)), target.cargo),
		target.turno = COALESCE(source.turno, target.turno),
		target.cuil = COALESCE(ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.cuil)), target.cuil),
		target.idSucursal = COALESCE(source.idSucursal, target.idSucursal)
	FROM Empleado.Empleado AS target
	JOIN #DatosEmpleados AS source ON target.legajoEmpleado = source.legajo
	WHERE 
		target.nombre != source.nombre 
		OR target.apellido != source.apellido
		OR target.direccion != source.direccion
		OR target.emailPersonal != source.emailPersonal
		OR target.emailEmpresa != source.emailEmpresa
		OR target.cargo != source.cargo
		OR target.idSucursal != source.idSucursal
		OR target.turno != source.turno
		OR target.cuil != source.cuil;

	-- Insertar nuevos empleados que no existen en la tabla (encriptando los datos)
	INSERT INTO Empleado.Empleado (legajoEmpleado, nombre, apellido, direccion, emailPersonal, emailEmpresa, cargo, idSucursal, turno, cuil, cuilHash, fechaAlta)
	SELECT 
		source.legajo,
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.nombre)),
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.apellido)),
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.direccion)),
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.emailPersonal)),
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.emailEmpresa)),
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.cargo)),
		source.idSucursal,
		source.turno,
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, source.cuil)),
		HASHBYTES('SHA2_256', CONVERT(VARBINARY, source.cuil)), 
		ENCRYPTBYKEY(KEY_GUID('EmpleadoLlave'), CONVERT(VARBINARY, CONVERT(VARCHAR(10), GETDATE(), 120)))
	FROM #DatosEmpleados AS source
	WHERE NOT EXISTS (
		SELECT 1
		FROM Empleado.Empleado AS target
		WHERE target.legajoEmpleado = source.legajo
	);

	-- Cerrar la llave simétrica
	CLOSE SYMMETRIC KEY EmpleadoLlave;

	-- Eliminar la tabla temporal
	DROP TABLE #DatosEmpleados;

  
END;
GO


---------------------------------------------------------------------
-- PRODUCTOS --


-- Clasificacion de productos
CREATE OR ALTER PROCEDURE Producto.ImportarClasificacionProductos(@RutaArchivo NVARCHAR(1024))
AS
BEGIN
	BEGIN TRY
		CREATE TABLE #tempClasificacionLineaCategoria (
			linea VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
			categoria VARCHAR(50) COLLATE Modern_Spanish_CI_AS
		);
	
		DECLARE @CargaDatosArchivo NVARCHAR(1024) = '

			INSERT INTO #tempClasificacionLineaCategoria (linea, categoria)
			SELECT [Línea de producto], Producto
			FROM OPENROWSET(
					''Microsoft.ACE.OLEDB.12.0'',
					''Excel 12.0;HDR=YES;IMEX=1;Database=' + @RutaArchivo + ''',
					''SELECT * FROM [Clasificacion productos$]''
			)';

		EXEC sp_executesql @CargaDatosArchivo;

		INSERT INTO Producto.LineaProducto(nombre)
		SELECT DISTINCT linea 
		FROM #tempClasificacionLineaCategoria
		WHERE NOT EXISTS (
			SELECT 1 
			FROM Producto.LineaProducto lineaProd
			WHERE lineaProd.nombre =  #tempClasificacionLineaCategoria.linea
		);


		INSERT INTO Producto.CategoriaProducto(nombre, idLineaProducto)
		SELECT categoria, 
			   (SELECT idLineaProducto 
				FROM Producto.LineaProducto AS lineaProd 
				WHERE lineaProd.nombre = #tempClasificacionLineaCategoria.linea)
		FROM #tempClasificacionLineaCategoria
		WHERE NOT EXISTS (
			SELECT 1
			FROM Producto.CategoriaProducto AS catProd
			WHERE catProd.nombre = categoria
		);


		DROP TABLE #tempClasificacionLineaCategoria;



		--Insertamos una linea de producto: Electronica
		IF NOT EXISTS (
			SELECT 1
			FROM Producto.LineaProducto
			WHERE nombre = 'Electrónica'
		)
		BEGIN
			INSERT INTO Producto.LineaProducto(nombre, estado)
			VALUES ('Electrónica', 1);
		END;

		--Insertamos cada categoría solo si no existe de los productos de Electronica
		DECLARE @idLineaElectronica INT = (
			SELECT idLineaProducto 
			FROM Producto.LineaProducto 
			WHERE nombre = 'Electrónica'
		);

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Teléfono' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Teléfono', @idLineaElectronica);
		END;

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Monitor' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Monitor', @idLineaElectronica);
		END;

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Laptop' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Laptop', @idLineaElectronica);
		END;

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Auricular' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Auricular', @idLineaElectronica);
		END;

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Cargador' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Cargador', @idLineaElectronica);
		END;

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Electrodoméstico' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Electrodoméstico', @idLineaElectronica);
		END;

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Televisor' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Televisor', @idLineaElectronica);
		END;

		IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE nombre = 'Batería' AND idLineaProducto = @idLineaElectronica)
		BEGIN
			INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
			VALUES ('Batería', @idLineaElectronica);
		END;


	END TRY
	BEGIN CATCH
		PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH
END;
GO


-- catalogo.csv
CREATE OR ALTER PROCEDURE Producto.ImportarCatalogo (@RutaArchivo NVARCHAR(1024))
AS
BEGIN
    -- Separamos el directorio y el nombre del archivo
    DECLARE @NombreArchivo NVARCHAR(100) = RIGHT(@RutaArchivo, CHARINDEX('/', REVERSE(@RutaArchivo)) - 1);
    DECLARE @Directorio NVARCHAR(500) = LEFT(@RutaArchivo, LEN(@RutaArchivo) - CHARINDEX('/', REVERSE(@RutaArchivo)));

    -- Crear una tabla temporal sin los campos 'id' y 'date'
    CREATE TABLE #TempProducto (
		id INT,
        category VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
        name VARCHAR(100) COLLATE Modern_Spanish_CI_AS,
        price DECIMAL(10,2),
        reference_price DECIMAL(10,2),
        reference_unit VARCHAR(10) COLLATE Modern_Spanish_CI_AS,
        date DATETIME
    );

    -- Realizar la carga del archivo CSV usando BULK INSERT
	DECLARE @SQL NVARCHAR(MAX) = 'INSERT INTO #TempProducto (id, category, name, price, reference_price, reference_unit, date)
    SELECT 
		id,
        category,
        -- Reemplazamos las secuencias erróneas de caracteres en la columna name
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name, ''Ã¡'', ''á''), 
            ''Ã©'', ''é''), 
            ''Ã­'', ''í''), 
            ''Ã³'', ''ó''), 
            ''Ãº'', ''ú''), 
            ''Ã±'', ''ñ''), 
            ''Ã‘'', ''Ñ'') AS name,
        CAST(price / 100 AS DECIMAL(10, 2)),  -- Aseguramos que el precio se almacene como decimal
		CAST(reference_price / 100 AS DECIMAL(10, 2)),  -- Hacemos lo mismo con el precio de referencia
		reference_unit,
		date
    FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
        ''Text;HDR=YES;FMT=Delimited;Database=' + @Directorio + ''',
        ''SELECT * FROM [' + @NombreArchivo + ']'');';


    -- Ejecutar la consulta OPENROWSET
	EXEC sp_executesql @SQL;


-- Actualizamos los productos existentes
	UPDATE p
	SET 
		p.precio = t.price,
		p.precioReferencia = t.reference_price,
		p.unidadReferencia = t.reference_unit,
		p.fecha = t.date,
		p.idCategoriaProducto = (
			SELECT idCategoriaProducto
			FROM Producto.CategoriaProducto
			WHERE nombre COLLATE Modern_Spanish_CI_AS = t.category COLLATE Modern_Spanish_CI_AS
		)
	FROM Producto.Producto p
	INNER JOIN #TempProducto t ON p.nombre COLLATE Modern_Spanish_CI_AS = t.name COLLATE Modern_Spanish_CI_AS;

	-- Insertamos los productos que no existen
	WITH ProductosUnicos AS (
		SELECT 
			name,
			price, 
			reference_price,  
			reference_unit,  
			date, 
			category 
		FROM #TempProducto t
		WHERE t.id = (
			SELECT MAX(id)
			FROM #TempProducto
			WHERE name = t.name
		)
	)

	INSERT INTO Producto.Producto (nombre, precio, precioReferencia, unidadReferencia, fecha, idCategoriaProducto)
	SELECT 
		t.name,
		t.price,
		t.reference_price,
		t.reference_unit,
		t.date,
		(SELECT idCategoriaProducto
			FROM Producto.CategoriaProducto
			WHERE nombre COLLATE Modern_Spanish_CI_AS = t.category COLLATE Modern_Spanish_CI_AS)
	FROM ProductosUnicos t
	WHERE NOT EXISTS (
		SELECT 1
		FROM Producto.Producto p
		WHERE p.nombre COLLATE Modern_Spanish_CI_AS = t.name COLLATE Modern_Spanish_CI_AS
	);


    -- Limpiar la tabla temporal
    DROP TABLE #TempProducto;
END;
GO


-- Electronic accesories.xlsx
CREATE OR ALTER PROCEDURE Producto.ImportarProductosElectronica (@RutaArchivo NVARCHAR(1024))
AS
BEGIN
	--Seteo palabras clave por categoria, para poder agrupar los productos de forma automatica.
	CREATE TABLE #PalabrasClavePorCategoria(
		idCategoria INT,
		palabrasClave VARCHAR(255) COLLATE Modern_Spanish_CI_AS

	);
	INSERT INTO #PalabrasClavePorCategoria(idCategoria, palabrasClave)
	SELECT 
		cp.idCategoriaProducto, 
		'Laptop' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Laptop'

	UNION ALL

	SELECT 
		cp.idCategoriaProducto, 
		'LG' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Electrodoméstico'

	UNION ALL

	SELECT 
		cp.idCategoriaProducto, 
		'Charging,Cable' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Cargador'

	UNION ALL

	SELECT 
		cp.idCategoriaProducto, 
		'AA,AAA' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Batería'

	UNION ALL

	SELECT 
		cp.idCategoriaProducto, 
		'Monitor' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Monitor'

	UNION ALL

	SELECT 
		cp.idCategoriaProducto, 
		'Headphones' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Auricular'

	UNION ALL

	SELECT 
		cp.idCategoriaProducto, 
		'Phone,iPhone' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Teléfono'

	UNION ALL

	SELECT 
		cp.idCategoriaProducto, 
		'TV' AS palabrasClave
	FROM Producto.CategoriaProducto cp
	WHERE cp.nombre = 'Televisor';


	-- Carga de productos en tabla temporal
	CREATE TABLE #ProductosTemporales (
		Producto VARCHAR(255) COLLATE Modern_Spanish_CI_AS,
		Precio DECIMAL(10,2)
	);

	DECLARE @CotizacionUSDActual DECIMAL(10,2);
	EXEC Sistema.ObtenerCotizacionUSD @CotizacionUSDActual OUTPUT;
	
	IF @CotizacionUSDActual IS NOT NULL
	BEGIN
		DECLARE @SQL NVARCHAR(MAX) = '
		INSERT INTO #ProductosTemporales (Producto, Precio)
		SELECT 
		[Product], 
		[Precio Unitario en dolares] 
		FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES; IMEX=1;'',
				''SELECT [Product], [Precio Unitario en dolares] FROM [Sheet1$]'');
		';

		EXEC sp_executesql @SQL;

		-- Actualizar productos existentes
		UPDATE p
		SET 
			p.precio = t.Precio * @CotizacionUSDActual,
			p.idCategoriaProducto = c.idCategoria
		FROM Producto.Producto p
		JOIN #ProductosTemporales t ON p.nombre = t.Producto
		CROSS APPLY (
			SELECT TOP 1 idCategoria
			FROM #PalabrasClavePorCategoria p
			WHERE EXISTS (
				SELECT 1 FROM STRING_SPLIT(p.palabrasClave, ',') s
				WHERE CHARINDEX(s.value, t.Producto) > 0
			)
			ORDER BY LEN(p.palabrasClave) DESC
		) c;

		-- Insertar productos nuevos
		WITH ProductosUnicos AS (
		SELECT 
			Producto, 
			AVG(Precio) Precio  
		FROM #ProductosTemporales
		GROUP BY Producto
		)

		INSERT INTO Producto.Producto (nombre, precio, idCategoriaProducto)
		SELECT 
			t.Producto,
			t.Precio * @CotizacionUSDActual,  -- Convertimos el precio a la moneda local
			c.idCategoria
		FROM ProductosUnicos t
		CROSS APPLY (
			SELECT TOP 1 idCategoria
			FROM #PalabrasClavePorCategoria p
			WHERE EXISTS (
				SELECT 1 FROM STRING_SPLIT(p.palabrasClave, ',') s
				WHERE CHARINDEX(s.value, t.Producto) > 0
			)
			ORDER BY LEN(p.palabrasClave) DESC
		) c
		WHERE NOT EXISTS (
			SELECT 1 FROM Producto.Producto p WHERE p.nombre = t.Producto
		);


		PRINT 'El archivo Excel es válido y los datos fueron cargados correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error al obtener valor del dolar', 16, 1);
	END;

	DROP TABLE #PalabrasClavePorCategoria;
END;
GO


-- Productos_importados.xlsx
CREATE OR ALTER PROCEDURE Producto.ImportarProductosImportados(@RutaArchivo NVARCHAR(1024))
AS
BEGIN
	-- Crear tabla temporal para leer el archivo
    CREATE TABLE #tempProductoImportado (
		idProducto INT,
		NombreProducto VARCHAR(255) COLLATE Modern_Spanish_CI_AS,
		Categoría VARCHAR(100) COLLATE Modern_Spanish_CI_AS,
		CantidadPorUnidad VARCHAR(100) COLLATE Modern_Spanish_CI_AS,
		PrecioUnidad DECIMAL(10,2)
    );

    DECLARE @Consulta NVARCHAR(2048) = '
        INSERT INTO #tempProductoImportado (idProducto, NombreProducto, Categoría, CantidadPorUnidad, PrecioUnidad)
        SELECT idProducto, NombreProducto, Categoría, CantidadPorUnidad, PrecioUnidad
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @RutaArchivo + ''',
            ''SELECT [idProducto], [NombreProducto], [Categoría], [CantidadPorUnidad], [PrecioUnidad] FROM [Listado de Productos$]''
        )';
  
	EXEC sp_executesql @Consulta;

	-- Crear linea de producto Importado si no existe
	IF NOT EXISTS (SELECT 1 FROM Producto.LineaProducto WHERE nombre = 'Importado')
    BEGIN
        INSERT INTO Producto.LineaProducto (nombre) VALUES ('Importado');
    END

	-- Obtener el ID de la linea de producto
	DECLARE @idLineaProducto INT;
    SELECT @idLineaProducto = idLineaProducto FROM Producto.LineaProducto WHERE nombre = 'Importado';

	-- Insertar nuevas categorías si no existen
    INSERT INTO Producto.CategoriaProducto (nombre, idLineaProducto)
    SELECT DISTINCT t.Categoría, @idLineaProducto
    FROM #tempProductoImportado t
    WHERE NOT EXISTS (
        SELECT 1 FROM Producto.CategoriaProducto c WHERE c.nombre = t.Categoría
    );

	-- Actualizar productos que ya existen
    UPDATE p
    SET 
        p.precio = t.PrecioUnidad,
        p.descripcionUnidad = t.CantidadPorUnidad,
        p.idCategoriaProducto = c.idCategoriaProducto
    FROM Producto.Producto p
    INNER JOIN #tempProductoImportado t ON p.nombre = t.NombreProducto
    INNER JOIN Producto.CategoriaProducto c ON t.Categoría = c.nombre;

    -- Insertar productos que no existen
	WITH ProductosUnicos AS (
        SELECT 
            NombreProducto, 
            Categoría, 
            CantidadPorUnidad, 
            PrecioUnidad
			FROM #tempProductoImportado t
			WHERE t.idProducto = (
				SELECT MAX(idProducto)
				FROM #tempProductoImportado
				WHERE NombreProducto = t.NombreProducto
			)
    )
    
    INSERT INTO Producto.Producto (nombre, precio, descripcionUnidad, idCategoriaProducto)
    SELECT t.NombreProducto, t.PrecioUnidad, t.CantidadPorUnidad, c.idCategoriaProducto
    FROM ProductosUnicos t
    INNER JOIN Producto.CategoriaProducto c ON t.Categoría = c.nombre
    WHERE NOT EXISTS (
        SELECT 1 FROM Producto.Producto p WHERE p.nombre = t.NombreProducto
    )


    DROP TABLE #tempProductoImportado;
END;
GO

CREATE OR ALTER PROCEDURE Producto.ImportarProductos
	@RutaArchivo NVARCHAR(1024),
	@RutaDirectorio NVARCHAR(1024)
AS
BEGIN
	BEGIN TRY
		-- Iniciar transacción
		BEGIN TRANSACTION;
		
			-- Establecer nombre de catalogos
			CREATE TABLE #TempNombreProductos (
				id INT IDENTITY(1,1) PRIMARY KEY,
				Productos VARCHAR(100)
			);

			-- Comando para importar datos desde el archivo Excel
			DECLARE @CargaDatosArchivo NVARCHAR(MAX) = 
			'INSERT INTO #TempNombreProductos (Productos)
			SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
									''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES; IMEX=1;'', 
									''SELECT * FROM [catalogo$]'');';

			EXEC sp_executesql @CargaDatosArchivo;


			-- Verificar los datos importados
			IF NOT EXISTS (SELECT 1 FROM #TempNombreProductos)
			BEGIN
				RAISERROR('El archivo Excel no contiene datos en la hoja [catalogo$].', 16, 1);
			END

			-- Declarar variables para almacenar los valores extraídos
			DECLARE @ProductosElectronica VARCHAR(100),
					@ProductosCatalogo VARCHAR(100),
					@ProductosImportados VARCHAR(100);

			PRINT @ProductosElectronica
			-- Extraer los valores de la tabla temporal
			SELECT 
			@ProductosElectronica = (SELECT Productos FROM #TempNombreProductos WHERE Id = 2),
			@ProductosCatalogo = (SELECT Productos FROM #TempNombreProductos WHERE Id = 1),
			@ProductosImportados = (SELECT Productos FROM #TempNombreProductos WHERE Id = 3);

			-- Eliminar la tabla temporal
			DROP TABLE #TempNombreProductos;

			-- Verificar que los valores se asignaron correctamente
			IF @ProductosElectronica IS NULL OR @ProductosCatalogo IS NULL OR @ProductosImportados IS NULL
			BEGIN
				RAISERROR('No se pudieron extraer correctamente los valores del Excel. ', 16, 1)
				RETURN;
			END

			-- Establecer ruta de catalogos
			DECLARE @RutaProductosCatalogo NVARCHAR(1024)
			DECLARE @RutaProductosElectronica NVARCHAR(1024)
			DECLARE @RutaProductosImportados NVARCHAR(1024)

			SET @RutaProductosCatalogo = @RutaDirectorio + @ProductosElectronica
			SET @RutaProductosElectronica = @RutaDirectorio + @ProductosCatalogo
			SET @RutaProductosImportados = @RutaDirectorio + @ProductosImportados
			
			-- Importar productos con la ruta ya establecida.
			EXEC Producto.ImportarCatalogo @RutaProductosCatalogo;
			EXEC Producto.ImportarProductosElectronica @RutaProductosElectronica;
			EXEC Producto.ImportarProductosImportados  @RutaProductosImportados;


		-- Confirmar transacción si todo fue exitoso
		COMMIT TRANSACTION;

		-- Mostrar mensaje de éxito
		PRINT 'El archivo Excel es válido y los datos fueron cargados correctamente.';
	END TRY

	BEGIN CATCH
		-- Revertir la transacción si ocurre un error
		ROLLBACK TRANSACTION;

		-- Mostrar mensaje de error
		PRINT 'No se cargaron los datos, se ha producido un error: ' + ERROR_MESSAGE();
	END CATCH;

END;
GO


---------------------------------------------------------------------
-- VENTAS --

-- Se asume que este archivo no vendrá con ventas previamente cargadas en archivos anteriores. 
-- Es decir, si una factura ya está registrada en la base de datos, 
-- el sistema evitará insertar la venta nuevamente, saltándose aquellas filas que ya estén registradas.
CREATE OR ALTER PROCEDURE Venta.ImportarVentas
    @RutaArchivo VARCHAR(1024)
AS
BEGIN
    -- Tabla temporal para almacenar los datos importados
    CREATE TABLE #DatosVentas (
        idFactura VARCHAR(11) COLLATE Modern_Spanish_CI_AS NOT NULL, --Factura.idFactura
        tipoFactura CHAR COLLATE Modern_Spanish_CI_AS NOT NULL, --Factura.tipoFactura
        ciudad VARCHAR(50) COLLATE Modern_Spanish_CI_AS NOT NULL, --Sucursal.ciudad
        tipoCliente CHAR(6) COLLATE Modern_Spanish_CI_AS NOT NULL, --Cliente.tipoCliente
        genero CHAR(6) COLLATE Modern_Spanish_CI_AS NOT NULL, --Cliente.genero
        producto VARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL, --Producto.nombre
        precioUnitario DECIMAL(10,2) NOT NULL, --DetalleVenta.precioUnitarioAlMomentoDeLaVenta
        cantidad INT NOT NULL, --DetalleVenta.cantidad
        fecha DATE NOT NULL, --Venta.fecha --Factura.fecha
        hora TIME NOT NULL, --Venta.hora --Factura.hora
        medioPago VARCHAR(30) COLLATE Modern_Spanish_CI_AS NOT NULL, --MetodoPago.nombre
        empleado INT NOT NULL, --Empleado.legajoEmpleado
        identificadorPago VARCHAR(30) COLLATE Modern_Spanish_CI_AS NOT NULL --Venta.identificadorPago
    );

   BEGIN TRY
        -- Construir la sentencia BULK INSERT dinámicamente
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            BULK INSERT #DatosVentas
            FROM ''' + @RutaArchivo + '''
            WITH (
                FIELDTERMINATOR = '';'',  -- Especifica el delimitador de campo (coma en un archivo CSV)
                ROWTERMINATOR = ''\n'',   -- Especifica el terminador de fila (salto de línea en un archivo CSV)
                CODEPAGE = ''65001''        -- Especifica la página de códigos del archivo
            );';

        -- Ejecutar la consulta dinámica
		EXEC sp_executesql @SQL;


		UPDATE #DatosVentas
		SET producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              producto, 'Ã¡', 'á'), 
              'Ã©', 'é'), 
              'Ã­', 'í'), 
              'Ã³', 'ó'), 
              'Ãº', 'ú'), 
              'Ã±', 'ñ'), 
              'Ã‘', 'Ñ');

        PRINT 'Los datos fueron importados correctamente desde el archivo CSV.';
    END TRY
    BEGIN CATCH
        -- Capturar errores
        RAISERROR (
            'Error: No se pudo importar el archivo CSV.',
            16,
            1
        );
        THROW;
    END CATCH;

	-- Inserto venta solo si no existe
	INSERT INTO Venta.Venta(nroFactura, tipoFactura, estado, total, fecha, hora, idCliente, idMetodoPago, identificadorPago, legajoEmpleado, idSucursal)
	SELECT D.idFactura, D.tipoFactura, 'P', SUM(D.precioUnitario * D.cantidad), D.fecha, D.hora, C.idCliente, M.idMetodoPago, 
	CASE 
        WHEN D.identificadorPago = '--' THEN NULL 
        ELSE D.identificadorPago 
    END AS identificadorPago,
	D.empleado, E.idSucursal
	FROM #DatosVentas D
	JOIN Cliente.Cliente C ON C.genero = D.genero AND C.tipoCliente = D.tipoCliente
	JOIN Venta.MetodoPago M ON M.nombre = D.medioPago
	JOIN Empleado.Empleado E ON E.legajoEmpleado = D.empleado
	WHERE NOT EXISTS (
				SELECT 1 FROM Venta.Venta V
				WHERE V.nroFactura = D.idFactura
			)
    GROUP BY D.idFactura, D.tipoFactura, D.fecha, D.hora, C.idCliente, M.idMetodoPago, D.identificadorPago, D.empleado, E.idSucursal


	-- Inserto detalles de venta solo si no existen
	INSERT INTO Venta.DetalleVenta(idVenta, idProducto, cantidad, precioUnitarioAlMomentoDeLaVenta, subtotal)
	SELECT 
		V.idVenta, 
		P.idProducto, 
		D.cantidad, 
		D.precioUnitario, 
		D.precioUnitario * D.cantidad AS subtotal
	FROM #DatosVentas D
	JOIN Producto.Producto P ON P.nombre = D.producto
	JOIN Venta.Venta V ON V.nroFactura = D.idFactura
	WHERE NOT EXISTS (
		SELECT 1 
		FROM Venta.DetalleVenta DV
		WHERE DV.idVenta = V.idVenta AND DV.idProducto = P.idProducto
	);


    -- Limpiar la tabla temporal
    DROP TABLE #DatosVentas;
END;
GO


---------------------------------------------------------------------
-- ARCHIVOS --

CREATE OR ALTER PROCEDURE Sistema.ImportarArchivoa
	@RutaInformacion VARCHAR(1024),
	@RutaVentas VARCHAR(1024),
	@DirectorioProductos VARCHAR(1024)
AS
BEGIN
	EXEC Sucursal.ImportarSucursales @RutaInformacion;
	EXEC Venta.ImportarMetodosDePago @RutaInformacion;
	EXEC Empleado.ImportarEmpleados @RutaInformacion;
	EXEC Producto.ImportarClasificacionProductos @RutaInformacion;
	EXEC Producto.ImportarProductos @RutaInformacion, @DirectorioProductos;
	EXEC Venta.ImportarVentas @RutaVentas;
END;
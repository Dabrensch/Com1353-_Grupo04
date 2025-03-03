---------------------------------------------------------------------
-- Fecha de entrega: 28/02/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Importe toda la información de los archivos a la base de datos

---------------------------------------------------------------------
USE Com1353G04
GO


---------------------------------------------------------------------
-- SE DEBE EJECUTAR PRIMERO LAS PRE IMPORTACIONES

/*
	Antes de realizar cualquier accion se necesita el componente OleDB:
	La descarga se realiza desde el siguiente enlace: https://www.microsoft.com/en-us/download/details.aspx?id=54920
	Es importanto seleccionar la version correcta (32 o 64 bits) según la versión de SQL Server instalada
	Una vez instalado se debe reinciar el servicio de SQL Server
*/

-- Habilitar opciones avanzadas y consultas distribuidas
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO

-- Ejecutar pre importaciones
EXEC Sistema.BorrarTodo
GO
EXEC Cliente.ImportarCliente
GO

---------------------------------------------------------------------
--Seteo de ruta para importar archivo

DECLARE @RutaInformacion NVARCHAR(1024),
@RutaVentas NVARCHAR(1024),
@DirectorioProductos NVARCHAR(1024);

--AGREGAR DIRECTORIO DE LOS ARCHIVOS DE PRODUCTOS Y RUTA DE LOS OTROS ARCHIVOS
-- EJEMPLO: 
   -- 'C:/Usuarios/javier/TP_integrador_Archivos/Informacion_complementaria.xlsx'
   -- 'C:/Usuarios/javier/TP_integrador_Archivos/Ventas_registradas.csv'
   -- 'C:/Usuarios/javier/TP_integrador_Archivos/Productos/'
-- IMPORTANTE QUE TERMINE CON '/'

--|
--|
--|
--↓
SET @RutaInformacion = 'C:/Users/Brenda/OneDrive - Enta Consulting/Escritorio/grupo04-main/grupo04/TP_integrador_Archivos/Informacion_complementaria.xlsx';
SET @RutaVentas = 'C:/Users/Brenda/OneDrive - Enta Consulting/Escritorio/grupo04-main/grupo04/TP_integrador_Archivos/Ventas_registradas.csv';
SET @DirectorioProductos = 'C:/Users/Brenda/OneDrive - Enta Consulting/Escritorio/grupo04-main/grupo04/TP_integrador_Archivos/Productos/';
--↑
--|
--|
--|

--EN CASO DE QUE SE HAYA OLVIDADO EL '/' AL FINAL
SET @DirectorioProductos = 
    CASE 
        WHEN RIGHT(@DirectorioProductos, 1) = '/' THEN @DirectorioProductos
        ELSE @DirectorioProductos + '/' 
    END;


EXEC Sucursal.ImportarSucursales @RutaInformacion;
EXEC Venta.ImportarMetodosDePago @RutaInformacion;
EXEC Empleado.ImportarEmpleados @RutaInformacion;
EXEC Producto.ImportarClasificacionProductos @RutaInformacion;
EXEC Producto.ImportarProductos @RutaInformacion, @DirectorioProductos;
EXEC Venta.ImportarVentas @RutaVentas;


-- Mostrar resultados
SELECT * FROM Sucursal.Sucursal
SELECT * FROM Venta.MetodoPago
EXEC Empleado.ObtenerEmpleado;
SELECT * FROM Producto.LineaProducto
SELECT * FROM Producto.CategoriaProducto
SELECT * FROM Producto.Producto
SELECT * FROM Cliente.Cliente
SELECT * FROM Venta.Venta
SELECT * FROM Venta.DetalleVenta



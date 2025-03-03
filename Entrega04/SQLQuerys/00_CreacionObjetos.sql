---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Cree la base de datos, entidades y relaciones. Incluya restricciones y claves.

---------------------------------------------------------------------
-- Crear base de datos si no existe

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Com1353G04')
BEGIN
    CREATE DATABASE Com1353G04 COLLATE Modern_Spanish_CI_AS
END
GO

---------------------------------------------------------------------
-- Crear schemas si no existen
USE Com1353G04
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Venta')
    EXEC('CREATE SCHEMA Venta');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Producto')
    EXEC('CREATE SCHEMA Producto');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Empleado')
    EXEC('CREATE SCHEMA Empleado');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Cliente')
    EXEC('CREATE SCHEMA Cliente');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Sucursal')
    EXEC('CREATE SCHEMA Sucursal');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Reporte')
    EXEC('CREATE SCHEMA Reporte');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Sistema')
    EXEC('CREATE SCHEMA Sistema');
GO

-- La instrucción CREATE SCHEMA no se puede ejecutar directamente en un bloque condicional. 
-- Por eso, se usa EXEC para ejecutar una cadena dinámica que contiene la instrucción CREATE SCHEMA.

---------------------------------------------------------------------
-- Borrar tablas si ya existen

IF OBJECT_ID('Venta.NotaDeCredito', 'U') IS NOT NULL DROP TABLE Venta.NotaDeCredito
IF OBJECT_ID('Venta.DetalleVenta', 'U') IS NOT NULL DROP TABLE Venta.DetalleVenta
IF OBJECT_ID('Venta.Venta', 'U') IS NOT NULL DROP TABLE Venta.Venta
IF OBJECT_ID('Venta.MetodoPago', 'U') IS NOT NULL DROP TABLE Venta.MetodoPago
IF OBJECT_ID('Empleado.Empleado', 'U') IS NOT NULL DROP TABLE Empleado.Empleado
IF OBJECT_ID('Sucursal.Sucursal', 'U') IS NOT NULL DROP TABLE Sucursal.Sucursal
IF OBJECT_ID('Cliente.Cliente', 'U') IS NOT NULL DROP TABLE Cliente.Cliente
IF OBJECT_ID('Producto.Producto', 'U') IS NOT NULL DROP TABLE Producto.Producto
IF OBJECT_ID('Producto.CategoriaProducto', 'U') IS NOT NULL DROP TABLE Producto.CategoriaProducto
IF OBJECT_ID('Producto.LineaProducto', 'U') IS NOT NULL DROP TABLE Producto.LineaProducto
GO

---------------------------------------------------------------------
-- Crear tablas

CREATE TABLE Producto.LineaProducto (
	idLineaProducto INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL UNIQUE,
	estado BIT NOT NULL DEFAULT 1
)
GO

CREATE TABLE Producto.CategoriaProducto (
	idCategoriaProducto INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL UNIQUE,
	idLineaProducto INT NOT NULL REFERENCES Producto.LineaProducto(idLineaProducto),
	estado BIT NOT NULL DEFAULT 1
)
GO

CREATE TABLE Producto.Producto (
	idProducto INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL UNIQUE,
	precio DECIMAL(10,2) NOT NULL,     -- Tiene que estar en pesos
	precioReferencia DECIMAL(10,2), -- catalogo.csv
	unidadReferencia VARCHAR(10),		-- catalogo.csv
	fecha DATETIME,						-- catalogo.csv
	descripcionUnidad varchar(50),   -- productos_importados.xlsx
	idCategoriaProducto INT NOT NULL REFERENCES Producto.CategoriaProducto(idCategoriaProducto),
	estado BIT NOT NULL DEFAULT 1
)
GO

CREATE TABLE Cliente.Cliente (
	idCliente INT IDENTITY(1,1) PRIMARY KEY,
	cuil CHAR(13) NOT NULL UNIQUE,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	telefono CHAR(10) NOT NULL,
	genero CHAR(6) NOT NULL CHECK(genero IN ('Female','Male')),  
	tipoCliente CHAR(6) NOT NULL CHECK(tipoCliente IN ('Normal','Member')) 
)
GO

CREATE TABLE Sucursal.Sucursal (
	idSucursal INT IDENTITY(1,1) PRIMARY KEY,
	ciudad VARCHAR(50) NOT NULL,
	sucursal VARCHAR(50) NOT NULL UNIQUE,
	direccion VARCHAR(100) NOT NULL,
	telefono CHAR(10) NOT NULL,
	horario CHAR(50) NOT NULL,
	estado BIT NOT NULL DEFAULT 1
)
GO

CREATE TABLE Empleado.Empleado (
	legajoEmpleado INT PRIMARY KEY, --IDENTITY BORRADO
	cuil CHAR(13) NOT NULL,
	nombre VARCHAR(30) NOT NULL,
	apellido VARCHAR(30) NOT NULL,
	direccion VARCHAR(100) NOT NULL,
	emailPersonal varchar(70) NOT NULL, --VARCHAR AMPLIADO
	emailEmpresa varchar(70) NOT NULL, --VARCHAR AMPLIADO
	turno varchar(16) NOT NULL, 
	cargo varchar(30) NOT NULL,
	fechaAlta DATE NOT NULL,
	fechaBaja DATE,
	idSucursal INT REFERENCES Sucursal.Sucursal(idSucursal),

	CONSTRAINT CHK_Empleado_Turno CHECK(turno IN ('TM', 'TT', 'Jornada Completa')),
    CONSTRAINT UNIQUE_Empleado_Cuil UNIQUE (cuil),
)
GO

CREATE TABLE Venta.MetodoPago (
	idMetodoPago INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(30) NOT NULL UNIQUE, -- Credit card (Tarjeta de credito) - Cash (Efectivo) - Ewallet (Billetera Electronica)
	estado BIT NOT NULL DEFAULT 1
)
GO

CREATE TABLE Venta.Venta (
	idVenta INT IDENTITY(1,1) PRIMARY KEY,
	nroFactura CHAR(11) NOT NULL UNIQUE,
	tipoFactura CHAR NOT NULL CHECK(tipoFactura IN ('A','B','C')),
	estado CHAR NOT NULL CHECK(estado IN ('E','P','C')),  -- Emitida-Pagada-Cancelada,
	fecha DATE NOT NULL,
	hora TIME NOT NULL,
	total DECIMAL(10,2) NOT NULL,
	identificadorPago VARCHAR(30),
	legajoEmpleado INT NOT NULL REFERENCES Empleado.Empleado(legajoEmpleado),
	idSucursal INT NOT NULL REFERENCES Sucursal.Sucursal(idSucursal),
	idCliente INT NOT NULL REFERENCES Cliente.Cliente(idCliente),
	idMetodoPago INT NOT NULL REFERENCES Venta.MetodoPago(idMetodoPago)
)
GO

CREATE TABLE Venta.DetalleVenta (
    idDetalleVenta INT IDENTITY(1,1) PRIMARY KEY, 
    idVenta INT NOT NULL REFERENCES Venta.Venta(idVenta),
    idProducto INT NOT NULL REFERENCES Producto.Producto(idProducto),
    cantidad INT NOT NULL,
    precioUnitarioAlMomentoDeLaVenta DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
)
GO

---------------------------------------------------------------------
-- Crear tabla nota de credito

CREATE TABLE Venta.NotaDeCredito(
	IdNotaDeCredito INT IDENTITY (1,1) PRIMARY KEY,
	idDetalleVenta INT NOT NULL REFERENCES Venta.DetalleVenta(idDetalleVenta),
	comprobante CHAR(8) NOT NULL,
	motivo VARCHAR(150) NOT NULL,
	fecha DATE NOT NULL,
	hora TIME NOT NULL,

	idProductoCambio INT REFERENCES Producto.Producto(idProducto),
	monto DECIMAL(10,2),
	cantidad INT NOT NULL
)
GO





---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Ejecutar pre importaciones

---------------------------------------------------------------------
USE Com1353G04
GO

---------------------------------------------------------------------
-- IMPORTANTE
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
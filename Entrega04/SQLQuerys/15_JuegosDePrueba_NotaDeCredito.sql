---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Realizar los juegos de prueba de nota de credito para la devolucion de un producto

---------------------------------------------------------------------
USE Com1353G04
GO

---------------------------------------------------------------------

-- Pre-Juegos de prueba
EXEC Sistema.CrearRoles

EXEC Sistema.BorrarTodo

DECLARE @idVentaGenerada INT;
EXEC Producto.InsertarLineaProducto 'Electr�nica';
EXEC Producto.InsertarCategoriaProducto 'Celulares', 1;
EXEC Producto.InsertarProducto 'iPhone 13', 1000, 1100, 'UN', '2024-06-01 12:06:00', '1 unidad', 1;
EXEC Producto.InsertarProducto 'iPhone 12', 1000, 1100, 'UN', '2024-06-01 12:06:00', '1 unidad', 1;
EXEC Cliente.InsertarCliente '30-12345678-5', 'Juan', 'P�rez', '1122334455', 'Male', 'Member';
EXEC Sucursal.InsertarSucursal 'Buenos Aires', 'Sucursal Centro', 'Av. 9 de Julio 1234', '1122334455', '9 a 18';
EXEC Empleado.InsertarEmpleado 1, '30-12345678-6', 'Laura', 'M�ndez', 'Calle Falsa 123', 'laura@gmail.com', 'laura@empresa.com', 'TM', 'Vendedora', '2024-01-01', 1;
EXEC Venta.InsertarMetodoPago 'Tarjeta de cr�dito';
EXEC Venta.InsertarVenta '222-22-2222', 'A', 'P', '2025-01-10', '12:30', 1200.50, 'AAA', 1, 1, 1, 1, @idVentaGenerada OUTPUT;
EXEC Venta.InsertarDetalleVenta @idVentaGenerada, 1, 2, 45;
EXEC Venta.InsertarDetalleVenta @idVentaGenerada, 2, 3, 35;
EXEC Venta.InsertarVenta '333-33-3333', 'A', 'E', '2025-01-10', '12:30', 1200.50, 'AAA', 1, 1, 1, 1, @idVentaGenerada OUTPUT;
EXEC Venta.InsertarDetalleVenta @idVentaGenerada, 1, 4, 35;




-------------------------- NOTA DE CREDITO ------------------------  

--Para conectarse como usuario_supervisor o usuario_empleado se deben seguir estos pasos:
/*
	1. Acceder a las propiedades del Servidor. 
		a. Conectase al Servidor y seleccionar Properties del Servidor, en Object Explorer.
		b. Ir a Security
		c. Seleccionar SQL Server and Windows Authentication Mode
	2. Cuando nos conectamos a un Servidor debemos:
		a. Especificar la base de datos a la que me voy a conectar. 
		b. En la pesta�a Connection Properties -> Connect to Database: Com1353G04
		c. Una vez hecho esto, debemos ir a Additional Connection Parameters -> TrustServerCertificate=True
	3. Ya puede conectarse con el usuario y contrase�a correctos.
		a. Podra conectase usando usuario_supervisor o usuario_empleado
		b. Se debe seleccionar el metodo de autenticacion SQL Server Authentication e ingresar correctamente el usuario y contrase�a.

	Usuario			User						Password
	Supervisor		usuario_supervisor			contrase�aSupervisor
	Empleado		usuario_empleado			contrase�aEmpleado

*/

-- Si no se ha conectado al usuario_supervisor los siguientes juegos de prueba van a tener el mismo resultado: "No tiene permisos para generar una nota de cr�dito."
-- Debe conectarse al usuario_supervisor para realizar los juegos de prueba.

-- Prueba 1: Nota de credito valida (monto)
-- Resultado esperado: idNotaDeCredito = 1, idDetalleVenta = 1, motivo = 'Da�ado', idProductoCambio = NULL, monto = 90 (45*2), cantidad = 2
EXEC Venta.GenerarNotaDeCredito 1, 2, 'Da�ado', 0;
SELECT * FROM Venta.NotaDeCredito WHERE IdNotaDeCredito = 1

-- Prueba 2: Detalle de venta inexistente
-- Resultado esperado: Error: "No existe un detalle de venta con el ID especificado."
EXEC Venta.GenerarNotaDeCredito 9999, 1, 'Da�ado', 0;

-- Prueba 3: Factura no pagada
-- Resultado esperado: Error: "No se puede generar una nota de cr�dito porque la factura no est� pagada."
EXEC Venta.GenerarNotaDeCredito 3, 1, 'Da�ado', 0;

-- Prueba 4: Motivo vacio
-- Resultado esperado: Error: "El motivo no puede estar vac�o."
EXEC Venta.GenerarNotaDeCredito 2, 1, ' ', 0;

-- Prueba 5: Cantidad menor o igual a 0
-- Resultado esperado: Error: "La cantidad debe ser mayor a 0."
EXEC Venta.GenerarNotaDeCredito 2, -1, 'Da�ado', 0;

-- Prueba 6: Cantidad mayor a cantidad vendida
-- Resultado esperado: Error: "La cantidad a devolver supera la cantidad vendida."
EXEC Venta.GenerarNotaDeCredito 1, 20, 'Da�ado', 0;

-- Prueba 7: Suma de cantidad de las notas de credito mayor a cantidad vendida
-- Resultado esperado: Error: "La cantidad a devolver junto con notas de cr�dito previas supera la cantidad vendida. "
EXEC Venta.GenerarNotaDeCredito 1, 1, 'Da�ado', 0;

-- Prueba 8: Nota de credito valida (producto)
-- Resultado esperado: idNotaDeCredito = 2, idDetalleVenta = 2, motivo = 'El celular no prende', idProductoCambio = 2, monto = NULL, cantidad = 2
EXEC Venta.GenerarNotaDeCredito 2, 2, 'El celular no prende', 1;
SELECT * FROM Venta.NotaDeCredito WHERE IdNotaDeCredito = 2

-- Prueba 9: Nota de credito valida (producto con una NC ya generada)
-- Resultado esperado: idNotaDeCredito = 2, idDetalleVenta = 2, motivo = 'El celular no prende', idProductoCambio = 2, monto = NULL, cantidad = 1
EXEC Venta.GenerarNotaDeCredito 2, 1, 'El celular se apaga', 1;
SELECT * FROM Venta.NotaDeCredito WHERE IdNotaDeCredito = 3
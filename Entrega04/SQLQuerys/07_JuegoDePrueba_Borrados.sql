---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Realice los juegos de prueba de los SP de borrados logicos y la reactivación
-- Para el correcto funcionamiento de las pruebas se deben realizar en orden y con la ejecucion previa de los juegos de prueba de las actualizaciones

---------------------------------------------------------------------
USE Com1353G04
GO

------------------------- BORRADOS LOGICOS --------------------------  

---------------------------------------------------------------------
-- PRODUCTO --

-- Prueba 1: Borrar un producto existente.
-- Inicial: estado = 1
-- Esperado: estado = 0
SELECT idProducto, estado FROM Producto.Producto WHERE idProducto = 1
EXEC Producto.BorrarProducto 1;
SELECT idProducto, estado FROM Producto.Producto WHERE idProducto = 1

-- Prueba 2: Borrar un producto no existente.
-- Esperado: Error: "No existe un producto con el ID especificado."
EXEC Producto.BorrarProducto 99;


---------------------------------------------------------------------
-- CATEGORIA DE PRODUCTO --

-- Se realiza borrado en cascada de los productos asociados, usando transacciones para mantener la consistencia

-- Prueba 1: Borrar una categoria de producto existente.
-- Inicial: estadoCategoria = 1 ; estadoProducto = 1
-- Esperado: estadoCategoria = 0 ; estadoProducto = 0
SELECT C.idCategoriaProducto, C.estado AS estadoCategoria, P.idProducto, P.estado AS estadoProducto FROM Producto.CategoriaProducto C JOIN Producto.Producto P ON C.idCategoriaProducto = P.idCategoriaProducto WHERE C.idCategoriaProducto = 2
EXEC Producto.BorrarCategoriaProducto 2;
SELECT C.idCategoriaProducto, C.estado AS estadoCategoria, P.idProducto, P.estado AS estadoProducto FROM Producto.CategoriaProducto C JOIN Producto.Producto P ON C.idCategoriaProducto = P.idCategoriaProducto WHERE C.idCategoriaProducto = 2

-- Prueba 2: Borrar una categoria de producto no existente.
-- Esperado: Error: "No existe una categoria de producto con el ID especificado."
EXEC Producto.BorrarCategoriaProducto 99;


---------------------------------------------------------------------
-- LINEA DE PRODUCTO --

-- Se realiza borrado en cascada de las categorias asociadas y por ende de los productos asociados, usando transacciones para mantener la consistencia

-- Prueba 1: Borrar una linea de producto existente.
-- Inicial: estadoLineaProducto = 1 ; estadoCategoria = 1 ; estadoProducto = 1
-- Esperado: estadoLineaProducto = 0 ; estadoCategoria = 0 ; estadoProducto = 0
SELECT L.idLineaProducto, L.estado, C.idCategoriaProducto, C.estado, P.idProducto, P.estado FROM Producto.LineaProducto L JOIN Producto.CategoriaProducto C ON L.idLineaProducto = C.idLineaProducto JOIN Producto.Producto P ON C.idCategoriaProducto = P.idCategoriaProducto WHERE L.idLineaProducto = 1 AND P.idProducto = 3
EXEC Producto.BorrarLineaProducto 1;
SELECT L.idLineaProducto, L.estado, C.idCategoriaProducto, C.estado, P.idProducto, P.estado FROM Producto.LineaProducto L JOIN Producto.CategoriaProducto C ON L.idLineaProducto = C.idLineaProducto JOIN Producto.Producto P ON C.idCategoriaProducto = P.idCategoriaProducto WHERE L.idLineaProducto = 1 AND P.idProducto = 3

-- Prueba 2: Borrar una linea de producto no existente.
-- Esperado: Error: "No existe una linea de producto con el ID especificado."
EXEC Producto.BorrarLineaProducto 99;


---------------------------------------------------------------------
-- EMPLEADO --

-- Prueba 1: Borrar un empleado existente.
-- Inicial: fechaBaja = NULL
-- Esperado: fechaBaja = (Fecha actual)
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.BorrarEmpleado 1;
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 2: Borrar un empleado no existente.
-- Esperado: Error: "No existe un empleado con el ID especificado."
EXEC dbEmpleado.BorrarEmpleado 99;


---------------------------------------------------------------------
-- SUCURSAL --

-- Se des asignan a los empleados de esa sucursal, para que los puedan re ubicar en un futuro, o se asignan a una sucursal diferente al momento del borrado
-- El parametro @idSucursalNueva no es obligatorio, por lo tanto, si no se manda ese parametros los empleados quedaran sin sucursal asignada

-- Prueba 1: Borrar una sucursal existente y asignar nueva sucursal.
-- Inicial: estadoSucursal = 1 ; idSucursalDeEmpleado = 2
-- Esperado: estadoSucursal = 0 ; idSucursalDeEmpleado = 1
SELECT S.idSucursal, S.estado AS estadoSucursal, E.legajoEmpleado, E.idSucursal AS idSucursalDeEmpleado FROM Sucursal.Sucursal S JOIN Empleado.Empleado E ON S.idSucursal = E.idSucursal WHERE S.idSucursal = 2
EXEC Sucursal.BorrarSucursal 2, 1;
SELECT idSucursal, estado AS estadoSucursal FROM Sucursal.Sucursal WHERE idSucursal = 2
EXEC Empleado.ObtenerEmpleado 2
EXEC Empleado.ObtenerEmpleado 3

-- Prueba 2: Borrar una sucursal no existente.
-- Esperado: Error: "No existe una sucursal con el ID especificado."
EXEC Sucursal.BorrarSucursal 99;

-- Prueba 3: Asignar una sucursal no existente.
-- Esperado: Error: "No existe una sucursal nueva con el ID especificado."
EXEC Sucursal.BorrarSucursal 1, 99;

-- Prueba 4: Asignar sucursal nueva igual a la borrada.
-- Esperado: Error: "La sucursal nueva no puede ser la sucursal que desea borrar."
EXEC Sucursal.BorrarSucursal 1, 1;

-- Prueba 5: Asignar sucursal nueva inactiva.
-- Esperado: Error: "La sucursal nueva esta inactiva."
EXEC Sucursal.BorrarSucursal 1, 2;

-- Prueba 6: Borrar una sucursal existente, sin asignar nueva sucursal.
-- Inicial: estadoSucursal = 1 ; idSucursalDeEmpleado = 1
-- Esperado: estadoSucursal = 0 ; idSucursalDeEmpleado = NULL
SELECT S.idSucursal, S.estado AS estadoSucursal, E.legajoEmpleado, E.idSucursal AS idSucursalDeEmpleado FROM Sucursal.Sucursal S JOIN Empleado.Empleado E ON S.idSucursal = E.idSucursal WHERE S.idSucursal = 1
EXEC Sucursal.BorrarSucursal 1;
SELECT idSucursal, estado AS estadoSucursal FROM Sucursal.Sucursal WHERE idSucursal = 1
EXEC Empleado.ObtenerEmpleado 1
EXEC Empleado.ObtenerEmpleado 2
EXEC Empleado.ObtenerEmpleado 3


---------------------------------------------------------------------
-- METODO DE PAGO --

-- Prueba 1: Borrar un medodo de pago existente.
-- Inicial: estado = 1
-- Esperado: estado = 0
SELECT idMetodoPago, estado FROM Venta.MetodoPago WHERE idMetodoPago = 1
EXEC Venta.BorrarMetodoPago 1;
SELECT idMetodoPago, estado FROM Venta.MetodoPago WHERE idMetodoPago = 1

-- Prueba 2: Borrar un medodo de pago no existente.
-- Esperado: Error: "No existe un metodo de pago con el ID especificado."
EXEC Venta.BorrarMetodoPago 99;


------------------------- REACTIVACIONES --------------------------  

---------------------------------------------------------------------
-- PRODUCTO, CATEGORIA Y LINEA --

-- Prueba 1: Intentar reactivar un producto con una categoria desactivada.
-- Esperado: Error: "La categoria asociada a este producto está desactivada. Primero debe activar la categoria."
EXEC Producto.ReactivarProducto 2;

-- Prueba 2: Intentar reactivar una categoría con una linea desactivada.
-- Esperado: Error: "La linea asociada a esta categoria está desactivada. Primero debe activar la linea."
EXEC Producto.ReactivarCategoriaProducto 2;

-- Prueba 3: Reactivar una línea de producto borrada.
-- Inicial: estado = 0
-- Esperado: estado = 1
SELECT idLineaProducto, estado FROM Producto.LineaProducto WHERE idLineaProducto = 1
EXEC Producto.ReactivarLineaProducto 1;
SELECT idLineaProducto, estado FROM Producto.LineaProducto WHERE idLineaProducto = 1

-- Prueba 4: Reactivar una categoría de producto borrada.
-- Inicial: estadoCategoria = 0
-- Esperado: estadoCategoria = 1
SELECT idCategoriaProducto, estado FROM Producto.CategoriaProducto WHERE idCategoriaProducto = 2
EXEC Producto.ReactivarCategoriaProducto 2;
SELECT idCategoriaProducto, estado FROM Producto.CategoriaProducto WHERE idCategoriaProducto = 2

-- Prueba 5: Reactivar un producto borrado.
-- Inicial: estado = 0
-- Esperado: estado = 1
SELECT idProducto, estado FROM Producto.Producto WHERE idProducto = 2
EXEC Producto.ReactivarProducto 2;
SELECT idProducto, estado FROM Producto.Producto WHERE idProducto = 2

-- Prueba 6: Intentar reactivar un producto que no existe.
-- Esperado: Error: "No existe un producto con el ID especificado."
EXEC Producto.ReactivarProducto 99;

-- Prueba 7: Intentar reactivar una categoría de producto que no existe.
-- Esperado: Error: "No existe una categoria de producto con el ID especificado."
EXEC Producto.ReactivarCategoriaProducto 99;

-- Prueba 8: Intentar reactivar una línea de producto que no existe.
-- Esperado: Error: "No existe una linea de producto con el ID especificado."
EXEC Producto.ReactivarLineaProducto 99;


---------------------------------------------------------------------
-- EMPLEADO --

-- Prueba 1: Reactivar un empleado borrado.
-- Inicial: fechaBaja no es NULL
-- Esperado: fechaBaja = NULL
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.ReactivarEmpleado 1;
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 2: Intentar reactivar un empleado que no existe.
-- Esperado: Error: "No existe un empleado con el ID especificado."
EXEC Empleado.ReactivarEmpleado 99;


---------------------------------------------------------------------
-- SUCURSAL --

-- Prueba 1: Reactivar una sucursal borrada.
-- Inicial: estado = 0
-- Esperado: estado = 1
SELECT idSucursal, estado FROM Sucursal.Sucursal WHERE idSucursal = 2
EXEC Sucursal.ReactivarSucursal 2;
SELECT idSucursal, estado FROM Sucursal.Sucursal WHERE idSucursal = 2

-- Prueba 2: Intentar reactivar una sucursal que no existe.
-- Esperado: Error: "No existe una sucursal con el ID especificado."
EXEC Sucursal.ReactivarSucursal 99;


---------------------------------------------------------------------
-- METODO DE PAGO --

-- Prueba 1: Reactivar un método de pago borrado.
-- Inicial: estado = 0
-- Esperado: estado = 1
SELECT idMetodoPago, estado FROM Venta.MetodoPago WHERE idMetodoPago = 1
EXEC Venta.ReactivarMetodoPago 1;
SELECT idMetodoPago, estado FROM Venta.MetodoPago WHERE idMetodoPago = 1

-- Prueba 2: Intentar reactivar un método de pago que no existe.
-- Esperado: Error: "No existe un metodo de pago con el ID especificado."
EXEC Venta.ReactivarMetodoPago 99;
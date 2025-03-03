---------------------------------------------------------------------
-- Fecha de entrega: 28/02/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557
   -- Turri, Teo Francis 42819058

---------------------------------------------------------------------
-- Consigna: Realice los juegos de prueba de los SP de actualizaciones
-- Para el correcto funcionamiento de las pruebas se deben realizar en orden y con la ejecucion previa de los juegos de prueba de las inserciones

---------------------------------------------------------------------
USE Com1353G04
GO

-------------------------- ACTUALIZACIONES --------------------------

---------------------------------------------------------------------
-- CATEGORIA DE PRODUCTO --

-- Prueba 1: Actualizar nombre.
-- Inicial: nombre = 'Celulares'
-- Esperado: nombre = 'Tablets'
SELECT * FROM Producto.CategoriaProducto WHERE idCategoriaProducto = 1
EXEC Producto.ActualizarCategoriaProducto @idCategoriaProducto = 1, @nombre = 'Tablets';
SELECT * FROM Producto.CategoriaProducto WHERE idCategoriaProducto = 1

-- Prueba 2: Intentar actualizar nombre invalido.
-- Esperado: Error: "El nombre no puede estar vacío."
EXEC Producto.ActualizarCategoriaProducto @idCategoriaProducto = 1, @nombre = '    ';

-- Prueba 3: Intentar actualizar una categoria de producto no existente.
-- Esperado: Error: "No existe una categoria de producto con el ID especificado."
EXEC Producto.ActualizarCategoriaProducto @idCategoriaProducto = 99, @nombre = 'Tablets';


---------------------------------------------------------------------
-- LINEA DE PRODUCTO --

-- Prueba 1: Actualizar nombre.
-- Inicial: nombre = 'Electronica'
-- Esperado: nombre = 'Tecnologia'
SELECT * FROM Producto.LineaProducto WHERE idLineaProducto = 1
EXEC Producto.ActualizarLineaProducto @idLineaProducto = 1, @nombre = 'Tecnologia';
SELECT * FROM Producto.LineaProducto WHERE idLineaProducto = 1

-- Prueba 2: Intentar actualizar nombre invalido.
-- Esperado: Error: "El nombre no puede estar vacío."
EXEC Producto.ActualizarLineaProducto @idLineaProducto = 1, @nombre = '    ';

-- Prueba 3: Intentar actualizar una linea de producto no existente.
-- Esperado: Error: "No existe una linea de producto con el ID especificado."
EXEC Producto.ActualizarLineaProducto @idLineaProducto = 99, @nombre = 'Tecnologia';


---------------------------------------------------------------------
-- PRODUCTO --

-- Prueba 1: Actualizar nombre.
-- Inicial: nombre = 'Auriculares inalambricos'
-- Esperado: nombre = 'Auriculares de casco'
SELECT * FROM Producto.Producto WHERE idProducto = 2
EXEC Producto.ActualizarProducto @idProducto = 2, @nombre = 'Auriculares de casco';
SELECT * FROM Producto.Producto WHERE idProducto = 2

-- Prueba 2: Intentar actualizar nombre invalido.
-- Esperado: Error: "El nombre no puede estar vacío."
SELECT * FROM Producto.Producto WHERE idProducto = 2
EXEC Producto.ActualizarProducto @idProducto = 2, @nombre = '   ';
SELECT * FROM Producto.Producto WHERE idProducto = 2

-- Prueba 3: Intentar actualizar una linea de producto no existente.
-- Esperado: Error: "No existe un producto con el ID especificado."
EXEC Producto.ActualizarProducto @idProducto = 99, @nombre = 'Auriculares de casco';


---------------------------------------------------------------------
-- CLIENTE --

-- Prueba 1: Actualizar cuil.
-- Inicial: cuil = '30-12345678-5'
-- Esperado: cuil = '20-12345678-5'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1
EXEC Cliente.ActualizarCliente @idCliente = 1, @cuil = '20-12345678-5'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1

-- Prueba 2: Actualizar nombre.
-- Inicial: nombre = 'Juan'
-- Esperado: nombre = 'Antonio'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1
EXEC Cliente.ActualizarCliente @idCliente = 1, @nombre = 'Antonio'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1

-- Prueba 3: Actualizar apellido.
-- Inicial: apellido = 'Pérez'
-- Esperado: apellido = 'Schereik'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1
EXEC Cliente.ActualizarCliente @idCliente = 1, @apellido = 'Schereik'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1

-- Prueba 4: Actualizar telefono.
-- Inicial: telefono = '1122334455'
-- Esperado: telefono = '1111111111'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1
EXEC Cliente.ActualizarCliente @idCliente = 1, @telefono = '1111111111'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1

-- Prueba 5: Actualizar genero.
-- Inicial: genero = 'Male'
-- Esperado: genero = 'Female'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1
EXEC Cliente.ActualizarCliente @idCliente = 1, @genero = 'Female'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1

-- Prueba 6: Actualizar tipoCliente.
-- Inicial: tipoCliente = 'Member'
-- Esperado: tipoCliente = 'Normal'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1
EXEC Cliente.ActualizarCliente @idCliente = 1, @tipoCliente = 'Normal'
SELECT * FROM Cliente.Cliente WHERE idCliente = 1

-- Prueba 7: Actualizar todos los campos.
-- Inicial: Los campos esperados
-- Esperado: Los campos iniciales
SELECT * FROM Cliente.Cliente WHERE idCliente = 1
EXEC Cliente.ActualizarCliente @idCliente = 1, @cuil = '30-12345678-5', @nombre = 'Juan', @apellido = 'Pérez', @telefono = '1122334455', @genero = 'Male', @tipoCliente = 'Member';
SELECT * FROM Cliente.Cliente WHERE idCliente = 1

-- Prueba 8: Intentar actualizar cuil invalido.
-- Esperado: Error: "El CUIL es inválido. "
EXEC Cliente.ActualizarCliente @idCliente = 1, @cuil = '205'

-- Prueba 9: Intentar actualizar nombre invalido.
-- Esperado: Error: "El nombre no puede estar vacío. "
EXEC Cliente.ActualizarCliente @idCliente = 1, @nombre = '  '

-- Prueba 10: Intentar actualizar apellido invalido.
-- Esperado: Error: "El apellido no puede estar vacío."
EXEC Cliente.ActualizarCliente @idCliente = 1, @apellido = '  '

-- Prueba 11: Intentar actualizar telefono invalido.
-- Esperado: Error: "El teléfono no puede estar vacío."
EXEC Cliente.ActualizarCliente @idCliente = 1, @telefono = ' '

-- Prueba 12: Intentar actualizar genero invalido (fuera de las opciones).
-- Esperado: Error: "El género debe ser Female o Male."
EXEC Cliente.ActualizarCliente @idCliente = 1, @genero = 'Mujer'

-- Prueba 13: Intentar actualizar tipoCliente invalido (fuera de las opciones).
-- Esperado: Error: "El tipo de cliente debe ser Member o Normal."
EXEC Cliente.ActualizarCliente @idCliente = 1, @tipoCliente = 'Premium'

-- Prueba 14: Intentar actualizar un cliente no existente.
-- Esperado: Error: "No existe un cliente con el ID especificado."
EXEC Cliente.ActualizarCliente @idCliente = 99, @tipoCliente = 'Normal'


---------------------------------------------------------------------
-- SUCURSAL --

-- Prueba 1: Actualizar ciudad.
-- Inicial: ciudad = 'Buenos Aires'
-- Esperado: ciudad = 'Cordoba'
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @ciudad = 'Cordoba';
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1

-- Prueba 2: Actualizar sucursal.
-- Inicial: sucursal = 'Sucursal Centro'
-- Esperado: sucursal = 'Sucursal Norte'
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @sucursal = 'Sucursal Norte';
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1

-- Prueba 3: Actualizar direccion.
-- Inicial: direccion = 'Av. 9 de Julio 1234'
-- Esperado: direccion = 'Calle cordobeza 1234'
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @direccion = 'Calle cordobeza 1234';
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1

-- Prueba 4: Actualizar telefono.
-- Inicial: telefono = '1122334455'
-- Esperado: telefono = '1111111111'
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @telefono = '1111111111';
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1

-- Prueba 5: Actualizar horario.
-- Inicial: horario = '9 a 18'
-- Esperado: horario = '12 a 18'
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @horario = '12 a 18';
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1

-- Prueba 6: Actualizar todos los campos.
-- Inicial: Los campos esperados
-- Esperado: Los campos iniciales
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @ciudad = 'Buenos Aires', @sucursal = 'Sucursal Centro', @direccion = 'Av. 9 de Julio 1234', @telefono = '1122334455', @horario = '9 a 18';
SELECT * FROM Sucursal.Sucursal WHERE idSucursal = 1

-- Prueba 7: Intentar actualizar ciudad invalida.
-- Esperado: Error: "La ciudad no puede estar vacía."
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @ciudad = '   ';

-- Prueba 8: Intentar actualizar sucursal invalida.
-- Inicial: Error: "La sucursal no puede estar vacía."
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @sucursal = '    ';

-- Prueba 9: Intentar actualizar direccion invalida.
-- Inicial: Error: "La dirección no puede estar vacía."
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @direccion = ' ';

-- Prueba 10: Intentar actualizar telefono invalido.
-- Inicial: Error: "El telefono no puede estar vacio."
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @telefono = ' ';

-- Prueba 11: Intentar actualizar horario invalido.
-- Inicial: Error: "El horario no puede estar vacío."
EXEC Sucursal.ActualizarSucursal @idSucursal = 1, @horario = ' ';

-- Prueba 12: Intentar actualizar una sucursal no existente.
-- Esperado: Error: "No existe una sucursal con el ID especificado."
EXEC Sucursal.ActualizarSucursal @idSucursal = 99, @horario = '12 a 18';


---------------------------------------------------------------------
-- EMPLEADO --

-- Prueba 1: Actualizar cuil.
-- Inicial: cuil = '30-12345678-6'
-- Esperado: cuil = '27-12345678-6'
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 1, @cuil = '27-12345678-6'
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 2: Actualizar nombre.
-- Inicial: nombre = 'Laura'
-- Esperado: nombre = 'Romina'
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 1, @nombre = 'Romina'
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 3: Actualizar apellido.
-- Inicial: apellido = 'Méndez'
-- Esperado: apellido = 'Schereik'
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 1, @apellido = 'Schereik'
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 4: Actualizar email.
-- Inicial: emailPersonal = 'laura@gmail.com', emailEmpresa = 'laura@empresa.com'
-- Esperado: emailPersonal = 'romina@gmail.com', emailEmpresa = 'romina@empresa.com'
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 1, @emailPersonal = 'romina@gmail.com', @emailEmpresa = 'romina@empresa.com';
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 5: Actualizar turno.
-- Inicial: turno = 'TM'
-- Esperado: turno = 'TT'
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 1, @turno = 'TT'
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 6: Actualizar todos los campos.
-- Inicial: Campos iniciales.
-- Esperado: Campos esperados.
EXEC Empleado.ObtenerEmpleado 1;
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 1, @cuil = '30-12345678-6', @nombre = 'Laura', @apellido = 'Méndez', @emailPersonal = 'laura@gmail.com', @emailEmpresa = 'laura@empresa.com', @turno = 'TM';
EXEC Empleado.ObtenerEmpleado 1;

-- Prueba 7: Intentar actualizar turno invalido (no esta en las opciones).
-- Esperado: Error = "El turno debe ser TM, TT o Jornada completa."
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 1, @turno = 'Tarde'

-- Prueba 8: Intentar actualizar una empleado no existente.
-- Esperado: Error: "No existe un empleado con el legajo especificado."
EXEC Empleado.ActualizarEmpleado @legajoEmpleado = 99, @turno = 'TT'


---------------------------------------------------------------------
-- METODO DE PAGO --

-- Prueba 1: Actualizar nombre.
-- Inicial: nombre = 'Tarjeta de credito'
-- Esperado: nombre = 'Cash'
SELECT * FROM Venta.MetodoPago WHERE idMetodoPago = 1
EXEC Venta.ActualizarMetodoPago 1, 'Cash';
SELECT * FROM Venta.MetodoPago WHERE idMetodoPago = 1

-- Prueba 2: Intentar actualizar nombre invalido.
-- Esperado: Error: "El nombre no puede estar vacío."
EXEC Venta.ActualizarMetodoPago 1, '   ';

-- Prueba 3: Intentar actualizar metodo de pago inexistente.
-- Esperado: Error: "No existe un método de pago con el ID especificado."
EXEC Venta.ActualizarMetodoPago 99, 'Cash';


---------------------------------------------------------------------
-- VENTA --

-- Prueba 1: Actualizar todos los campos
-- Inicial: nroFactura = '222-22-2222', tipoFactura = 'A', estado = 'E', fecha = '2025-01-10', hora = '12:30:00.0000000', total = 1200.50, identificadorPago = 'AAA'
-- Esperado: nroFactura = '111-11-1111', tipoFactura = 'B', estado = 'P', fecha = '2025-02-20', hora = '08:45:00.0000000', total = 1.25, identificadorPago = 'BBB'
SELECT * FROM Venta.Venta
EXEC Venta.ActualizarVenta @idVenta = 1, @fecha = '2025-02-20', @hora = '08:45:00.0000000', @identificadorPago = 'BBB', @nroFactura = '111-11-1111', @tipoFactura = 'B', @estado = 'P', @total = 1.25;
SELECT * FROM Venta.Venta

-- Prueba 2: Intentar actualizar una venta inexistente.
-- Esperado: Error: "No existe una venta con el ID especificado."
EXEC Venta.ActualizarVenta @idVenta = 99, @fecha = '2025-02-20';

-- Prueba 3: Intentar actualizar un empleado inexistente.
-- Esperado: Error: "No existe un empleado con el ID especificado."
EXEC Venta.ActualizarVenta @idVenta = 1, @legajoEmpleado = 99;

-- Prueba 4: Intentar actualizar una sucursal inexistente.
-- Esperado: Error: "No existe una sucursal con el ID especificado."
EXEC Venta.ActualizarVenta @idVenta = 1, @idSucursal = 99;

-- Prueba 5: Intentar actualizar un metodo de pago inexistente.
-- Esperado: Error: "No existe un metodo de pago con el ID especificado."
EXEC Venta.ActualizarVenta @idVenta = 1, @idMetodoPago = 99;

-- Prueba 6: Intentar actualizar tipoFactura invalida (fuera de las opciones)
-- Esperado: Error: "El tipo de factura debe ser A, B o C."
EXEC Venta.ActualizarVenta @idVenta = 1, @tipoFactura = 'X';

-- Prueba 7: Intentar actualizar estado invalido (fuera de las opciones)
-- Esperado: Error: "El estado debe ser E, P o C."
EXEC Venta.ActualizarVenta @idVenta = 1, @estado = 'X';

-- Prueba 8: Intentar actualizar total invalido (negativo)
-- Esperado: Error: "El total debe ser mayor a 0. "
EXEC Venta.ActualizarVenta @idVenta = 1, @total = -1;


---------------------------------------------------------------------
-- DETALLE VENTA --

-- Prueba 1: Actualizar todos los campos
-- Inicial: cantidad = 1, precioUnitarioAlMomentoDeLaVenta = 1, subtotal = 1
-- Esperado: cantidad = 2, precioUnitarioAlMomentoDeLaVenta = 5, subtotal = 10
SELECT * FROM Venta.DetalleVenta
EXEC Venta.ActualizarDetalleVenta @idDetalleVenta = 1, @cantidad = 2, @precioUnitarioAlMomentoDeLaVenta = 5, @subtotal = 10;
SELECT * FROM Venta.DetalleVenta

-- Prueba 2: Intentar actualizar cantidad invalida (negativo)
-- Esperado: Error= "La cantidad debe ser mayor a 0."
EXEC Venta.ActualizarDetalleVenta @idDetalleVenta = 1, @cantidad = -2;

-- Prueba 3: Intentar actualizar precioUnitarioAlMomentoDeLaVenta invalida (negativo)
-- Esperado: Error= "El precio unitario debe ser mayor a 0."
EXEC Venta.ActualizarDetalleVenta @idDetalleVenta = 1, @precioUnitarioAlMomentoDeLaVenta = -2;

-- Prueba 3: Intentar actualizar precioUnitarioAlMomentoDeLaVenta invalida (negativo)
-- Esperado: Error= "El subtotal debe ser mayor a 0."
EXEC Venta.ActualizarDetalleVenta @idDetalleVenta = 1, @subtotal = -2;

-- Prueba 5: Intentar actualizar un detalle de venta no existente
-- Esperado: Error: "No existe un detalle de venta con el ID especificado."
EXEC Venta.ActualizarDetalleVenta @idDetalleVenta = 99, @cantidad = 2;

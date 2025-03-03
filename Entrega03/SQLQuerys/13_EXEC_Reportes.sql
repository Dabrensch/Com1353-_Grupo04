---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Ejecutar reportes en xml

---------------------------------------------------------------------
USE Com1353G04
GO

---------------------------------------------------------------------
-- Mensual: ingresando un mes y año determinado mostrar el total facturado por días de la semana, incluyendo sábado y domingo.
EXEC Reporte.TotalFacturadoPorDiaMensual '1', '2019';

-- Trimestral: mostrar el total facturado por turnos de trabajo por mes.
EXEC Reporte.TotalFacturadoPorTurnoTrimestral '1', '2019';

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
EXEC Reporte.CantidadProductosVendidosPorRangoFechas '2019-01-01', '2019-12-24';

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor.
EXEC Reporte.CantidadProductosVendidosPorRangoFechasSucursal '2019-01-01', '2019-12-24';

-- Mostrar los 5 productos más vendidos en un mes, por semana
EXEC Reporte.ProductosMasVendidosPorSemana '1', '2019';

-- Mostrar los 5 productos menos vendidos en el mes.
EXEC Reporte.ProductosMenosVendidosPorMes '1', '2019';

-- Mostrar total acumulado de ventas (o sea también mostrar el detalle) para una fecha y sucursal particulares
EXEC Reporte.TotalAcumuladoVentasPorSucursal '2019-01-01', 'San Justo';

-- Mensual: ingresando un mes y año determinado mostrar el vendedor de mayor monto facturado por sucursal.
EXEC Reporte.VendedorMayorTotalFacturadoPorSucursal '1', '2019';

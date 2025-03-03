---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Generar reportes en xml

---------------------------------------------------------------------
USE Com1353G04
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Reporte')
    EXEC('CREATE SCHEMA Reporte');
GO


---------------------------------------------------------------------
-- Mensual: ingresando un mes y año determinado mostrar el total facturado por días de la semana, incluyendo sábado y domingo.
CREATE OR ALTER PROCEDURE Reporte.TotalFacturadoPorDiaMensual
	@mes INT, 
	@anio INT
AS
BEGIN
	WITH FacturacionPorDia AS (
        SELECT 
            DATENAME(WEEKDAY, fecha) AS Dia,
            DATEPART(WEEKDAY, fecha) AS DiaNumero,
            SUM(total) AS TotalFacturado
        FROM Venta.Venta
        WHERE MONTH(fecha) = @mes AND YEAR(fecha) = @anio
        GROUP BY DATENAME(WEEKDAY, fecha), DATEPART(WEEKDAY, fecha)
    )
    SELECT Dia, TotalFacturado
    FROM FacturacionPorDia
    ORDER BY DiaNumero
	FOR XML PATH('Facturacion'), ROOT('ReporteFacturacionMensual'), TYPE;
END;
GO


---------------------------------------------------------------------
-- Trimestral: mostrar el total facturado por turnos de trabajo por mes.
CREATE OR ALTER PROCEDURE Reporte.TotalFacturadoPorTurnoTrimestral
    @trimestre INT,
    @anio INT
AS
BEGIN
	DECLARE @mesInicio INT = ((@trimestre - 1) * 3) + 1;
    DECLARE @mesFin INT = @trimestre * 3;

	WITH FacturacionPorTurno AS (
        SELECT 
            DATENAME(MONTH, V.fecha) AS Mes,
            E.turno AS Turno, 
            SUM(V.total) AS TotalFacturado
        FROM Venta.Venta V
        INNER JOIN Empleado.Empleado E ON V.legajoEmpleado = E.legajoEmpleado
        WHERE YEAR(V.fecha) = @anio AND MONTH(V.fecha) BETWEEN @mesInicio AND @mesFin
        GROUP BY DATENAME(MONTH, V.fecha), E.turno
    )
    SELECT Mes, Turno, TotalFacturado
    FROM FacturacionPorTurno
    FOR XML PATH('Facturacion'), ROOT('ReporteFacturacionTrimestral');
END;
GO


---------------------------------------------------------------------
-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
CREATE OR ALTER PROCEDURE Reporte.CantidadProductosVendidosPorRangoFechas
    @fechaInicio DATE,
    @fechaFin DATE
AS
BEGIN
	WITH ProductosVendidos AS (
        SELECT 
            P.nombre AS Producto,
            SUM(DV.cantidad) AS CantidadVendida
        FROM Venta.Venta V
        INNER JOIN Venta.DetalleVenta DV ON V.idVenta = DV.idVenta
        INNER JOIN Producto.Producto P ON DV.idProducto = P.idProducto
        WHERE V.fecha BETWEEN @fechaInicio AND @fechaFin
        GROUP BY P.nombre
    )
    SELECT Producto, CantidadVendida
    FROM ProductosVendidos
    ORDER BY CantidadVendida DESC
    FOR XML PATH('ProductoVendido'), ROOT('ReporteProductosVendidos');
END;
GO


---------------------------------------------------------------------
-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor.
CREATE OR ALTER PROCEDURE Reporte.CantidadProductosVendidosPorRangoFechasSucursal
    @fechaInicio DATE,
    @fechaFin DATE
AS
BEGIN
	WITH VentasPorSucursal AS (
        SELECT 
            S.sucursal AS Sucursal,
            SUM(DV.cantidad) AS CantidadVendida
        FROM Venta.Venta V
        INNER JOIN Venta.DetalleVenta DV ON V.idVenta = DV.idVenta
        INNER JOIN Empleado.Empleado E ON V.legajoEmpleado = E.legajoEmpleado
        INNER JOIN Sucursal.Sucursal S ON E.idSucursal = S.idSucursal
        WHERE V.fecha BETWEEN @fechaInicio AND @fechaFin
        GROUP BY S.sucursal
    )
    SELECT Sucursal, CantidadVendida
    FROM VentasPorSucursal
    ORDER BY CantidadVendida DESC
    FOR XML PATH('ProductosVendidos'), ROOT('ReporteVentasPorSucursal');
END;
GO


---------------------------------------------------------------------
-- Mostrar los 5 productos más vendidos en un mes, por semana
CREATE OR ALTER PROCEDURE Reporte.ProductosMasVendidosPorSemana
    @mes INT,
    @anio INT
AS
BEGIN
    WITH VentasPorSemana AS (
        SELECT 
            DATEPART(WEEK, V.fecha) AS Semana,
            P.nombre AS Producto,
            SUM(DV.cantidad) AS TotalCantidad,
            ROW_NUMBER() OVER (PARTITION BY DATEPART(WEEK, V.fecha) ORDER BY SUM(DV.cantidad) DESC) AS rn
        FROM Venta.Venta V
        INNER JOIN Venta.DetalleVenta DV ON V.idVenta = DV.idVenta
        INNER JOIN Producto.Producto P ON DV.idProducto = P.idProducto
        WHERE MONTH(V.fecha) = @mes AND YEAR(V.fecha) = @anio
        GROUP BY DATEPART(WEEK, V.fecha), P.nombre
    )
    SELECT Semana, Producto, TotalCantidad
    FROM VentasPorSemana
    WHERE rn <= 5
    ORDER BY Semana, TotalCantidad DESC
    FOR XML PATH('Ventas'), ROOT('ReporteProductosMasVendidosPorSemana');
END;
GO


---------------------------------------------------------------------
-- Mostrar los 5 productos menos vendidos en el mes.
CREATE OR ALTER PROCEDURE Reporte.ProductosMenosVendidosPorMes
    @mes INT,
    @anio INT
AS
BEGIN
    -- CTE para agrupar las ventas por producto y cantidad vendida en el mes
    WITH ProductosPorMes AS (
        SELECT P.nombre AS Producto, SUM(DV.cantidad) AS CantidadVendida
        FROM Venta.Venta V
        INNER JOIN Venta.DetalleVenta DV ON V.idVenta = DV.idVenta
        INNER JOIN Producto.Producto P ON DV.idProducto = P.idProducto
        WHERE YEAR(V.fecha) = @anio AND MONTH(V.fecha) = @mes
        GROUP BY P.nombre
    )
    -- Seleccionar los 5 productos menos vendidos, ordenados por cantidad vendida ascendente
    SELECT TOP 5 * FROM ProductosPorMes
    ORDER BY CantidadVendida ASC
    FOR XML PATH('Ventas'), ROOT('ReporteProductosMenosVendidos'), TYPE
END;
GO


---------------------------------------------------------------------
-- Mostrar total acumulado de ventas (o sea también mostrar el detalle) para una fecha y sucursal particulares
CREATE OR ALTER PROCEDURE Reporte.TotalAcumuladoVentasPorSucursal
    @fecha DATE,
    @sucursal VARCHAR(50)
AS
BEGIN
    WITH VentasSucursal AS (
        SELECT 
            s.sucursal AS Sucursal,
            v.fecha AS Fecha,
            SUM(v.total) AS TotalFacturado
        FROM Venta.Venta v
        JOIN Empleado.Empleado e ON v.legajoEmpleado = e.legajoEmpleado
        JOIN Sucursal.Sucursal s ON e.idSucursal = s.idSucursal
        WHERE v.fecha = @fecha AND s.sucursal = @sucursal
        GROUP BY s.sucursal, v.fecha
    )
    SELECT * FROM VentasSucursal
	FOR XML PATH('Ventas'), ROOT('ReporteAcumuladoFechaSucursal'), TYPE
END;
GO


---------------------------------------------------------------------
-- Mensual: ingresando un mes y año determinado mostrar el vendedor de mayor monto facturado por sucursal.
CREATE OR ALTER PROCEDURE Reporte.VendedorMayorTotalFacturadoPorSucursal
	@mes INT, 
	@anio INT
AS
BEGIN
	WITH VentasFiltradas AS (
        SELECT E.legajoEmpleado AS Empleado, S.idSucursal, S.sucursal AS Sucursal, SUM(V.total) AS Total
        FROM Venta.Venta V
		JOIN Empleado.Empleado E ON V.legajoEmpleado = E.legajoEmpleado
        JOIN Sucursal.Sucursal S ON E.idSucursal = S.idSucursal
		WHERE YEAR(V.fecha) = @anio AND MONTH(V.fecha) = @mes
        GROUP BY E.legajoEmpleado, S.idSucursal, S.sucursal
	),
	MaxPorSucursal AS (
        SELECT idSucursal, MAX(Total) AS MaxFacturacion
        FROM VentasFiltradas
        GROUP BY idSucursal
    )

	SELECT Empleado, Sucursal, Total
    FROM VentasFiltradas VF
	JOIN MaxPorSucursal MPS ON VF.idSucursal = MPS.idSucursal AND VF.Total = MPS.MaxFacturacion
    FOR XML PATH('Facturacion'), ROOT('ReporteMayorMontoSucursal'), TYPE
END
GO


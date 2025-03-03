---------------------------------------------------------------------
-- Fecha de entrega: 05/03/2025
-- Materia: Base de Datos Aplicada
-- Comision: 1353
-- Numero de grupo: 04
-- Integrantes:
   -- Schereik, Brenda 45128557

---------------------------------------------------------------------
-- Consigna: Encripte los datos de los empleados

---------------------------------------------------------------------
USE Com1353G04
GO
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Crear una llave maestra, certificado y llave simetrica para encriptar la tabla dbEmpleado.Empleado


IF NOT EXISTS (SELECT * FROM sys.key_encryptions)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'boca123';
GO

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'CertificadoEmpleado')
CREATE CERTIFICATE CertificadoEmpleado
    WITH SUBJECT = 'Certificado para encriptar datos de Empleados';
GO

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'EmpleadoLlave')
CREATE SYMMETRIC KEY EmpleadoLlave
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertificadoEmpleado;
GO


---------------------------------------------------------------------
-- Alterar la tabla dbEmpleado.Empleado para que permita encriptar sus datos con las restricciones adecuadas.

ALTER TABLE Empleado.Empleado 
ADD 
    nombreEncriptado VARBINARY(MAX),
    apellidoEncriptado VARBINARY(MAX),
    direccionEncriptada VARBINARY(MAX),
    emailPersonalEncriptado VARBINARY(MAX),
    emailEmpresaEncriptado VARBINARY(MAX),
    cargoEncriptado VARBINARY(MAX),
    fechaAltaEncriptada VARBINARY(MAX),
    fechaBajaEncriptada VARBINARY(MAX);
GO

ALTER TABLE Empleado.Empleado 
ADD 
    cuilHash VARBINARY(32), -- No puedo usar la restricción: UNIQUE usando ENCRYPTBYKEY(), ya que cada vez que 
                            -- encripte los datos, me devolverá un valor distinto, aunque el texto original sea el mismo.

    cuilEncriptado VARBINARY(MAX)  -- Debe tener la restricción UNIQUE (agregada al final)
GO

ALTER TABLE Empleado.Empleado DROP CONSTRAINT UNIQUE_Empleado_Cuil;
GO

ALTER TABLE Empleado.Empleado 
DROP COLUMN cuil, nombre, apellido, direccion, emailPersonal, emailEmpresa, cargo, fechaAlta, fechaBaja;
GO

EXEC sp_rename 'Empleado.Empleado.cuilEncriptado', 'cuil', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.nombreEncriptado', 'nombre', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.apellidoEncriptado', 'apellido', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.direccionEncriptada', 'direccion', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.emailPersonalEncriptado', 'emailPersonal', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.emailEmpresaEncriptado', 'emailEmpresa', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.cargoEncriptado', 'cargo', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.fechaAltaEncriptada', 'fechaAlta', 'COLUMN';
EXEC sp_rename 'Empleado.Empleado.fechaBajaEncriptada', 'fechaBaja', 'COLUMN';
GO

ALTER TABLE Empleado.Empleado 
ADD CONSTRAINT UNIQUE_Empleado_Cuil UNIQUE (cuilHash);
GO


---------------------------------------------------------------------
-- Obtener empleados encriptados

CREATE OR ALTER PROCEDURE Empleado.ObtenerEmpleado
	@legajoEmpleado INT = NULL
AS
BEGIN
    OPEN SYMMETRIC KEY EmpleadoLlave
        DECRYPTION BY CERTIFICATE CertificadoEmpleado;
 
	IF @legajoEmpleado IS NULL
	BEGIN
		SELECT
			legajoEmpleado,
			CONVERT(CHAR(13), DECRYPTBYKEY(cuil)) AS cuil,  
			CONVERT(VARCHAR(30), DECRYPTBYKEY(nombre)) AS nombre,
			CONVERT(VARCHAR(30), DECRYPTBYKEY(apellido)) AS apellido,
			CONVERT(VARCHAR(100), DECRYPTBYKEY(direccion)) AS direccion,
			CONVERT(VARCHAR(70), DECRYPTBYKEY(emailPersonal)) AS emailPersonal,
			CONVERT(VARCHAR(70), DECRYPTBYKEY(emailEmpresa)) AS emailEmpresa,
			turno,
			CONVERT(VARCHAR(30), DECRYPTBYKEY(cargo)) AS cargo,
			CONVERT(DATE, CONVERT(VARCHAR(10), DECRYPTBYKEY(fechaAlta))) AS fechaAlta,
			CONVERT(DATE, CONVERT(VARCHAR(10), DECRYPTBYKEY(fechaBaja))) AS fechaBaja,
			idSucursal
		FROM Empleado.Empleado
	END
	ELSE
	BEGIN
		SELECT
			legajoEmpleado,
			CONVERT(CHAR(13), DECRYPTBYKEY(cuil)) AS cuil,  
			CONVERT(VARCHAR(30), DECRYPTBYKEY(nombre)) AS nombre,
			CONVERT(VARCHAR(30), DECRYPTBYKEY(apellido)) AS apellido,
			CONVERT(VARCHAR(100), DECRYPTBYKEY(direccion)) AS direccion,
			CONVERT(VARCHAR(70), DECRYPTBYKEY(emailPersonal)) AS emailPersonal,
			CONVERT(VARCHAR(70), DECRYPTBYKEY(emailEmpresa)) AS emailEmpresa,
			turno,
			CONVERT(VARCHAR(30), DECRYPTBYKEY(cargo)) AS cargo,
			CONVERT(DATE, CONVERT(VARCHAR(10), DECRYPTBYKEY(fechaAlta))) AS fechaAlta,
			CONVERT(DATE, CONVERT(VARCHAR(10), DECRYPTBYKEY(fechaBaja))) AS fechaBaja,
			idSucursal
		FROM Empleado.Empleado
		WHERE legajoEmpleado = @legajoEmpleado
	END
 
    CLOSE SYMMETRIC KEY EmpleadoLlave;
END;
GO


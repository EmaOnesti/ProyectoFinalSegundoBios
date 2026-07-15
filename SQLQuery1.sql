USE master
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'VuelosAgencia')
BEGIN
	DROP DATABASE VuelosAgencia
END
GO

CREATE DATABASE VuelosAgencia
GO

USE VuelosAgencia
GO


/*******************************    TABLAS    *******************************/

CREATE TABLE Empleados
(
	Usu			VARCHAR(15)		PRIMARY KEY,
	Clave		VARCHAR(10)		NOT NULL,
	NomComp		VARCHAR(100)	NOT NULL,
	Act			BIT				NOT NULL DEFAULT 1,

	CONSTRAINT CK_Empleado_Usu
		CHECK(LEN(Usu) BETWEEN 1 AND 15),

	CONSTRAINT CK_Empleado_Clave
		CHECK(
			LEN(Clave) BETWEEN 5 AND 10
			AND Clave LIKE '%[A-Za-z]%'
			AND Clave LIKE '%[0-9]%'
			AND Clave LIKE '%[^A-Za-z0-9]%'
		),

	CONSTRAINT CK_Empleado_Nombre
		CHECK(LEN(NomComp) >= 5)
)
GO


CREATE TABLE Estados
(
	Cod			CHAR(4)			PRIMARY KEY,
	Nom			VARCHAR(80)		NOT NULL,
	Pais		VARCHAR(80)		NOT NULL,
	Act			BIT				NOT NULL DEFAULT 1,

	CONSTRAINT CK_Estado_Codigo
		CHECK(Cod LIKE '[A-Z][A-Z][A-Z][A-Z]'),

	CONSTRAINT CK_Estado_Nombre
		CHECK(LEN(Nom) >= 3),

	CONSTRAINT CK_Estado_Pais
		CHECK(LEN(Pais) >= 3)
)
GO

CREATE TABLE Vuelos
(
	Cod			CHAR(10)		PRIMARY KEY,
	FecSal		DATETIME		NOT NULL,
	EstOri		CHAR(4)			NOT NULL,
	FecLle		DATETIME		NOT NULL,
	EstDes		CHAR(4)			NOT NULL,
	Precio		DECIMAL(10,2)	NOT NULL,
	Act			BIT				NOT NULL DEFAULT 1,

	CONSTRAINT FK_Vuelo_EstadoOrigen
		FOREIGN KEY (EstOri)
		REFERENCES Estados(Cod),

	CONSTRAINT FK_Vuelo_EstadoDestino
		FOREIGN KEY (EstDes)
		REFERENCES Estados(Cod),

	CONSTRAINT CK_Vuelo_Codigo
		CHECK(LEN(Cod) = 10),

	CONSTRAINT CK_Vuelo_Fechas
		CHECK(FecLle > FecSal),

	CONSTRAINT CK_Vuelo_Precio
		CHECK(Precio > 0)
)
GO

CREATE TABLE Hospedajes
(
	Cod			VARCHAR(10)		PRIMARY KEY,
	Nom			VARCHAR(100)	NOT NULL,
	Dir			VARCHAR(150)	NOT NULL,
	Tipo		VARCHAR(20)		NOT NULL,
	PreNoc		DECIMAL(10,2)	NOT NULL,
	Est			CHAR(4)			NOT NULL,
	Act			BIT				NOT NULL DEFAULT 1,

	CONSTRAINT FK_Hospedaje_Estado
		FOREIGN KEY (Est)
		REFERENCES Estados(Cod),

	CONSTRAINT CK_Hospedaje_Codigo
		CHECK(
			LEN(Cod) BETWEEN 1 AND 10
			AND Cod NOT LIKE '%[^A-Za-z]%'
		),

	CONSTRAINT CK_Hospedaje_Nombre
		CHECK(LEN(Nom) >= 3),

	CONSTRAINT CK_Hospedaje_Direccion
		CHECK(LEN(Dir) >= 5),

	CONSTRAINT CK_Hospedaje_Tipo
		CHECK(Tipo IN ('Hotel STD','Posada','All Inclusive')),

	CONSTRAINT CK_Hospedaje_Precio
		CHECK(PreNoc > 0)
)
GO

CREATE TABLE Paquetes
(
	Cod			INT IDENTITY(1,1)	PRIMARY KEY,
	Tit			VARCHAR(100)		NOT NULL,
	Descripcion		VARCHAR(500)		NOT NULL,
	CantDias	INT					NOT NULL,
	PreInd		DECIMAL(10,2)		NOT NULL,
	PreDob		DECIMAL(10,2)		NOT NULL,
	PreTri		DECIMAL(10,2)		NOT NULL,
	EstDes		CHAR(4)				NOT NULL,
	VueIda		CHAR(10)			NOT NULL,
	VueVta		CHAR(10)			NOT NULL,
	Emp			VARCHAR(15)			NOT NULL,
	Act			BIT					NOT NULL DEFAULT 1,

	CONSTRAINT FK_Paquete_Estado
		FOREIGN KEY (EstDes)
		REFERENCES Estados(Cod),

	CONSTRAINT FK_Paquete_VueloIda
		FOREIGN KEY (VueIda)
		REFERENCES Vuelos(Cod),

	CONSTRAINT FK_Paquete_VueloVuelta
		FOREIGN KEY (VueVta)
		REFERENCES Vuelos(Cod),

	CONSTRAINT FK_Paquete_Empleado
		FOREIGN KEY (Emp)
		REFERENCES Empleados(Usu),

	CONSTRAINT CK_Paquete_Titulo
		CHECK(LEN(Tit) >= 5),

	CONSTRAINT CK_Paquete_Descripcion
		CHECK(LEN(Descripcion) >= 10),

	CONSTRAINT CK_Paquete_Dias
		CHECK(CantDias > 0),

	CONSTRAINT CK_Paquete_PrecioIndividual
		CHECK(PreInd > 0),

	CONSTRAINT CK_Paquete_PrecioDoble
		CHECK(PreDob > 0),

	CONSTRAINT CK_Paquete_PrecioTriple
		CHECK(PreTri > 0),

	CONSTRAINT CK_Paquete_Vuelos
		CHECK(VueIda <> VueVta)
)
GO

CREATE TABLE PaquetesHospedajes
(
	Paq			INT				NOT NULL,
	Hosp		VARCHAR(10)		NOT NULL,
	CantNoc		INT				NOT NULL,

	PRIMARY KEY (Paq, Hosp),

	CONSTRAINT FK_PH_Paquete
		FOREIGN KEY (Paq)
		REFERENCES Paquetes(Cod),

	CONSTRAINT FK_PH_Hospedaje
		FOREIGN KEY (Hosp)
		REFERENCES Hospedajes(Cod),

	CONSTRAINT CK_PH_Noches
		CHECK(CantNoc > 0)
)
GO

USE master
GO

IF NOT EXISTS
(
	SELECT *
	FROM sys.server_principals
	WHERE name = 'IIS APPPOOL\DefaultAppPool'
)
BEGIN
	CREATE LOGIN [IIS APPPOOL\DefaultAppPool]
	FROM WINDOWS
END
GO

USE VuelosAgencia
GO

IF NOT EXISTS
(
	SELECT *
	FROM sys.database_principals
	WHERE name = 'IIS APPPOOL\DefaultAppPool'
)
BEGIN
	CREATE USER [IIS APPPOOL\DefaultAppPool]
	FOR LOGIN [IIS APPPOOL\DefaultAppPool]
END
GO

EXEC sp_addrolemember
	'db_owner',
	'IIS APPPOOL\DefaultAppPool'
GO

/*******************************    DATOS DE PRUEBA    *******************************/

INSERT INTO Empleados (Usu, Clave, NomComp, Act)
VALUES
('admin','Adm1@','Administrador General',1),
('juanp','Jp123@','Juan Perez Rodriguez',1),
('marias','Ms456#','Maria Silva Gomez',1),
('carlosr','Cr789$','Carlos Rodriguez',1),
('lauraf','Lf321%','Laura Fernandez',1),
('pedrom','Pm741&','Pedro Martinez',1),
('anag','Ag852*','Ana Gonzalez',1),
('lucasg','Lg963!','Lucas Garcia',1),
('sofiam','Sm147@','Sofia Morales',1),
('martinc','Mc258#','Martin Castro',1),
('valeriah','Vh369$','Valeria Hernandez',1),
('federicob','Fb159%','Federico Blanco',1);
GO

INSERT INTO Estados (Cod, Nom, Pais, Act)
VALUES
('RIOJ','Rio de Janeiro','Brasil',1),
('ALAG','Alagoas','Brasil',1),
('BAHI','Bahia','Brasil',1),
('CANC','Cancun','Mexico',1),
('QROO','Quintana Roo','Mexico',1),
('PCAN','Punta Cana','Republica Dominicana',1),
('LIMA','Lima','Peru',1),
('CUSC','Cusco','Peru',1),
('MIAM','Miami','Estados Unidos',1),
('ORLA','Orlando','Estados Unidos',1),
('MADR','Madrid','España',1),
('BARC','Barcelona','España',1),
('ROMA','Roma','Italia',1),
('PARI','Paris','Francia',1),
('LOND','Londres','Reino Unido',1),
('AMST','Amsterdam','Paises Bajos',1),
('BERL','Berlin','Alemania',1),
('TOKY','Tokio','Japon',1),
('SYDN','Sidney','Australia',1),
('BUEN','Buenos Aires','Argentina',1);
GO


INSERT INTO Vuelos (Cod, FecSal, EstOri, FecLle, EstDes, Precio, Act)
VALUES
('VUE0000001','2026-03-10T08:00:00','BUEN','2026-03-10T11:30:00','RIOJ',450.00,1),
('VUE0000002','2026-03-12T07:15:00','BUEN','2026-03-12T12:10:00','ALAG',620.00,1),
('VUE0000003','2026-03-15T09:00:00','BUEN','2026-03-15T13:20:00','BAHI',590.00,1),
('VUE0000004','2026-03-18T06:30:00','BUEN','2026-03-18T15:10:00','CANC',980.00,1),
('VUE0000005','2026-03-20T07:20:00','BUEN','2026-03-20T15:30:00','QROO',1010.00,1),

('VUE0000006','2026-03-25T08:00:00','BUEN','2026-03-25T16:20:00','PCAN',940.00,1),
('VUE0000007','2026-03-28T09:00:00','BUEN','2026-03-28T12:40:00','LIMA',500.00,1),
('VUE0000008','2026-04-02T10:00:00','BUEN','2026-04-02T15:20:00','CUSC',610.00,1),
('VUE0000009','2026-04-05T07:10:00','BUEN','2026-04-05T16:00:00','MIAM',1200.00,1),
('VUE0000010','2026-04-08T07:40:00','BUEN','2026-04-08T16:50:00','ORLA',1275.00,1),

('VUE0000011','2026-04-12T15:00:00','BUEN','2026-04-13T08:20:00','MADR',1800.00,1),
('VUE0000012','2026-04-15T16:10:00','BUEN','2026-04-16T09:15:00','BARC',1820.00,1),
('VUE0000013','2026-04-18T18:00:00','BUEN','2026-04-19T11:10:00','ROMA',1950.00,1),
('VUE0000014','2026-04-21T19:00:00','BUEN','2026-04-22T11:30:00','PARI',1980.00,1),
('VUE0000015','2026-04-24T20:00:00','BUEN','2026-04-25T12:45:00','LOND',2050.00,1),

('VUE0000016','2026-05-01T07:30:00','RIOJ','2026-05-01T10:50:00','BUEN',450.00,1),
('VUE0000017','2026-05-05T08:00:00','ALAG','2026-05-05T12:40:00','BUEN',620.00,1),
('VUE0000018','2026-05-08T09:15:00','BAHI','2026-05-08T13:45:00','BUEN',590.00,1),
('VUE0000019','2026-05-12T16:00:00','CANC','2026-05-12T23:30:00','BUEN',980.00,1),
('VUE0000020','2026-05-15T16:30:00','QROO','2026-05-15T23:45:00','BUEN',1010.00,1);
GO

INSERT INTO Hospedajes (Cod, Nom, Dir, Tipo, PreNoc, Est)
VALUES
('GOCA','Gran Oca','Rua Central 123 - Maragogi','All Inclusive',150,'ALAG'),
('SOLMAR','Sol del Mar','Av. Costera 45 - Cancún','Hotel STD',120,'QROO'),
('POSAZUL','Posada Azul','Av. Costera 20 - Cancún','Posada',90,'QROO'),
('ANDESHOT','Andes Hotel','Av. Paulista 500 - Sao Paulo','Hotel STD',110,'BAHI'),
('PATAGON','Patagonia Lodge','Copacabana 450 - Rio de Janeiro','Posada',95,'RIOJ'),
('RIOHOT','Rio Palace','Copacabana 100 - Río de Janeiro','Hotel STD',180,'RIOJ'),
('BAHIA','Bahía Resort','Praia do Forte','All Inclusive',220,'BAHI'),
('NORTE','Hotel Norte','Av. Principal 45 - Lima','Hotel STD',100,'LIMA'),
('LAGUNA','Laguna Inn','Costanera 550 - Cusco','Posada',85,'CUSC'),
('SELVA','Selva Hotel','Centro 25 - Punta Cana','Hotel STD',130,'PCAN');
GO

INSERT INTO Paquetes
(Tit, Descripcion, CantDias, PreInd, PreDob, PreTri, EstDes, VueIda, VueVta, Emp, Act)
VALUES
('Rio Clasico','Paquete para conocer Rio de Janeiro con alojamiento frente al mar.',5,1350.00,2430.00,3645.00,'RIOJ','VUE0000001','VUE0000016','admin',1),
('Alagoas Premium','Vacaciones completas en playas de Alagoas.',8,1800.00,3240.00,4860.00,'ALAG','VUE0000002','VUE0000017','juanp',1),
('Bahia Tropical','Disfrute de las mejores playas de Bahia.',7,1700.00,3060.00,4590.00,'BAHI','VUE0000003','VUE0000018','marias',1),
('Cancun Paradise','Viaje completo a Cancun con hotel incluido.',8,2800.00,5040.00,7560.00,'CANC','VUE0000004','VUE0000019','carlosr',1),
('Quintana Roo Deluxe','Paquete exclusivo para Riviera Maya.',9,2950.00,5310.00,7965.00,'QROO','VUE0000005','VUE0000020','lauraf',1),
('Punta Cana Relax','Descanso en playas caribeñas.',7,2650.00,4770.00,7155.00,'PCAN','VUE0000006','VUE0000020','pedrom',1),
('Lima Cultural','Recorrido histórico por Lima.',6,1450.00,2610.00,3915.00,'LIMA','VUE0000007','VUE0000016','anag',1),
('Cusco Inca','Conozca Machu Picchu y Cusco.',8,2100.00,3780.00,5670.00,'CUSC','VUE0000008','VUE0000017','lucasg',1),
('Miami Shopping','Compras y playa en Miami.',9,3400.00,6120.00,9180.00,'MIAM','VUE0000009','VUE0000018','sofiam',1),
('Orlando Magic','Parques temáticos para toda la familia.',10,3600.00,6480.00,9720.00,'ORLA','VUE0000010','VUE0000019','martinc',1),
('Madrid Imperial','Recorra la capital española.',10,4200.00,7560.00,11340.00,'MADR','VUE0000011','VUE0000020','valeriah',1),
('Barcelona Mediterranea','Playas y cultura catalana.',10,4250.00,7650.00,11475.00,'BARC','VUE0000012','VUE0000016','federicob',1);

INSERT INTO PaquetesHospedajes (Paq, Hosp, CantNoc)
VALUES
(1,'RIOHOT',4),
(1,'PATAGON',1),
(1,'BAHIA',2),

(2,'GOCA',5),
(2,'BAHIA',2),
(2,'RIOHOT',1),

(3,'BAHIA',6),
(3,'GOCA',1),
(3,'RIOHOT',1),

(4,'SOLMAR',6),
(4,'POSAZUL',2),
(4,'GOCA',1),

(5,'SOLMAR',7),
(5,'POSAZUL',1),
(5,'GOCA',1),

(6,'SELVA',6),
(6,'GOCA',1),
(6,'RIOHOT',1),

(7,'NORTE',5),
(7,'SELVA',1),
(7,'GOCA',1),

(8,'LAGUNA',6),
(8,'NORTE',1),
(8,'GOCA',1),

(9,'RIOHOT',3),
(9,'BAHIA',3),
(9,'GOCA',2),

(10,'RIOHOT',5),
(10,'GOCA',2),
(10,'BAHIA',2),

(11,'RIOHOT',5),
(11,'BAHIA',3),
(11,'GOCA',1),

(12,'RIOHOT',5),
(12,'BAHIA',3),
(12,'GOCA',1);
GO

/*******************************    PROCEDIMIENTOS    *******************************/

CREATE PROCEDURE AltaEmpleado
(
	@Usu		VARCHAR(15),
	@Clave		VARCHAR(10),
	@NomComp	VARCHAR(100)
)
AS
BEGIN
	INSERT INTO Empleados
	(
		Usu,
		Clave,
		NomComp
	)
	VALUES
	(
		@Usu,
		@Clave,
		@NomComp
	)
END
GO


CREATE PROCEDURE ModificarEmpleado
(
	@Usu		VARCHAR(15),
	@Clave		VARCHAR(10),
	@NomComp	VARCHAR(100)
)
AS
BEGIN
	UPDATE Empleados
	SET
		Clave = @Clave,
		NomComp = @NomComp
	WHERE Usu = @Usu
END
GO


CREATE PROCEDURE BuscarEmpleado
(
	@Usu VARCHAR(15)
)
AS
BEGIN
	SELECT
		Usu,
		Clave,
		NomComp,
		Act
	FROM Empleados
	WHERE Usu = @Usu
END
GO


CREATE PROCEDURE ListarEmpleados
AS
BEGIN
	SELECT
		Usu,
		NomComp,
		Act
	FROM Empleados
	ORDER BY NomComp
END
GO

CREATE PROCEDURE BajaEmpleado
(
    @Usu VARCHAR(15)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT *
        FROM Empleados
        WHERE Usu = @Usu
    )
    BEGIN
        RAISERROR('El empleado no existe.',16,1);
        RETURN;
    END

    IF EXISTS
    (
        SELECT *
        FROM Paquetes
        WHERE Emp = @Usu
    )
    BEGIN
        UPDATE Empleados
        SET Act = 0
        WHERE Usu = @Usu;
    END
    ELSE
    BEGIN
        DELETE
        FROM Empleados
        WHERE Usu = @Usu;
    END
END
GO

CREATE PROCEDURE AltaEstado
	@Cod CHAR(4),
	@Nom VARCHAR(80),
	@Pais VARCHAR(80)
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS
	(
		SELECT *
		FROM Estados
		WHERE Cod = @Cod
	)
	BEGIN
		RAISERROR('Ya existe un estado con ese codigo.',16,1)
		RETURN
	END

	INSERT INTO Estados
	(
		Cod,
		Nom,
		Pais,
		Act
	)
	VALUES
	(
		@Cod,
		@Nom,
		@Pais,
		1
	)
END
GO

CREATE PROCEDURE ModificarEstado
	@Cod CHAR(4),
	@Nom VARCHAR(80),
	@Pais VARCHAR(80)
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS
	(
		SELECT *
		FROM Estados
		WHERE Cod = @Cod
	)
	BEGIN
		RAISERROR('El estado no existe.',16,1)
		RETURN
	END

	UPDATE Estados
	SET
		Nom = @Nom,
		Pais = @Pais
	WHERE Cod = @Cod
END
GO

CREATE PROCEDURE BajaEstado
	@Cod CHAR(4)
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS
	(
		SELECT *
		FROM Estados
		WHERE Cod = @Cod
	)
	BEGIN
		RAISERROR('El estado no existe.',16,1)
		RETURN
	END

	IF EXISTS (SELECT * FROM Vuelos WHERE EstOri = @Cod OR EstDes = @Cod)
		OR EXISTS (SELECT * FROM Hospedajes WHERE Est = @Cod)
		OR EXISTS (SELECT * FROM Paquetes WHERE EstDes = @Cod)
	BEGIN
		UPDATE Estados
		SET Act = 0
		WHERE Cod = @Cod
	END
	ELSE
	BEGIN
		DELETE FROM Estados
		WHERE Cod = @Cod
	END
END
GO

CREATE PROCEDURE BuscarEstado
	@Cod CHAR(4)
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		Cod,
		Nom,
		Pais,
		Act
	FROM Estados
	WHERE Cod = @Cod
END
GO

CREATE PROCEDURE ListarEstados
	@Nombre VARCHAR(80) = ''
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		Cod,
		Nom,
		Pais,
		Act
	FROM Estados
	WHERE Nom LIKE '%' + @Nombre + '%'
	ORDER BY Nom
END
GO

CREATE PROCEDURE AltaVuelo
	@Cod CHAR(10),
	@FecSal DATETIME,
	@EstOri CHAR(4),
	@FecLle DATETIME,
	@EstDes CHAR(4),
	@Precio DECIMAL(10,2)
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS
	(
		SELECT *
		FROM Vuelos
		WHERE Cod = @Cod
	)
	BEGIN
		RAISERROR('Ya existe un vuelo con ese codigo.',16,1)
		RETURN
	END

	IF NOT EXISTS
	(
		SELECT *
		FROM Estados
		WHERE Cod = @EstOri
	)
	BEGIN
		RAISERROR('El estado de origen no existe.',16,1)
		RETURN
	END

	IF NOT EXISTS
	(
		SELECT *
		FROM Estados
		WHERE Cod = @EstDes
	)
	BEGIN
		RAISERROR('El estado de destino no existe.',16,1)
		RETURN
	END

	IF @EstOri = @EstDes
	BEGIN
		RAISERROR('El origen y destino no pueden ser iguales.',16,1)
		RETURN
	END

	IF @FecLle <= @FecSal
	BEGIN
		RAISERROR('La fecha de llegada debe ser posterior a la salida.',16,1)
		RETURN
	END

	INSERT INTO Vuelos
	(
		Cod,
		FecSal,
		EstOri,
		FecLle,
		EstDes,
		Precio,
		Act
	)
	VALUES
	(
		@Cod,
		@FecSal,
		@EstOri,
		@FecLle,
		@EstDes,
		@Precio,
		1
	)
END
GO

CREATE PROCEDURE ModificarVuelo
	@Cod CHAR(10),
	@FecSal DATETIME,
	@EstOri CHAR(4),
	@FecLle DATETIME,
	@EstDes CHAR(4),
	@Precio DECIMAL(10,2)
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS
	(
		SELECT *
		FROM Vuelos
		WHERE Cod = @Cod
	)
	BEGIN
		RAISERROR('El vuelo no existe.',16,1)
		RETURN
	END

	IF @EstOri = @EstDes
	BEGIN
		RAISERROR('El origen y destino no pueden ser iguales.',16,1)
		RETURN
	END

	IF @FecLle <= @FecSal
	BEGIN
		RAISERROR('La fecha de llegada debe ser posterior a la salida.',16,1)
		RETURN
	END

	UPDATE Vuelos
	SET
		FecSal = @FecSal,
		EstOri = @EstOri,
		FecLle = @FecLle,
		EstDes = @EstDes,
		Precio = @Precio
	WHERE Cod = @Cod
END
GO

CREATE PROCEDURE BajaVuelo
	@Cod CHAR(10)
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS
	(
		SELECT *
		FROM Vuelos
		WHERE Cod = @Cod
	)
	BEGIN
		RAISERROR('El vuelo no existe.',16,1)
		RETURN
	END

	IF EXISTS
	(
		SELECT *
		FROM Paquetes
		WHERE VueIda = @Cod
		   OR VueVta = @Cod
	)
	BEGIN
		UPDATE Vuelos
		SET Act = 0
		WHERE Cod = @Cod
	END
	ELSE
	BEGIN
		DELETE
		FROM Vuelos
		WHERE Cod = @Cod
	END
END
GO

CREATE PROCEDURE BuscarVuelo
	@Cod CHAR(10)
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		Cod,
		FecSal,
		EstOri,
		FecLle,
		EstDes,
		Precio,
		Act
	FROM Vuelos
	WHERE Cod = @Cod
END
GO

CREATE PROCEDURE ListarVuelos
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		Cod,
		FecSal,
		EstOri,
		FecLle,
		EstDes,
		Precio,
		Act
	FROM Vuelos
	ORDER BY FecSal
END
GO

CREATE PROCEDURE AltaHospedaje
	@Cod VARCHAR(10),
	@Nom VARCHAR(100),
	@Dir VARCHAR(150),
	@Tipo VARCHAR(20),
	@PreNoc DECIMAL(10,2),
	@Est CHAR(4)
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS
	(
		SELECT *
		FROM Hospedajes
		WHERE Cod = @Cod
	)
	BEGIN
		RAISERROR('Ya existe un hospedaje con ese codigo.',16,1)
		RETURN
	END

	IF NOT EXISTS
	(
		SELECT *
		FROM Estados
		WHERE Cod = @Est
	)
	BEGIN
		RAISERROR('El estado indicado no existe.',16,1)
		RETURN
	END

	IF @Tipo NOT IN ('Hotel STD','Posada','All Inclusive')
	BEGIN
		RAISERROR('Tipo de hospedaje invalido.',16,1)
		RETURN
	END

	INSERT INTO Hospedajes
	(
		Cod,
		Nom,
		Dir,
		Tipo,
		PreNoc,
		Est,
		Act
	)
	VALUES
	(
		@Cod,
		@Nom,
		@Dir,
		@Tipo,
		@PreNoc,
		@Est,
		1
	)
END
GO

CREATE PROCEDURE ModificarHospedaje
	@Cod VARCHAR(10),
	@Nom VARCHAR(100),
	@Dir VARCHAR(150),
	@Tipo VARCHAR(20),
	@PreNoc DECIMAL(10,2),
	@Est CHAR(4)
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS
	(
		SELECT *
		FROM Hospedajes
		WHERE Cod=@Cod
	)
	BEGIN
		RAISERROR('El hospedaje no existe.',16,1)
		RETURN
	END

	IF NOT EXISTS
	(
		SELECT *
		FROM Estados
		WHERE Cod=@Est
	)
	BEGIN
		RAISERROR('El estado indicado no existe.',16,1)
		RETURN
	END

	IF @Tipo NOT IN ('Hotel STD','Posada','All Inclusive')
	BEGIN
		RAISERROR('Tipo de hospedaje invalido.',16,1)
		RETURN
	END

	UPDATE Hospedajes
	SET
		Nom=@Nom,
		Dir=@Dir,
		Tipo=@Tipo,
		PreNoc=@PreNoc,
		Est=@Est
	WHERE Cod=@Cod
END
GO

CREATE PROCEDURE BajaHospedaje
	@Cod VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS
	(
		SELECT *
		FROM Hospedajes
		WHERE Cod=@Cod
	)
	BEGIN
		RAISERROR('El hospedaje no existe.',16,1)
		RETURN
	END

	IF EXISTS
	(
		SELECT *
		FROM PaquetesHospedajes
		WHERE Hosp=@Cod
	)
	BEGIN
		UPDATE Hospedajes
		SET Act=0
		WHERE Cod=@Cod
	END
	ELSE
	BEGIN
		DELETE
		FROM Hospedajes
		WHERE Cod=@Cod
	END
END
GO

CREATE PROCEDURE BuscarHospedaje
	@Cod VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		Cod,
		Nom,
		Dir,
		Tipo,
		PreNoc,
		Est,
		Act
	FROM Hospedajes
	WHERE Cod=@Cod
END
GO

CREATE PROCEDURE ListarHospedajes
	@Nombre VARCHAR(100)=''
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		Cod,
		Nom,
		Dir,
		Tipo,
		PreNoc,
		Est,
		Act
	FROM Hospedajes
	WHERE Nom LIKE '%' + @Nombre + '%'
	ORDER BY Nom
END
GO

CREATE PROCEDURE AltaPaquete
(
	@Tit VARCHAR(100),
	@Descripcion VARCHAR(500),
	@EstDes CHAR(4),
	@VueIda CHAR(10),
	@VueVta CHAR(10),
	@Emp VARCHAR(15)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CantDias INT;

	IF NOT EXISTS(SELECT * FROM Estados WHERE Cod=@EstDes)
	BEGIN
		RAISERROR('Estado inexistente.',16,1)
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM Empleados WHERE Usu=@Emp)
	BEGIN
		RAISERROR('Empleado inexistente.',16,1)
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM Vuelos WHERE Cod=@VueIda)
	BEGIN
		RAISERROR('Vuelo de ida inexistente.',16,1)
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM Vuelos WHERE Cod=@VueVta)
	BEGIN
		RAISERROR('Vuelo de vuelta inexistente.',16,1)
		RETURN
	END

	IF (SELECT EstDes FROM Vuelos WHERE Cod=@VueIda)<>@EstDes
	BEGIN
		RAISERROR('El vuelo de ida no llega al destino.',16,1)
		RETURN
	END

	IF (SELECT EstOri FROM Vuelos WHERE Cod=@VueVta)<>@EstDes
	BEGIN
		RAISERROR('El vuelo de vuelta no sale del destino.',16,1)
		RETURN
	END
	
	IF @VueIda=@VueVta
	BEGIN
	    RAISERROR('Los vuelos deben ser distintos.',16,1)
	    RETURN
	END
	
	IF
	(
	SELECT FecSal
	FROM Vuelos
	WHERE Cod=@VueIda
	)
	>=
	(
	SELECT FecSal
	FROM Vuelos
	WHERE Cod=@VueVta
	)
	BEGIN
	     RAISERROR('El vuelo de vuelta debe salir luego del vuelo de ida.',16,1)
	     RETURN
	END

	SELECT @CantDias=
	DATEDIFF
	(
		DAY,
		(SELECT FecSal FROM Vuelos WHERE Cod=@VueIda),
		(SELECT FecSal FROM Vuelos WHERE Cod=@VueVta)
	)

	INSERT INTO Paquetes
	(
		Tit,
		Descripcion,
		CantDias,
		PreInd,
		PreDob,
		PreTri,
		EstDes,
		VueIda,
		VueVta,
		Emp,
		Act
	)
	VALUES
	(
		@Tit,
		@Descripcion,
		@CantDias,
		0,
		0,
		0,
		@EstDes,
		@VueIda,
		@VueVta,
		@Emp,
		1
	)

	SELECT SCOPE_IDENTITY() AS CodigoPaquete;
END
GO

CREATE PROCEDURE RecalcularPreciosPaquete
(
	@Paq INT
)
AS
BEGIN

	DECLARE @Base DECIMAL(10,2)

	SELECT
		@Base=
		VI.Precio+
		VV.Precio+
		ISNULL(SUM(H.PreNoc*PH.CantNoc),0)
	FROM Paquetes P
	INNER JOIN Vuelos VI
	ON P.VueIda=VI.Cod
	INNER JOIN Vuelos VV
	ON P.VueVta=VV.Cod
	LEFT JOIN PaquetesHospedajes PH
	ON P.Cod=PH.Paq
	LEFT JOIN Hospedajes H
	ON H.Cod=PH.Hosp
	WHERE P.Cod=@Paq
	GROUP BY VI.Precio,VV.Precio

	UPDATE Paquetes
	SET

	PreInd=@Base*1.35,

	PreDob=@Base*2*1.10,

	PreTri=@Base*3*1.10

	WHERE Cod=@Paq

END
GO

CREATE PROCEDURE AltaPaqueteHospedaje
(
	@Paq INT,
	@Hosp VARCHAR(10),
	@CantNoc INT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS
(
	SELECT *
	FROM PaquetesHospedajes
	WHERE Paq=@Paq
	AND Hosp=@Hosp
)
BEGIN
	RAISERROR('Ese hospedaje ya fue agregado al paquete.',16,1)
	RETURN
END

IF @CantNoc<=0
BEGIN
	RAISERROR('La cantidad de noches debe ser mayor a cero.',16,1)
	RETURN
END

	IF NOT EXISTS(SELECT * FROM Paquetes WHERE Cod=@Paq)
	BEGIN
		RAISERROR('Paquete inexistente.',16,1)
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM Hospedajes WHERE Cod=@Hosp)
	BEGIN
		RAISERROR('Hospedaje inexistente.',16,1)
		RETURN
	END

	INSERT INTO PaquetesHospedajes
	(
		Paq,
		Hosp,
		CantNoc
	)
	VALUES
	(
		@Paq,
		@Hosp,
		@CantNoc
	)

	EXEC RecalcularPreciosPaquete @Paq
END
GO

CREATE PROCEDURE ModificarPaqueteHospedaje
(
	@Paq INT,
	@Hosp VARCHAR(10),
	@CantNoc INT
)
AS
BEGIN

	SET NOCOUNT ON;

	IF NOT EXISTS
	(
		SELECT *
		FROM PaquetesHospedajes
		WHERE Paq=@Paq
		AND Hosp=@Hosp
	)
	BEGIN
		RAISERROR('La relación paquete-hospedaje no existe.',16,1)
		RETURN
	END

	IF @CantNoc<=0
	BEGIN
		RAISERROR('La cantidad de noches debe ser mayor a cero.',16,1)
		RETURN
	END

	UPDATE PaquetesHospedajes

	SET CantNoc=@CantNoc

	WHERE
	Paq=@Paq
	AND Hosp=@Hosp

	EXEC RecalcularPreciosPaquete @Paq

END
GO

CREATE PROCEDURE BajaPaqueteHospedaje
(
	@Paq INT,
	@Hosp VARCHAR(10)
)
AS
BEGIN

	SET NOCOUNT ON;

	IF NOT EXISTS
	(
		SELECT *
		FROM PaquetesHospedajes
		WHERE Paq=@Paq
		AND Hosp=@Hosp
	)
	BEGIN
		RAISERROR('La relación paquete-hospedaje no existe.',16,1)
		RETURN
	END

	DELETE

	FROM PaquetesHospedajes

	WHERE
	Paq=@Paq
	AND Hosp=@Hosp

	EXEC RecalcularPreciosPaquete @Paq

END
GO

CREATE PROCEDURE BuscarHospedajesPaquete
(
	@Paq INT
)
AS
BEGIN

	SELECT

	H.Cod,
	H.Nom,
	H.Tipo,
	H.PreNoc,
	PH.CantNoc

	FROM PaquetesHospedajes PH

	INNER JOIN Hospedajes H

	ON PH.Hosp=H.Cod

	WHERE PH.Paq=@Paq

END
GO

CREATE PROCEDURE ModificarPaquete
(
	@Cod INT,
	@Tit VARCHAR(100),
	@Descripcion VARCHAR(500),
	@EstDes CHAR(4),
	@VueIda CHAR(10),
	@VueVta CHAR(10),
	@Emp VARCHAR(15)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CantDias INT;

	IF NOT EXISTS(SELECT * FROM Paquetes WHERE Cod=@Cod)
	BEGIN
		RAISERROR('El paquete no existe.',16,1)
		RETURN
	END

	IF (SELECT EstDes FROM Vuelos WHERE Cod=@VueIda)<>@EstDes
	BEGIN
		RAISERROR('El vuelo de ida no corresponde al destino.',16,1)
		RETURN
	END

	IF (SELECT EstOri FROM Vuelos WHERE Cod=@VueVta)<>@EstDes
	BEGIN
		RAISERROR('El vuelo de vuelta no corresponde al destino.',16,1)
		RETURN
	END

	SELECT @CantDias=
	DATEDIFF
	(
		DAY,
		(SELECT FecSal FROM Vuelos WHERE Cod=@VueIda),
		(SELECT FecSal FROM Vuelos WHERE Cod=@VueVta)
	)

	UPDATE Paquetes

	SET

	Tit=@Tit,
	Descripcion=@Descripcion,
	CantDias=@CantDias,
	EstDes=@EstDes,
	VueIda=@VueIda,
	VueVta=@VueVta,
	Emp=@Emp

	WHERE Cod=@Cod

	EXEC RecalcularPreciosPaquete @Cod

END
GO

CREATE PROCEDURE BajaPaquete
(
	@Cod INT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	IF NOT EXISTS
(
	SELECT *
	FROM Paquetes
	WHERE Cod=@Cod
)
BEGIN
	RAISERROR('El paquete no existe.',16,1)
	RETURN
END

	IF EXISTS
	(
		SELECT *
		FROM PaquetesHospedajes
		WHERE Paq=@Cod
	)
	BEGIN

		UPDATE Paquetes

		SET Act=0

		WHERE Cod=@Cod

	END
	ELSE
	BEGIN

		DELETE

		FROM Paquetes

		WHERE Cod=@Cod

	END

END
GO

CREATE PROCEDURE BuscarPaquete
(
	@Cod INT
)
AS
BEGIN

	SELECT

	P.Cod,
	P.Tit,
	P.Descripcion,
	P.CantDias,
	P.PreInd,
	P.PreDob,
	P.PreTri,
	E.Nom AS Estado,
	VI.Cod AS VueloIda,
	VV.Cod AS VueloVuelta,
	EM.NomComp,
	P.Act

	FROM Paquetes P

	INNER JOIN Estados E
	ON P.EstDes=E.Cod

	INNER JOIN Vuelos VI
	ON P.VueIda=VI.Cod

	INNER JOIN Vuelos VV
	ON P.VueVta=VV.Cod

	INNER JOIN Empleados EM
	ON P.Emp=EM.Usu

	WHERE P.Cod=@Cod

END
GO

CREATE PROCEDURE ListarPaquetes
(
	@Estado CHAR(4)=NULL
)
AS
BEGIN

	SELECT

	P.Cod,
	P.Tit,
	E.Nom Estado,
	P.CantDias,
	P.PreInd,
	P.PreDob,
	P.PreTri,
	P.Act

	FROM Paquetes P

	INNER JOIN Estados E

	ON P.EstDes=E.Cod

	WHERE

	@Estado IS NULL

	OR

	P.EstDes=@Estado

	ORDER BY P.Tit

END
GO

CREATE PROCEDURE LoginEmpleado
(
	@Usu VARCHAR(15),
	@Clave VARCHAR(10)
)
AS
BEGIN

	SELECT *

	FROM Empleados

	WHERE

	Usu=@Usu

	AND

	Clave=@Clave

	AND

	Act=1

END
GO

CREATE PROCEDURE CrearUsuarioSQL
(
	@Usuario VARCHAR(15),
	@Clave VARCHAR(10)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX);

	IF EXISTS
	(
		SELECT *
		FROM sys.server_principals
		WHERE name = @Usuario
	)
	BEGIN
		RAISERROR('El Login ya existe.',16,1);
		RETURN;
	END

	SET @SQL =
	'CREATE LOGIN [' + @Usuario + '] WITH PASSWORD = ''' + @Clave + ''';';

	EXEC(@SQL);

	SET @SQL =
	'USE VuelosAgencia;
	CREATE USER [' + @Usuario + '] FOR LOGIN [' + @Usuario + '];
	ALTER ROLE db_datareader ADD MEMBER [' + @Usuario + '];
	ALTER ROLE db_datawriter ADD MEMBER [' + @Usuario + '];';

	EXEC(@SQL);
END
GO
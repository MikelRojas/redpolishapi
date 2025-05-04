CREATE TABLE Categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Promociones (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    porcentaje NUMERIC(5,2) CHECK (porcentaje >= 0 AND porcentaje <= 100),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

CREATE TABLE Usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(255) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL
);

CREATE TABLE Productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    stock INT NOT NULL CHECK (stock >= 0),
    categoria_id INT NOT NULL,
    imagen VARCHAR(255),
    id_promocion INT NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES Categorias(id),
    FOREIGN KEY (id_promocion) REFERENCES Promociones(id)
);

CREATE TABLE Servicios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    categoria_id INT NOT NULL,
    descripcion TEXT,
    duracion INT NOT NULL CHECK (duracion > 0), -- minutos
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    id_promocion INT,
    FOREIGN KEY (categoria_id) REFERENCES Categorias(id),
    FOREIGN KEY (id_promocion) REFERENCES Promociones(id)
);

CREATE TABLE Citas (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    servicio_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
    FOREIGN KEY (servicio_id) REFERENCES Servicios(id)
);

CREATE TABLE Pagos_Citas (
    id SERIAL PRIMARY KEY,
    cita_id INT NOT NULL,
    fecha DATE NOT NULL,
    monto NUMERIC(10,2) NOT NULL CHECK (monto >= 0),
    metodo VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (cita_id) REFERENCES Citas(id)
);

CREATE TABLE Carrito (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);

CREATE TABLE Ordenes (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    carrito_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(50) NOT NULL,
    total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
    FOREIGN KEY (carrito_id) REFERENCES Carrito(id)
);

CREATE TABLE Pagos_Ordenes (
    id SERIAL PRIMARY KEY,
    orden_id INT NOT NULL,
    fecha DATE NOT NULL,
    monto NUMERIC(10,2) NOT NULL CHECK (monto >= 0),
    metodo VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (orden_id) REFERENCES Ordenes(id)
);

CREATE TABLE Notificaciones (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    mensaje TEXT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id)
);

/*Veificacion de correo*/
CREATE OR REPLACE FUNCTION correo_existente(p_correo VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    existe BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM Usuarios WHERE correo_electronico = p_correo
    ) INTO existe;
    RETURN existe;
END;
$$ LANGUAGE plpgsql;


/*Agregar usuario*/
CREATE OR REPLACE FUNCTION insertar_usuario(
    p_nombre VARCHAR,
    p_apellido VARCHAR,
    p_correo VARCHAR,
    p_contraseña VARCHAR,
    p_rol VARCHAR
) RETURNS TEXT AS $$
BEGIN
    INSERT INTO Usuarios(nombre, apellido, correo_electronico, contraseña, rol)
    VALUES (p_nombre, p_apellido, p_correo, p_contraseña, p_rol);
    
    RETURN 'Usuario insertado exitosamente';
EXCEPTION
    WHEN unique_violation THEN
        RETURN 'Error: El correo electrónico ya está registrado.';
    WHEN others THEN
        RETURN 'Error al insertar usuario.';
END;
$$ LANGUAGE plpgsql;

/*Obtener usuario*/
CREATE OR REPLACE FUNCTION obtener_usuario(p_correo VARCHAR)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    apellido VARCHAR,
    correo VARCHAR,
    rol VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, nombre, apellido, correo_electronico, rol FROM Usuarios WHERE correo_electronico = p_correo;
END;
$$ LANGUAGE plpgsql;

-- Citas: eliminar citas cuando se elimina un usuario
ALTER TABLE Citas DROP CONSTRAINT citas_usuario_id_fkey;
ALTER TABLE Citas ADD CONSTRAINT citas_usuario_id_fkey
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE;

-- Carrito: eliminar elementos del carrito cuando se elimina un usuario
ALTER TABLE Carrito DROP CONSTRAINT carrito_usuario_id_fkey;
ALTER TABLE Carrito ADD CONSTRAINT carrito_usuario_id_fkey
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE;

-- Ordenes: eliminar órdenes cuando se elimina un usuario
ALTER TABLE Ordenes DROP CONSTRAINT ordenes_usuario_id_fkey;
ALTER TABLE Ordenes ADD CONSTRAINT ordenes_usuario_id_fkey
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id) ON DELETE CASCADE;

-- Pagos_Citas: eliminar pagos cuando se elimina la cita
ALTER TABLE Pagos_Citas DROP CONSTRAINT pagos_citas_cita_id_fkey;
ALTER TABLE Pagos_Citas ADD CONSTRAINT pagos_citas_cita_id_fkey
    FOREIGN KEY (cita_id) REFERENCES Citas(id) ON DELETE CASCADE;

-- Pagos_Ordenes: eliminar pagos cuando se elimina la orden
ALTER TABLE Pagos_Ordenes DROP CONSTRAINT pagos_ordenes_orden_id_fkey;
ALTER TABLE Pagos_Ordenes ADD CONSTRAINT pagos_ordenes_orden_id_fkey
    FOREIGN KEY (orden_id) REFERENCES Ordenes(id) ON DELETE CASCADE;


/*Eliminar usuario*/
CREATE OR REPLACE FUNCTION eliminar_usuario(p_usuario_id INT)
RETURNS TEXT AS $$
BEGIN
    DELETE FROM Usuarios WHERE id = p_usuario_id;
    
    IF NOT FOUND THEN
        RETURN 'Usuario no encontrado.';
    END IF;

    RETURN 'Usuario y registros relacionados eliminados correctamente.';
END;
$$ LANGUAGE plpgsql;

/*Actulizar usuario*/
CREATE OR REPLACE FUNCTION actualizar_usuario(
    p_id INT,
    p_nombre VARCHAR,
    p_apellido VARCHAR,
    p_correo VARCHAR,
    p_contraseña VARCHAR,
    p_rol VARCHAR
) RETURNS TEXT AS $$
BEGIN
    UPDATE Usuarios
    SET
        nombre = p_nombre,
        apellido = p_apellido,
        correo_electronico = p_correo,
        contraseña = p_contraseña,
        rol = p_rol
    WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN 'Usuario no encontrado.';
    END IF;

    RETURN 'Usuario actualizado correctamente.';
    
EXCEPTION
    WHEN unique_violation THEN
        RETURN 'Error: El correo electrónico ya está registrado.';
    WHEN others THEN
        RETURN 'Error al actualizar usuario.';
END;
$$ LANGUAGE plpgsql;


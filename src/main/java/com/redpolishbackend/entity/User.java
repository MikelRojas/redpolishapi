package com.redpolishbackend.entity;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Usuarios")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name="nombre")
    private String name;
    @Column(name="apellido")
    private String last_name;
    @Column(name="correo_electronico", nullable = false, unique = true)
    private String email;
    @Column(name="contraseña")
    private String password;
    @Column(name="rol")
    private String rol;
}

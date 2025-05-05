package com.redpolishbackend.controller;

import com.redpolishbackend.dto.AuthResponseDto;
import com.redpolishbackend.dto.LoginRequestDto;
import com.redpolishbackend.dto.UserDto;
import com.redpolishbackend.service.AuthService;
import com.redpolishbackend.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.bind.annotation.*;

@AllArgsConstructor
@RestController
@RequestMapping("/api/users")
public class UserController {

    private UserService userService;
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<UserDto> createUser(@RequestBody UserDto userDto) {
        UserDto savedUser = userService.createUser(userDto);
        return new ResponseEntity<>(savedUser, HttpStatus.CREATED);
    }

    // Endpoint mejorado para login que genera y devuelve JWT
    @PostMapping("/sign_in")
    public ResponseEntity<AuthResponseDto> login(@RequestBody LoginRequestDto loginRequest) {
        AuthResponseDto authResponse = authService.authenticate(
                loginRequest.getEmail(),
                loginRequest.getPassword()
        );
        return ResponseEntity.ok(authResponse);
    }

    // Endpoint para obtener usuario por email
    @GetMapping("/{email}")
    public ResponseEntity<UserDto> getUserByEmail(@PathVariable("email") String userEmail) {
        UserDto userDto = userService.getUserByEmail(userEmail);
        return ResponseEntity.ok(userDto);
    }

    // Endpoint protegido con JWT: actualización de usuario
    @PutMapping("/update")
    public ResponseEntity<UserDto> updateUser(@RequestBody UserDto userDto,
                                               @RequestHeader("Authorization") String token) {
        // El correo del usuario se extrae desde el JWT
        String userEmail = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        UserDto updatedUser = userService.updateUser(userEmail, userDto);
        return ResponseEntity.ok(updatedUser);
    }
}

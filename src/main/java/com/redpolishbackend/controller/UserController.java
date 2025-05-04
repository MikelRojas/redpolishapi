package com.redpolishbackend.controller;

import com.redpolishbackend.dto.UserDto;
import com.redpolishbackend.service.UserService;
import lombok.AllArgsConstructor;
import org.apache.coyote.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@AllArgsConstructor
@RestController
@RequestMapping("/api/users")
public class UserController {

    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<UserDto> createUser(@RequestBody UserDto userDto) {
        System.out.println(userDto.getName());
        UserDto savedUser = userService.createUser(userDto);
        return new ResponseEntity<>(savedUser, HttpStatus.CREATED);
    }

    @GetMapping("/sign_in/{email}")
    public ResponseEntity<UserDto> getUserByEmail(@PathVariable("email") String userEmail) {
        UserDto userDto = userService.getUserByEmail(userEmail);
        return  ResponseEntity.ok(userDto);
    }

}

package com.redpolishbackend.service.impl;

import com.redpolishbackend.dto.UserDto;
import com.redpolishbackend.entity.User;
import com.redpolishbackend.exception.ResourceNotFoundException;
import com.redpolishbackend.mapper.UserMapper;
import com.redpolishbackend.repository.UserRepository;
import com.redpolishbackend.service.UserService;
import com.redpolishbackend.utils.PasswordUtils;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Example;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService {

    private UserRepository userRepository;

    @Override
    public UserDto createUser(UserDto userDto) {
        User user = UserMapper.maptoUser(userDto);
        user.setPassword(PasswordUtils.hashPassword(user.getPassword()));
        User saveUser = userRepository.save(user);
        return UserMapper.maptoUserDto(saveUser);
    }

    @Override
    public UserDto getUserByEmail(String email) {
        User userExample = new User();
        userExample.setEmail(email);

        // Creamos el Example con el objeto de ejemplo
        Example<User> example = Example.of(userExample);

        // Usamos findBy con la función que devuelve un único resultado (o null)
        User user = userRepository.findBy(example, query -> query.first().orElse(null));
        if (user == null) {
            throw new ResourceNotFoundException("User with email " + email + " not found");
        }
        return UserMapper.maptoUserDto(user);
    }

    @Override
    public UserDto updateUser(String email, UserDto userDto) {
        User userExample = new User();
        userExample.setEmail(email);

        Example<User> example = Example.of(userExample);

        User userToUpdate = userRepository.findBy(example, query -> query.first().orElse(null));
        if (userToUpdate == null) {
            throw new ResourceNotFoundException("User with email " + email + " not found");
        }

        userToUpdate.setName(userDto.getName());
        userToUpdate.setLast_name(userDto.getLast_name());
        //userUpdated.setPassword(userDto.getPassword());

        User updatedUserObj = userRepository.save(userToUpdate);

        return UserMapper.maptoUserDto(updatedUserObj);
    }
}

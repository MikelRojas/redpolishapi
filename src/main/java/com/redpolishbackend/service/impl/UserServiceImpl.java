package com.redpolishbackend.service.impl;

import com.redpolishbackend.dto.UserDto;
import com.redpolishbackend.entity.User;
import com.redpolishbackend.mapper.UserMapper;
import com.redpolishbackend.repository.UserRepository;
import com.redpolishbackend.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService {

    private UserRepository userRepository;

    @Override
    public UserDto createUser(UserDto userDto) {
        User user = UserMapper.maptoUser(userDto);
        User saveUser = userRepository.save(user);
        return UserMapper.maptoUserDto(saveUser);
    }
}

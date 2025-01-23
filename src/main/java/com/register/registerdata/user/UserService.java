package com.register.registerdata.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public User registerUser(String username, String email){
        User user = new User();
        user.setUsername("Patrick");
        user.setEmail("test@example.com");
        return userRepository.save(user);
    }
}

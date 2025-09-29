package com.littlelotus.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.ui.Model;

@Controller
@RequestMapping("/admin") 
public class AdminController {

    @GetMapping("/product")
    public String productManagement(Model model) 
    {
        model.addAttribute("pageTitle", "Quản lý Sản Phẩm");
        model.addAttribute("pageName", "product"); 
        model.addAttribute("contentPage", "product_manage.jsp"); 
        return "admin/admin_layout"; 
    }
    
    @GetMapping("/category")
    public String categoryManagement(Model model) 
    {
        model.addAttribute("pageTitle", "Quản lý Danh Mục");
        model.addAttribute("pageName", "category");
        model.addAttribute("contentPage", "category_manage.jsp");
        return "admin/admin_layout";
    }
    
    @GetMapping("/user")
    public String userManagement(Model model) 
    {
        model.addAttribute("pageTitle", "Quản lý Người Dùng");
        model.addAttribute("pageName", "user");
        model.addAttribute("contentPage", "user_manage.jsp");
        return "admin/admin_layout";
    }
}
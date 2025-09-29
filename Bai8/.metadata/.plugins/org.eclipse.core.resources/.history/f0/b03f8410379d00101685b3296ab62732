package com.littlelotus.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable; 
import org.springframework.ui.Model; 

@Controller
public class WebController 
{

    @GetMapping("/")
    public String home(Model model) 
    {
        model.addAttribute("pageTitle", "Trang Chủ");
        model.addAttribute("contentPage", "index.jsp"); 
        return "web/web_layout"; 
    }
    
    @GetMapping("/product/{id}")
    public String productDetail(@PathVariable Long id, Model model) 
    {
        model.addAttribute("pageTitle", "Chi Tiết Sản Phẩm");
        model.addAttribute("productId", id); 
        model.addAttribute("contentPage", "product_detail.jsp"); 
        return "web/web_layout"; 
    }
}
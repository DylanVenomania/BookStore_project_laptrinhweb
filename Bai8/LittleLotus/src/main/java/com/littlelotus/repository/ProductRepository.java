package com.littlelotus.repository;

import com.littlelotus.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> 
{
    // 1. Hiển thị tất cả product có giá từ thấp đến cao
    List<Product> findAllByOrderByPriceAsc();

    // 2. Lấy tất cả product của 01 category
    List<Product> findByCategory_Id(Long categoryId);
}
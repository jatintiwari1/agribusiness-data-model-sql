-- ============================================================
-- AGRIBUSINESS RELATIONAL DATA MODEL - SCHEMA
-- MySQL Dialect
-- ============================================================

CREATE TABLE Farm (
    farm_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_name VARCHAR(100) NOT NULL,
    location VARCHAR(150),
    area_hectares DECIMAL(10,2),
    owner_name VARCHAR(100),
    established_date DATE
);

CREATE TABLE Field (
    field_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_id INT NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    area_hectares DECIMAL(10,2),
    soil_type VARCHAR(50),
    CONSTRAINT fk_field_farm
        FOREIGN KEY (farm_id)
        REFERENCES Farm(farm_id)
        ON DELETE CASCADE
);

CREATE TABLE Crop (
    crop_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL,
    crop_type VARCHAR(50),
    growing_season VARCHAR(50)
);

CREATE TABLE Employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_id INT NOT NULL,
    employee_name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    hire_date DATE,
    wage_rate DECIMAL(8,2),
    CONSTRAINT fk_employee_farm
        FOREIGN KEY (farm_id)
        REFERENCES Farm(farm_id)
        ON DELETE CASCADE
);

CREATE TABLE Equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_id INT NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_type VARCHAR(50),
    purchase_date DATE,
    CONSTRAINT fk_equipment_farm
        FOREIGN KEY (farm_id)
        REFERENCES Farm(farm_id)
        ON DELETE CASCADE
);

CREATE TABLE Supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_type VARCHAR(50),
    contact_info VARCHAR(150)
);

CREATE TABLE Input_Purchase (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    farm_id INT NOT NULL,
    item_name VARCHAR(100),
    item_type VARCHAR(50),
    quantity DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    purchase_date DATE,
    CONSTRAINT fk_purchase_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES Supplier(supplier_id),
    CONSTRAINT fk_purchase_farm
        FOREIGN KEY (farm_id)
        REFERENCES Farm(farm_id)
);

CREATE TABLE Market (
    market_id INT AUTO_INCREMENT PRIMARY KEY,
    market_name VARCHAR(100) NOT NULL,
    location VARCHAR(150)
);

CREATE TABLE Planting (
    planting_id INT AUTO_INCREMENT PRIMARY KEY,
    field_id INT NOT NULL,
    crop_id INT NOT NULL,
    planting_date DATE NOT NULL,
    expected_harvest_date DATE,
    seed_quantity_kg DECIMAL(10,2),
    CONSTRAINT fk_planting_field
        FOREIGN KEY (field_id)
        REFERENCES Field(field_id),
    CONSTRAINT fk_planting_crop
        FOREIGN KEY (crop_id)
        REFERENCES Crop(crop_id)
);

CREATE TABLE Harvest (
    harvest_id INT AUTO_INCREMENT PRIMARY KEY,
    planting_id INT NOT NULL,
    harvest_date DATE NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL,
    quality_grade VARCHAR(20),
    CONSTRAINT fk_harvest_planting
        FOREIGN KEY (planting_id)
        REFERENCES Planting(planting_id)
);

CREATE TABLE Labor (
    labor_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    planting_id INT NOT NULL,
    work_date DATE NOT NULL,
    hours_worked DECIMAL(5,2),
    activity_type VARCHAR(50),
    CONSTRAINT fk_labor_employee
        FOREIGN KEY (employee_id)
        REFERENCES Employee(employee_id),
    CONSTRAINT fk_labor_planting
        FOREIGN KEY (planting_id)
        REFERENCES Planting(planting_id)
);

CREATE TABLE Equipment_Usage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_id INT NOT NULL,
    planting_id INT NOT NULL,
    usage_date DATE NOT NULL,
    hours_used DECIMAL(5,2),
    CONSTRAINT fk_usage_equipment
        FOREIGN KEY (equipment_id)
        REFERENCES Equipment(equipment_id),
    CONSTRAINT fk_usage_planting
        FOREIGN KEY (planting_id)
        REFERENCES Planting(planting_id)
);

CREATE TABLE Sale (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    harvest_id INT NOT NULL,
    market_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity_sold_kg DECIMAL(10,2) NOT NULL,
    price_per_kg DECIMAL(8,2) NOT NULL,
    buyer_name VARCHAR(100),
    CONSTRAINT fk_sale_harvest
        FOREIGN KEY (harvest_id)
        REFERENCES Harvest(harvest_id),
    CONSTRAINT fk_sale_market
        FOREIGN KEY (market_id)
        REFERENCES Market(market_id)
);

CREATE TABLE Price_History (
    price_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    market_id INT NOT NULL,
    price_date DATE NOT NULL,
    price_per_kg DECIMAL(8,2) NOT NULL,
    CONSTRAINT fk_price_crop
        FOREIGN KEY (crop_id)
        REFERENCES Crop(crop_id),
    CONSTRAINT fk_price_market
        FOREIGN KEY (market_id)
        REFERENCES Market(market_id)
);

CREATE TABLE Weather_Log (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_id INT NOT NULL,
    record_date DATE NOT NULL,
    temperature_c DECIMAL(5,2),
    rainfall_mm DECIMAL(6,2),
    CONSTRAINT fk_weather_farm
        FOREIGN KEY (farm_id)
        REFERENCES Farm(farm_id)
);

CREATE TABLE Expense (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_id INT NOT NULL,
    category VARCHAR(50),
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    description VARCHAR(200),
    CONSTRAINT fk_expense_farm
        FOREIGN KEY (farm_id)
        REFERENCES Farm(farm_id)
);

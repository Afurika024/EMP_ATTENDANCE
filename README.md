

---

# Employee Attendance Management System

## Overview

The Employee Attendance Management System is designed to track employee attendance records in a structured way. It provides functionality to count and analyze attendance based on specified dates and statuses (e.g., Present or Absent). This system includes:

- A table to store employee information.
- A table to log attendance records.
- A function to retrieve attendance counts.
- A procedure to analyze and display attendance statistics for employees by month and year.

## Prerequisites

To run this project, you will need:

- Oracle Database (or compatible database system)
- SQL Developer or any SQL command-line interface

## Table Structure

### Employees Table

The `employees` table stores information about employees, including their unique ID, first name, and last name.

```sql
-- SQL Code to create Employees Table
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
);
```

### Attendance Table

The `attendance` table logs attendance records, linking each record to an employee and storing the date and attendance status.

```sql
-- SQL Code to create Attendance Table
CREATE TABLE attendance (
    attendance_id NUMBER PRIMARY KEY,
    employee_id NUMBER,
    attendance_date DATE,
    status VARCHAR2(10),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

## Function to Get Attendance Status

The `get_attendance_status` function retrieves the count of attendance records for a specific employee, date, and status.

```sql
-- SQL Code for the function get_attendance_status
CREATE OR REPLACE FUNCTION get_attendance_status(
    p_emp_id NUMBER,
    p_date DATE,
    p_status VARCHAR2
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM attendance
    WHERE employee_id = p_emp_id
      AND status = p_status
      AND attendance_date = TRUNC(p_date);  -- Ensure only the date part is considered

    RETURN v_count;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in function get_attendance_status: ' || SQLERRM);
        RETURN 0;
END get_attendance_status;
```

## Procedure to Analyze Attendance

The `analyze_attendance_with_while` procedure calculates and displays attendance statistics for all employees for a specified month and year.

```sql
-- SQL Code for the procedure analyze_attendance_with_while
CREATE OR REPLACE PROCEDURE analyze_attendance_with_while(p_month IN NUMBER, p_year IN NUMBER) IS
    -- Variables for employee details
    v_employee_id NUMBER;
    v_first_name VARCHAR2(50);
    v_last_name VARCHAR2(50);
    
    -- Variables for attendance counts and calculations
    v_total_presents NUMBER := 0;
    v_total_absents NUMBER := 0;
    v_attendance_percentage NUMBER := 0;
    v_total_days_in_month NUMBER;

    -- Variables to track dates
    v_current_date DATE;
    v_start_date DATE := TO_DATE(p_year || '-' || p_month || '-01', 'YYYY-MM-DD');
    v_end_date DATE := LAST_DAY(v_start_date);

BEGIN
    v_total_days_in_month := TO_NUMBER(TO_CHAR(v_end_date, 'DD'));

    FOR emp_rec IN (SELECT employee_id, first_name, last_name FROM employees) LOOP
        v_employee_id := emp_rec.employee_id;
        v_first_name := emp_rec.first_name;
        v_last_name := emp_rec.last_name;

        v_total_presents := 0;
        v_total_absents := 0;

        v_current_date := v_start_date;

        WHILE v_current_date <= v_end_date LOOP
            v_total_presents := v_total_presents + get_attendance_status(v_employee_id, v_current_date, 'Present');
            v_total_absents := v_total_absents + get_attendance_status(v_employee_id, v_current_date, 'Absent');
            v_current_date := v_current_date + 1;
        END LOOP;

        IF v_total_presents + v_total_absents > 0 THEN
            v_attendance_percentage := (v_total_presents / v_total_days_in_month) * 100;
            DBMS_OUTPUT.PUT_LINE('Employee: ' || v_first_name || ' ' || v_last_name);
            DBMS_OUTPUT.PUT_LINE('Total Presents: ' || v_total_presents);
            DBMS_OUTPUT.PUT_LINE('Total Absents: ' || v_total_absents);
            DBMS_OUTPUT.PUT_LINE('Attendance Percentage: ' || ROUND(v_attendance_percentage, 2) || '%');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Employee: ' || v_first_name || ' ' || v_last_name || ' has no attendance records for the specified month.');
        END IF;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred in analyze_attendance_with_while: ' || SQLERRM);
END analyze_attendance_with_while;
```

## Usage

1. Create the `employees` and `attendance` tables by running the provided SQL code.
2. Insert employee and attendance records into the respective tables.
3. Call the `analyze_attendance_with_while` procedure, passing the desired month and year to analyze attendance for that period.

```sql
-- Example of calling the procedure
BEGIN
    analyze_attendance_with_while(10, 2024); -- Analyzes attendance for October 2024
END;
```

## Conclusion

This project provides a comprehensive solution for managing employee attendance. You can further extend its functionality by adding features such as reporting, integration with other systems, or web interfaces for user interaction.

---

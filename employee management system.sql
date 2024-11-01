
CREATE OR REPLACE PROCEDURE analyze_attendance_with_function(p_month IN NUMBER, p_year IN NUMBER) IS
    -- Variables for employee details
    v_employee_id NUMBER;
    v_first_name VARCHAR2(50);
    v_last_name VARCHAR2(50);
    
    
    -- Variables for attendance counts and calculations
    v_total_presents NUMBER := 0;
    v_total_absents NUMBER := 0;
    v_attendance_percentage NUMBER := 0;
    v_total_days_in_month NUMBER;

    -- Calculate the first and last day of the month for date range checking
    v_start_date DATE := TO_DATE(p_year || '-' || p_month || '-01', 'YYYY-MM-DD');
    v_end_date DATE := LAST_DAY(v_start_date);

BEGIN
    -- Calculate the total number of days in the specified month
    v_total_days_in_month := TO_NUMBER(TO_CHAR(v_end_date, 'DD'));

    -- Main loop to go through each employee
    FOR emp_rec IN (SELECT employee_id, first_name, last_name FROM employees) LOOP
        v_employee_id := emp_rec.employee_id;
        v_first_name := emp_rec.first_name;
        v_last_name := emp_rec.last_name;

        -- Initialize counters for this employee
        v_total_presents := 0;
        v_total_absents := 0;

        -- Count 'Present' days using a WHILE loop
        WHILE v_total_presents < v_total_days_in_month LOOP
            SELECT COUNT(*) INTO v_total_presents
            FROM attendance
            WHERE employee_id = v_employee_id
              AND status = 'Present'
              AND attendance_date BETWEEN v_start_date AND v_end_date;

            -- Exit the loop if we have counted all present days
            EXIT WHEN v_total_presents > 0;
        END LOOP;

        -- Count 'Absent' days similarly
        WHILE v_total_absents < v_total_days_in_month LOOP
            SELECT COUNT(*) INTO v_total_absents
            FROM attendance
            WHERE employee_id = v_employee_id
              AND status = 'Absent'
              AND attendance_date BETWEEN v_start_date AND v_end_date;

            -- Exit the loop if we have counted all absent days
            EXIT WHEN v_total_absents > 0;
        END LOOP;

        -- Calculate and display the attendance details
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
        DBMS_OUTPUT.PUT_LINE('An error occurred in analyze_attendance_with_function: ' || SQLERRM);
END analyze_attendance_with_function;

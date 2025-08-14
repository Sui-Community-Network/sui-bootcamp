// =========================================
// SUI MOVE COLLECTIONS - EDUCATIONAL TUTORIAL
// Learning Collections Through a School Management System
// =========================================

module school::collections_tutorial {
    use sui::object::{Self, UID, ID};
    use sui::bag::{Self, Bag};
    use sui::object_bag::{Self, ObjectBag};
    use sui::table::{Self, Table};
    use sui::object_table::{Self, ObjectTable};
    use sui::linked_table::{Self, LinkedTable};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::String;
    use std::vector;

    // =========================================
    // 📚 CHAPTER 1: UNDERSTANDING COLLECTIONS
    // =========================================
    /*
    🎯 WHAT ARE COLLECTIONS?
    Collections are data structures that hold multiple items. Think of them as
    different types of storage containers, each optimized for specific use cases.

    🏫 OUR SCHOOL ANALOGY:
    Imagine you're organizing a school. You need different storage solutions:
    - A filing cabinet for mixed documents (BAG)
    - A trophy case for valuable items (OBJECT BAG) 
    - A student directory for quick lookups (TABLE)
    - A classroom assignment board (OBJECT TABLE)
    - A ranked honor roll list (LINKED TABLE)

    Each collection type serves a different organizational need!
    */

    // Basic entities for our examples
    struct School has key {
        id: UID,
        name: String,
    }

    struct Student has key, store {
        id: UID,
        name: String,
        grade: u8,
        gpa: u64, // GPA * 100 (e.g., 350 = 3.50)
    }

    struct Teacher has key, store {
        id: UID,
        name: String,
        subject: String,
        years_experience: u8,
    }

    struct Certificate has key, store {
        id: UID,
        title: String,
        recipient: String,
        year: u16,
    }

    // =========================================
    // 📁 CHAPTER 2: BAG - THE VERSATILE FILING CABINET
    // =========================================
    /*
    🗃️ WHAT IS A BAG?
    A Bag is like a filing cabinet where you can store ANY type of data that has
    the 'store' ability. Each item is identified by a unique key.

    📋 KEY CHARACTERISTICS:
    ✅ Stores heterogeneous data (different types)
    ✅ Key-value storage with any copyable key type  
    ✅ Values must have 'store' ability
    ✅ Dynamic - add/remove items at runtime
    ❌ No fast lookup optimization
    ❌ Keys must be copyable (no objects as keys)

    🎓 LEARNING OBJECTIVES:
    - Understand when to use Bags vs other collections
    - Learn all Bag operations: add, borrow, remove, contains
    - Practice with different data types
    - Handle optional values safely
    */

    struct SchoolConfig has key {
        id: UID,
        name: String,
        settings: Bag, // Our filing cabinet for mixed school data
    }

    // 🔧 BAG OPERATIONS TUTORIAL

    // CREATE: Initialize an empty bag
    public fun create_school_config(name: String, ctx: &mut TxContext) {
        let school = SchoolConfig {
            id: object::new(ctx),
            name,
            settings: bag::new(ctx), // Creates empty bag
        };
        transfer::transfer(school, tx_context::sender(ctx));
    }

    // ADD: Store different types of data
    public fun setup_school_settings(school: &mut SchoolConfig) {
        let settings = &mut school.settings;
        
        // Store primitive types
        bag::add(settings, b"max_students", 1000u32);
        bag::add(settings, b"tuition_fee", 25000u64);
        bag::add(settings, b"school_motto", b"Excellence Through Learning".to_string());
        bag::add(settings, b"is_accredited", true);
        
        // Store complex types
        let subjects = vector[
            b"Mathematics".to_string(),
            b"Science".to_string(),
            b"Literature".to_string(),
            b"History".to_string()
        ];
        bag::add(settings, b"available_subjects", subjects);
        
        // Store custom structs (must have 'store' ability)
        let semester_dates = SemesterDates {
            start_month: 9,
            end_month: 5,
            break_weeks: 2,
        };
        bag::add(settings, b"semester_info", semester_dates);
    }

    struct SemesterDates has store {
        start_month: u8,
        end_month: u8,
        break_weeks: u8,
    }

    // CONTAINS: Check if a key exists (always do this before borrowing!)
    public fun has_setting(school: &SchoolConfig, key: String): bool {
        bag::contains(&school.settings, key)
    }

    // BORROW: Read data (immutable reference)
    public fun get_max_students(school: &SchoolConfig): u32 {
        // IMPORTANT: Always check existence first!
        if (bag::contains(&school.settings, b"max_students".to_string())) {
            // Dereference the borrowed value
            *bag::borrow(&school.settings, b"max_students".to_string())
        } else {
            0 // Safe default
        }
    }

    // BORROW_MUT: Modify data in place
    public fun update_tuition_fee(school: &mut SchoolConfig, new_fee: u64) {
        if (bag::contains(&school.settings, b"tuition_fee".to_string())) {
            let fee_ref = bag::borrow_mut(&mut school.settings, b"tuition_fee".to_string());
            *fee_ref = new_fee; // Update the value
        }
    }

    // REMOVE: Take ownership of stored data
    public fun remove_setting(school: &mut SchoolConfig, key: String): bool {
        if (bag::contains(&school.settings, key)) {
            // Remove and get the value (you own it now)
            let _removed_value: bool = bag::remove(&mut school.settings, key);
            true
        } else {
            false
        }
    }

    // 🎯 BAG BEST PRACTICES EXAMPLE
    public fun demonstrate_bag_patterns(school: &mut SchoolConfig) {
        // Pattern 1: Safe optional access
        let student_count = if (bag::contains(&school.settings, b"current_students".to_string())) {
            *bag::borrow(&school.settings, b"current_students".to_string())
        } else {
            bag::add(&mut school.settings, b"current_students".to_string(), 0u32);
            0u32
        };

        // Pattern 2: Conditional updates
        if (bag::contains(&school.settings, b"enrollment_open".to_string())) {
            let is_open = bag::borrow_mut(&mut school.settings, b"enrollment_open".to_string());
            *is_open = student_count < get_max_students(school);
        };
    }

    // =========================================
    // 🏆 CHAPTER 3: OBJECT BAG - THE TROPHY CASE
    // =========================================
    /*
    🏆 WHAT IS AN OBJECT BAG?
    An Object Bag is like a trophy case where you store valuable objects that
    can be individually transferred or owned. Each object has 'key + store' abilities.

    📋 KEY CHARACTERISTICS:  
    ✅ Stores heterogeneous objects (different struct types)
    ✅ Objects can be removed and transferred individually
    ✅ Objects must have 'key + store' abilities
    ✅ Perfect for collections of valuable/transferable items
    ❌ No fast lookup optimization
    ❌ Only objects (not primitive types)

    🎓 LEARNING OBJECTIVES:
    - Distinguish between storing data vs objects
    - Practice object lifecycle management
    - Understand when objects should be transferable
    - Learn object ownership patterns
    */

    struct SchoolTreasury has key {
        id: UID,
        name: String,
        valuables: ObjectBag, // Our trophy case for important objects
    }

    // 🔧 OBJECT BAG OPERATIONS TUTORIAL

    // CREATE: Initialize with empty object bag
    public fun create_school_treasury(name: String, ctx: &mut TxContext) {
        let treasury = SchoolTreasury {
            id: object::new(ctx),
            name,
            valuables: object_bag::new(ctx),
        };
        transfer::transfer(treasury, tx_context::sender(ctx));
    }

    // Helper functions to create objects
    public fun create_student(name: String, grade: u8, gpa: u64, ctx: &mut TxContext): Student {
        Student {
            id: object::new(ctx),
            name,
            grade, 
            gpa,
        }
    }

    public fun create_certificate(title: String, recipient: String, year: u16, ctx: &mut TxContext): Certificate {
        Certificate {
            id: object::new(ctx),
            title,
            recipient,
            year,
        }
    }

    // ADD: Store different types of objects
    public fun store_school_valuables(
        treasury: &mut SchoolTreasury,
        star_student: Student,
        achievement_cert: Certificate,
        principal: Teacher
    ) {
        // Store different object types with descriptive keys
        object_bag::add(&mut treasury.valuables, b"student_of_year".to_string(), star_student);
        object_bag::add(&mut treasury.valuables, b"national_award".to_string(), achievement_cert);
        object_bag::add(&mut treasury.valuables, b"school_principal".to_string(), principal);
    }

    // CONTAINS: Check object existence
    public fun has_award(treasury: &SchoolTreasury, award_key: String): bool {
        object_bag::contains(&treasury.valuables, award_key)
    }

    // BORROW: Inspect objects without taking ownership
    public fun get_student_of_year_gpa(treasury: &SchoolTreasury): u64 {
        if (object_bag::contains(&treasury.valuables, b"student_of_year".to_string())) {
            let student: &Student = object_bag::borrow(&treasury.valuables, b"student_of_year".to_string());
            student.gpa
        } else {
            0
        }
    }

    // BORROW_MUT: Modify objects in place
    public fun update_student_gpa(treasury: &mut SchoolTreasury, new_gpa: u64) {
        if (object_bag::contains(&treasury.valuables, b"student_of_year".to_string())) {
            let student: &mut Student = object_bag::borrow_mut(&mut treasury.valuables, b"student_of_year".to_string());
            student.gpa = new_gpa;
        }
    }

    // REMOVE: Extract object for transfer or individual ownership
    public fun award_student_of_year(treasury: &mut SchoolTreasury, recipient: address) {
        if (object_bag::contains(&treasury.valuables, b"student_of_year".to_string())) {
            // Remove object from bag and transfer to recipient
            let student: Student = object_bag::remove(&mut treasury.valuables, b"student_of_year".to_string());
            transfer::transfer(student, recipient);
        }
    }

    // 🎯 OBJECT BAG BEST PRACTICES
    public fun demonstrate_object_lifecycle(treasury: &mut SchoolTreasury, ctx: &mut TxContext) {
        // Pattern 1: Conditional object creation and storage
        if (!object_bag::contains(&treasury.valuables, b"backup_principal".to_string())) {
            let backup = Teacher {
                id: object::new(ctx),
                name: b"Dr. Smith".to_string(),
                subject: b"Administration".to_string(),
                years_experience: 15,
            };
            object_bag::add(&mut treasury.valuables, b"backup_principal".to_string(), backup);
        };

        // Pattern 2: Object rotation/replacement
        if (object_bag::contains(&treasury.valuables, b"old_certificate".to_string())) {
            let old_cert: Certificate = object_bag::remove(&mut treasury.valuables, b"old_certificate".to_string());
            // Could transfer old_cert or let it be dropped
            
            let new_cert = Certificate {
                id: object::new(ctx),
                title: b"Excellence Award 2024".to_string(),
                recipient: b"Springfield High".to_string(),
                year: 2024,
            };
            object_bag::add(&mut treasury.valuables, b"current_certificate".to_string(), new_cert);
        };
    }

    // =========================================
    // 📊 CHAPTER 4: TABLE - THE STUDENT DIRECTORY
    // =========================================
    /*
    📊 WHAT IS A TABLE?
    A Table is like a high-speed student directory. It provides O(1) lookup time
    for finding specific information by key. All values must be the same type.

    📋 KEY CHARACTERISTICS:
    ✅ Homogeneous values (all same type)
    ✅ O(1) lookup performance (super fast!)
    ✅ Optimized for frequent reads/updates
    ✅ Memory efficient for large datasets
    ❌ All values must be identical type
    ❌ No ordering guarantees

    🎓 LEARNING OBJECTIVES:
    - Understand when speed matters most
    - Learn efficient bulk operations
    - Practice type consistency requirements
    - Optimize for read-heavy workloads
    */

    struct StudentDirectory has key {
        id: UID,
        school_name: String,
        // Fast lookup tables for different student data
        student_grades: Table<u64, u8>,     // student_id -> current_grade
        student_gpas: Table<u64, u64>,      // student_id -> gpa
        student_attendance: Table<u64, u8>, // student_id -> attendance_percentage
        enrollment_years: Table<u64, u16>,  // student_id -> year_enrolled
    }

    // 🔧 TABLE OPERATIONS TUTORIAL

    // CREATE: Initialize with empty tables
    public fun create_student_directory(school_name: String, ctx: &mut TxContext) {
        let directory = StudentDirectory {
            id: object::new(ctx),
            school_name,
            student_grades: table::new(ctx),
            student_gpas: table::new(ctx),
            student_attendance: table::new(ctx),
            enrollment_years: table::new(ctx),
        };
        transfer::transfer(directory, tx_context::sender(ctx));
    }

    // ADD: Store student information (all values same type per table)
    public fun enroll_new_student(
        directory: &mut StudentDirectory,
        student_id: u64,
        grade: u8,
        gpa: u64,
        attendance: u8,
        enrollment_year: u16
    ) {
        // Add to each specialized table
        table::add(&mut directory.student_grades, student_id, grade);
        table::add(&mut directory.student_gpas, student_id, gpa);
        table::add(&mut directory.student_attendance, student_id, attendance);
        table::add(&mut directory.enrollment_years, student_id, enrollment_year);
    }

    // CONTAINS: Check student existence (O(1) speed!)
    public fun is_student_enrolled(directory: &StudentDirectory, student_id: u64): bool {
        table::contains(&directory.student_grades, student_id)
    }

    // BORROW: Fast data retrieval (O(1) speed!)
    public fun get_student_grade(directory: &StudentDirectory, student_id: u64): u8 {
        if (table::contains(&directory.student_grades, student_id)) {
            *table::borrow(&directory.student_grades, student_id)
        } else {
            0 // Student not found
        }
    }

    public fun get_student_gpa(directory: &StudentDirectory, student_id: u64): u64 {
        if (table::contains(&directory.student_gpas, student_id)) {
            *table::borrow(&directory.student_gpas, student_id)
        } else {
            0
        }
    }

    // BORROW_MUT: Fast updates (O(1) speed!)
    public fun update_student_grade(
        directory: &mut StudentDirectory,
        student_id: u64,
        new_grade: u8
    ) {
        if (table::contains(&directory.student_grades, student_id)) {
            let grade_ref = table::borrow_mut(&mut directory.student_grades, student_id);
            *grade_ref = new_grade;
        }
    }

    public fun improve_attendance(
        directory: &mut StudentDirectory,
        student_id: u64,
        improvement: u8
    ) {
        if (table::contains(&directory.student_attendance, student_id)) {
            let attendance_ref = table::borrow_mut(&mut directory.student_attendance, student_id);
            *attendance_ref = if (*attendance_ref + improvement > 100) {
                100
            } else {
                *attendance_ref + improvement
            };
        }
    }

    // REMOVE: Graduate/transfer students
    public fun graduate_student(directory: &mut StudentDirectory, student_id: u64): (u8, u64) {
        assert!(table::contains(&directory.student_grades, student_id), 1);
        
        // Remove from all tables and return final stats
        let final_grade = table::remove(&mut directory.student_grades, student_id);
        let final_gpa = table::remove(&mut directory.student_gpas, student_id);
        let _attendance = table::remove(&mut directory.student_attendance, student_id);
        let _enrollment_year = table::remove(&mut directory.enrollment_years, student_id);
        
        (final_grade, final_gpa)
    }

    // 🎯 TABLE PERFORMANCE PATTERNS
    public fun demonstrate_table_efficiency(directory: &mut StudentDirectory) {
        // Pattern 1: Batch lookups (each lookup is O(1))
        let student_ids = vector[1001, 1002, 1003, 1004, 1005];
        let mut total_gpa = 0u64;
        let mut count = 0u64;
        
        let mut i = 0;
        while (i < vector::length(&student_ids)) {
            let id = *vector::borrow(&student_ids, i);
            if (table::contains(&directory.student_gpas, id)) {
                total_gpa = total_gpa + *table::borrow(&directory.student_gpas, id);
                count = count + 1;
            };
            i = i + 1;
        };
        
        // Calculate average efficiently
        if (count > 0) {
            let _average_gpa = total_gpa / count;
        };

        // Pattern 2: Conditional bulk updates
        i = 0;
        while (i < vector::length(&student_ids)) {
            let id = *vector::borrow(&student_ids, i);
            if (table::contains(&directory.student_attendance, id)) {
                let attendance = table::borrow_mut(&mut directory.student_attendance, id);
                if (*attendance > 95) {
                    // Reward excellent attendance
                    let gpa = table::borrow_mut(&mut directory.student_gpas, id);
                    *gpa = *gpa + 5; // Small GPA bonus
                }
            };
            i = i + 1;
        };
    }

    // =========================================
    // 🏫 CHAPTER 5: OBJECT TABLE - CLASSROOM ASSIGNMENTS
    // =========================================
    /*
    🏫 WHAT IS AN OBJECT TABLE?
    An Object Table combines the speed of Table with object storage. Perfect
    for scenarios where you need fast lookup of objects that might be transferred.

    📋 KEY CHARACTERISTICS:
    ✅ Homogeneous objects (all same object type)
    ✅ O(1) lookup performance
    ✅ Objects can be removed and transferred
    ✅ Objects must have 'key + store' abilities
    ❌ All objects must be same type
    ❌ No ordering guarantees

    🎓 LEARNING OBJECTIVES:
    - Combine fast lookups with object management
    - Practice object assignment and reassignment
    - Understand when objects need to be transferable
    - Learn resource management patterns
    */

    struct ClassroomManager has key {
        id: UID,
        school_name: String,
        teacher_assignments: ObjectTable<u64, Teacher>, // room_number -> teacher
        student_lockers: ObjectTable<u64, Student>,     // locker_number -> student
    }

    // 🔧 OBJECT TABLE OPERATIONS TUTORIAL

    // CREATE: Initialize with empty object tables
    public fun create_classroom_manager(school_name: String, ctx: &mut TxContext) {
        let manager = ClassroomManager {
            id: object::new(ctx),
            school_name,
            teacher_assignments: object_table::new(ctx),
            student_lockers: object_table::new(ctx),
        };
        transfer::transfer(manager, tx_context::sender(ctx));
    }

    // Helper to create teacher objects
    public fun create_teacher(
        name: String,
        subject: String,
        years_experience: u8,
        ctx: &mut TxContext
    ): Teacher {
        Teacher {
            id: object::new(ctx),
            name,
            subject,
            years_experience,
        }
    }

    // ADD: Assign objects to keys (O(1) performance)
    public fun assign_teacher_to_room(
        manager: &mut ClassroomManager,
        room_number: u64,
        teacher: Teacher
    ) {
        object_table::add(&mut manager.teacher_assignments, room_number, teacher);
    }

    public fun assign_student_locker(
        manager: &mut ClassroomManager,
        locker_number: u64,
        student: Student
    ) {
        object_table::add(&mut manager.student_lockers, locker_number, student);
    }

    // CONTAINS: Quick existence check (O(1))
    public fun is_room_assigned(manager: &ClassroomManager, room_number: u64): bool {
        object_table::contains(&manager.teacher_assignments, room_number)
    }

    public fun is_locker_taken(manager: &ClassroomManager, locker_number: u64): bool {
        object_table::contains(&manager.student_lockers, locker_number)
    }

    // BORROW: Inspect objects without ownership (O(1))
    public fun get_room_teacher_subject(manager: &ClassroomManager, room_number: u64): String {
        if (object_table::contains(&manager.teacher_assignments, room_number)) {
            let teacher = object_table::borrow(&manager.teacher_assignments, room_number);
            teacher.subject
        } else {
            b"No teacher assigned".to_string()
        }
    }

    public fun get_locker_student_grade(manager: &ClassroomManager, locker_number: u64): u8 {
        if (object_table::contains(&manager.student_lockers, locker_number)) {
            let student = object_table::borrow(&manager.student_lockers, locker_number);
            student.grade
        } else {
            0
        }
    }

    // BORROW_MUT: Modify objects in place (O(1))
    public fun promote_room_teacher(manager: &mut ClassroomManager, room_number: u64) {
        if (object_table::contains(&manager.teacher_assignments, room_number)) {
            let teacher = object_table::borrow_mut(&mut manager.teacher_assignments, room_number);
            teacher.years_experience = teacher.years_experience + 1;
        }
    }

    // REMOVE: Extract objects for transfer (O(1))
    public fun transfer_teacher_to_new_school(
        manager: &mut ClassroomManager,
        room_number: u64,
        new_school_address: address
    ) {
        if (object_table::contains(&manager.teacher_assignments, room_number)) {
            let teacher = object_table::remove(&mut manager.teacher_assignments, room_number);
            transfer::transfer(teacher, new_school_address);
        }
    }

    public fun graduate_student_from_locker(
        manager: &mut ClassroomManager,
        locker_number: u64,
        graduate_address: address
    ) {
        if (object_table::contains(&manager.student_lockers, locker_number)) {
            let student = object_table::remove(&mut manager.student_lockers, locker_number);
            transfer::transfer(student, graduate_address);
        }
    }

    // 🎯 OBJECT TABLE ADVANCED PATTERNS
    public fun demonstrate_room_management(manager: &mut ClassroomManager, ctx: &mut TxContext) {
        // Pattern 1: Room reassignment (move objects between keys)
        let source_room = 101u64;
        let target_room = 102u64;
        
        if (object_table::contains(&manager.teacher_assignments, source_room) &&
            !object_table::contains(&manager.teacher_assignments, target_room)) {
            
            // Move teacher from room 101 to room 102
            let teacher = object_table::remove(&mut manager.teacher_assignments, source_room);
            object_table::add(&mut manager.teacher_assignments, target_room, teacher);
        };

        // Pattern 2: Conditional object replacement
        if (object_table::contains(&manager.teacher_assignments, 201u64)) {
            let current_teacher = object_table::borrow(&manager.teacher_assignments, 201u64);
            
            // Replace if teacher has less than 2 years experience
            if (current_teacher.years_experience < 2) {
                let old_teacher = object_table::remove(&mut manager.teacher_assignments, 201u64);
                
                // Transfer old teacher elsewhere or handle appropriately
                transfer::transfer(old_teacher, tx_context::sender(ctx));
                
                // Assign experienced replacement
                let experienced_teacher = create_teacher(
                    b"Prof. Johnson".to_string(),
                    b"Advanced Mathematics".to_string(),
                    10,
                    ctx
                );
                object_table::add(&mut manager.teacher_assignments, 201u64, experienced_teacher);
            }
        };
    }

    // =========================================
    // 🥇 CHAPTER 6: LINKED TABLE - THE HONOR ROLL
    // =========================================
    /*
    🥇 WHAT IS A LINKED TABLE?
    A Linked Table maintains insertion order and allows iteration from either end.
    Perfect for rankings, queues, and any ordered data processing.

    📋 KEY CHARACTERISTICS:
    ✅ Maintains insertion order
    ✅ Iterate front-to-back or back-to-front
    ✅ Queue and stack operations (push/pop both ends)
    ✅ Perfect for rankings and ordered processing
    ❌ Slower than Table for random key access
    ❌ More memory overhead than Table

    🎓 LEARNING OBJECTIVES:
    - Understand when ordering matters
    - Master queue/stack operations
    - Practice ordered data processing
    - Learn ranking and leaderboard patterns
    */

    struct HonorRollManager has key {
        id: UID,
        school_name: String,
        test_scores: LinkedTable<u64, String>,      // score -> student_name (ordered by insertion)
        graduation_queue: LinkedTable<u64, String>, // priority -> student_name (processing order)
        achievement_log: LinkedTable<u64, String>,  // timestamp -> achievement_description
    }

    // 🔧 LINKED TABLE OPERATIONS TUTORIAL

    // CREATE: Initialize with empty linked tables
    public fun create_honor_roll_manager(school_name: String, ctx: &mut TxContext) {
        let manager = HonorRollManager {
            id: object::new(ctx),
            school_name,
            test_scores: linked_table::new(ctx),
            graduation_queue: linked_table::new(ctx),
            achievement_log: linked_table::new(ctx),
        };
        transfer::transfer(manager, tx_context::sender(ctx));
    }

    // PUSH_BACK: Add to the end (like appending to a list)
    public fun add_test_score(
        manager: &mut HonorRollManager,
        score: u64,
        student_name: String
    ) {
        // Adds to the back of the list (most recent)
        linked_table::push_back(&mut manager.test_scores, score, student_name);
    }

    // PUSH_FRONT: Add to the beginning (highest priority)
    public fun add_priority_graduation(
        manager: &mut HonorRollManager,
        priority: u64,
        student_name: String
    ) {
        // Adds to the front (first to be processed)
        linked_table::push_front(&mut manager.graduation_queue, priority, student_name);
    }

    // IS_EMPTY: Check if table has any entries
    public fun has_test_scores(manager: &HonorRollManager): bool {
        !linked_table::is_empty(&manager.test_scores)
    }

    public fun has_graduation_queue(manager: &HonorRollManager): bool {
        !linked_table::is_empty(&manager.graduation_queue)
    }

    // FRONT/BACK: Peek at first/last entries without removing
    public fun get_first_test_score(manager: &HonorRollManager): (u64, String) {
        assert!(!linked_table::is_empty(&manager.test_scores), 1);
        
        let (score, name) = linked_table::front(&manager.test_scores);
        (*score, *name) // Return copies
    }

    public fun get_latest_test_score(manager: &HonorRollManager): (u64, String) {
        assert!(!linked_table::is_empty(&manager.test_scores), 1);
        
        let (score, name) = linked_table::back(&manager.test_scores);
        (*score, *name)
    }

    // POP_FRONT: Remove and return first entry (queue behavior)
    public fun process_next_graduation(manager: &mut HonorRollManager): (u64, String) {
        assert!(!linked_table::is_empty(&manager.graduation_queue), 1);
        // Removes from front (FIFO - First In, First Out)
        linked_table::pop_front(&mut manager.graduation_queue)
    }

    // POP_BACK: Remove and return last entry (stack behavior)  
    public fun remove_latest_score(manager: &mut HonorRollManager): (u64, String) {
        assert!(!linked_table::is_empty(&manager.test_scores), 1);
        // Removes from back (LIFO - Last In, First Out)
        linked_table::pop_back(&mut manager.test_scores)
    }

    // CONTAINS/BORROW: Standard lookup operations (like other tables)
    public fun has_score
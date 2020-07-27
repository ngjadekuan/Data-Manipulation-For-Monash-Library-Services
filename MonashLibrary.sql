set echo on
spool ￼monashlibrary.txt

-------------------------------------------
----------------- Q1 ----------------------
-------------------------------------------
-- CREATE TABLE commands


-------------------------------------------
--1.1
------------------------a-------------------
/*
Create the missing table(s)
*/

CREATE TABLE book_copy (
    branch_code         NUMBER(2) NOT NULL,
    bc_id               NUMBER(6) NOT NULL,
    bc_purchase_price   NUMBER(7,2) NOT NULL,
    bc_reserve_flag     CHAR(1) NOT NULL,
    book_call_no        VARCHAR2(20) NOT NULL
);

COMMENT ON COLUMN book_copy.branch_code IS
    'Branch number ';

COMMENT ON COLUMN book_copy.bc_id IS
    'Book copy id within the branch which owns this book copy';

COMMENT ON COLUMN book_copy.bc_purchase_price IS
    'Purchase price for this copy';

COMMENT ON COLUMN book_copy.bc_reserve_flag IS
    'Flag to indicate if on Counter Reserve or not (Y/N)';

COMMENT ON COLUMN book_copy.book_call_no IS
    'Titles call number - identifies a title';

ALTER TABLE book_copy
    ADD CONSTRAINT bc_counter_chk CHECK ( bc_reserve_flag IN (
        'N',
        'Y'
    ) );

ALTER TABLE book_copy ADD CONSTRAINT book_copy_pk PRIMARY KEY ( bc_id,
branch_code );


CREATE TABLE loan (
    branch_code               NUMBER(2) NOT NULL,
    bc_id                     NUMBER(6) NOT NULL,
    loan_date_time            DATE NOT NULL,
    loan_due_date             DATE NOT NULL,
    loan_actual_return_date   DATE,
    bor_no                    NUMBER(6) NOT NULL
);

COMMENT ON COLUMN loan.branch_code IS
    'Branch number ';

COMMENT ON COLUMN loan.bc_id IS
    'Book copy id within the branch which owns this book copy';

COMMENT ON COLUMN loan.loan_date_time IS
    'Date and time loan taken out';

COMMENT ON COLUMN loan.loan_due_date IS
    'Date and time loan due';

COMMENT ON COLUMN loan.loan_actual_return_date IS
    'Actual date and time loan retruned';

COMMENT ON COLUMN loan.bor_no IS
    'Borrower identifier';

ALTER TABLE loan
    ADD CONSTRAINT loan_pk PRIMARY KEY ( branch_code,
    bc_id,
    loan_date_time );


CREATE TABLE reserve (
    branch_code                NUMBER(2) NOT NULL,
    bc_id                      NUMBER(6) NOT NULL,
    reserve_date_time_placed   DATE NOT NULL,
    bor_no                     NUMBER(6) NOT NULL
);

COMMENT ON COLUMN reserve.branch_code IS
    'Branch number ';

COMMENT ON COLUMN reserve.bc_id IS
    'Book copy id within the branch which owns this book copy';

COMMENT ON COLUMN reserve.reserve_date_time_placed IS
    'Date and time reserve was palced';

COMMENT ON COLUMN reserve.bor_no IS
    'Borrower identifier';

ALTER TABLE reserve
    ADD CONSTRAINT reserve_pk PRIMARY KEY ( reserve_date_time_placed,
    branch_code,
    bc_id );


-- ALTER TABLE FK Rules

ALTER TABLE loan
    ADD CONSTRAINT bc_loan FOREIGN KEY ( bc_id,
    branch_code )
        REFERENCES book_copy ( bc_id,
        branch_code );

ALTER TABLE reserve
    ADD CONSTRAINT bc_reserve FOREIGN KEY ( bc_id,
    branch_code )
        REFERENCES book_copy ( bc_id,
        branch_code );

ALTER TABLE book_copy
    ADD CONSTRAINT bd_bc FOREIGN KEY ( book_call_no )
        REFERENCES book_detail ( book_call_no );

ALTER TABLE loan
    ADD CONSTRAINT borr_loan FOREIGN KEY ( bor_no )
        REFERENCES borrower ( bor_no );

ALTER TABLE reserve
    ADD CONSTRAINT borr_reserve FOREIGN KEY ( bor_no )
        REFERENCES borrower ( bor_no );

ALTER TABLE book_copy
    ADD CONSTRAINT branch_bookcopy FOREIGN KEY ( branch_code )
        REFERENCES branch ( branch_code );
     
     
-------------------------------------------
--1.2
-------------------------------------------
/*
Add the full set of DROP TABLE statements without using CASCADE CONSTRAINTS option.  


DROP TABLE loan PURGE;

DROP TABLE reserve PURGE;

DROP TABLE book_copy PURGE;

DROP TABLE borrower PURGE;

DROP TABLE bd_author PURGE;

DROP TABLE bd_subject PURGE;

DROP TABLE subject PURGE;

DROP TABLE author PURGE;

DROP TABLE book_detail PURGE;

DROP TABLE publisher PURGE;

--DROP TABLE branch_manager PURGE;

DROP TABLE branch PURGE;

DROP TABLE manager PURGE;

*/


-------------------------------------------
----------------- Q2 ----------------------
-------------------------------------------


-------------------------------------------
--2.1
-------------------------------------------
/*
MonLib has just purchased its first 3 copies of a recently released edition of a book. Readers of this book will learn about the subjects 
"Database Design and Database Management". 

Some of  the details of the new book are:

	      	Call Number: 005.74 C822D 2018
            Title: Database Systems: Design, Implementation, and Management
	      	Publication Year: 2018
	      	Edition: 13
	      	Publisher: Cengage
            Authors: Carlos CORONEL (author_id = 1 ) and 
                    Steven MORRIS  (author_id = 2)  	      	
            Price: $120
	
You may make up any other reasonable data values you need to be able to add this book.

Each of the 3 MonLib branches listed below will get a single copy of this book, the book will be available for borrowing (ie not on counter reserve)
at each branch:

		Caulfield (Ph: 8888888881)
		Glen Huntly (Ph: 8888888882)
        Carnegie (Ph: 8888888883)

Your are required to treat this add of the book details and the three copies as a single transaction.

*/

INSERT INTO book_detail VALUES (
    '005.74 C822D 2018',
    'Database Systems: Design, Implementation, and Management',
    'R',
    802,
    TO_DATE('2018','YYYY'),
    '13',
    (
        SELECT
            pub_id
        FROM
            publisher
        WHERE
            pub_name = 'Cengage'
    )
);

INSERT INTO bd_subject VALUES (
    (
        SELECT
            subject_code
        FROM
            subject
        WHERE
            subject_details = 'Database Design'
    ),
    '005.74 C822D 2018'
);

INSERT INTO bd_subject VALUES (
    (
        SELECT
            subject_code
        FROM
            subject
        WHERE
            subject_details = 'Database Management'
    ),
   '005.74 C822D 2018'
);

INSERT INTO bd_author VALUES (
    '005.74 C822D 2018',
    1
);

INSERT INTO bd_author VALUES (
    '005.74 C822D 2018',
    2
);


INSERT INTO book_copy VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888881'
    ),
    (
        SELECT
            branch_count_books + 1
        FROM
            branch
        WHERE
            branch_contact_no = '8888888881'
    ),
    120,
    'N',
    '005.74 C822D 2018'
);

UPDATE branch
    SET
        branch_count_books = branch_count_books + 1
	WHERE
    branch_contact_no = '8888888881';

INSERT INTO book_copy VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888882'
    ),
    (
        SELECT
            branch_count_books + 1
        FROM
            branch
        WHERE
            branch_contact_no = '8888888882'
    ),
    120,
    'N',
    '005.74 C822D 2018'
);

UPDATE branch
    SET
        branch_count_books = branch_count_books + 1
	WHERE
    branch_contact_no = '8888888882';
	

INSERT INTO book_copy VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    (
        SELECT
            branch_count_books + 1
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    120,
    'N',
    '005.74 C822D 2018'
);

UPDATE branch
    SET
        branch_count_books = branch_count_books + 1
	WHERE
    branch_contact_no = '8888888883';
	

COMMIT;

/* Check values NOT required as part of submission */

SELECT
    *
FROM
    book_detail
ORDER BY
    ROWID;

SELECT
    *
FROM
    bd_subject
ORDER BY
    ROWID;

SELECT
    *
FROM
    bd_author
ORDER BY
    ROWID;

SELECT
    *
FROM
    book_copy
ORDER BY
    ROWID;

SELECT
    branch_code,
    branch_name,
    branch_count_books
FROM
    branch
ORDER BY
    branch_code;
    
-------------------------------------------
--2.2
-------------------------------------------
/*
An Oracle sequence is to be implemented in the database for the subsequent insertion of records into the database for  BORROWER table. 

Provide the CREATE 	SEQUENCE statement to create a sequence which could be used to provide primary key values for the BORROWER table. 
The sequence should start at 10 and increment by 1.
*/

CREATE SEQUENCE borrower_seq START WITH 10;


-------------------------------------------
--2.3
-------------------------------------------
/*
Provide the DROP SEQUENCE statement for the sequence object you have created in question 2.2 above. 
*/

-- DROP SEQUENCE borrower_seq;



-------------------------------------------
----------------- Q3 ----------------------
-------------------------------------------
/*
The sequence created in task 2 must be used to insert data into the database for the task 3 questions. For these questions you may only use the data 
supplied in this task. 

You must correctly manage transactions with these tasks.
*/

-------------------------------------------
--3.1
-------------------------------------------
/*
Today is 20th September, 2018, add a new borrower in the database. Some of the details of the new borrower are:
		Name: Ada LOVELACE
		Home Branch: Caulfield (Ph: 8888888881)

You may make up any other reasonable data values you need to be able to add this borrower.
*/

INSERT INTO borrower VALUES (
    borrower_seq.NEXTVAL,
    'Ada',
    'Lovelace',
    '1 Programmer Way',
    'Programville',
    '4000',
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888881'
    )
);

COMMIT;

/* Check values NOT required as part of submission */

SELECT
    *
FROM
    borrower
ORDER BY
    bor_no;

-------------------------------------------
--3.2
-------------------------------------------
/*
Immediately after becoming a member, at 4PM, Ada places a reservation on a book at the Carnegie branch (Ph: 8888888883). 
Some of the details of the book that Ada  has placed a reservation on are:

		Title: Database Systems: Design, Implementation, and Management
		Publication Year: 2018
		Edition: 13

You may assume:
MonLib has not purchased any further copies of this book, beyond those which you inserted in Task 2.1
that nobody has become a member of the library between Ada becoming a member and this reservation.
*/

INSERT INTO reserve VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    (
        SELECT
            bc_id
        FROM
            book_copy
        WHERE
            book_call_no = '005.74 C822D 2018'
            AND   branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_contact_no = '8888888883'
            )
    ),
    TO_DATE('20-Sep-2018 4:00 PM','DD-MON-YYYY HH:MI PM'),
    borrower_seq.CURRVAL
);
    
COMMIT;

/* Check values NOT required as part of submission */

SELECT
    branch_code,
    bc_id,
    TO_CHAR(reserve_date_time_placed,'DD-MON-YYYY HH:MI PM')AS reserve_dt,
    bor_no
FROM
    reserve
ORDER BY
    ROWID;
    
-------------------------------------------
--3.3
-------------------------------------------
/*
After 7 days from reserving the book, Ada receives a notification from the Carnegie library that the book she had placed reservation on is available. 
Ada is very excited about the book being available as she wants to do very well in FIT9132 unit that she is currently studying at Monash University. 
Ada goes to the library and borrows the book at 2 PM on the same day of receiving the notification.

You may assume that there is no other borrower named Ada Lovelace.
*/

INSERT INTO loan VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    (
        SELECT
            bc_id
        FROM
            book_copy
        WHERE
            book_call_no = '005.74 C822D 2018'
            AND   branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_contact_no = '8888888883'
            )
    ),
    (TO_DATE('20-Sep-2018 4:00 PM','DD-MON-YYYY HH:MI PM') - INTERVAL '2' HOUR) + 7,
    TO_DATE('20-Sep-2018','DD-MON-YYYY') + 7 + 28,
    NULL,
    (
        SELECT
            bor_no
        FROM
            borrower
        WHERE
            bor_fname = 'Ada'
            AND   upper(bor_lname) = 'LOVELACE'
    )
);

-- "DELETE FROM reserve WHERE ..." statement is an OPTIONAL STEP.
DELETE FROM reserve
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    )
AND bc_id = (
SELECT
    bc_id
FROM
    book_copy
WHERE
    book_call_no = '005.74 C822D 2018'
    AND   branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883')
    )
        AND   reserve_date_time_placed = TO_DATE('20-Sep-2018 4:00 PM','DD-MON-YYYY HH:MI PM');
    
    
COMMIT;

 /* Check values NOT required as part of submission */

SELECT
    branch_code,
    bc_id,
    TO_CHAR(loan_date_time,'DD-MON-YYYY HH:MI PM')AS loandt,
    loan_due_date,
    loan_actual_return_date,
    bor_no
FROM
    loan
ORDER BY
    ROWID;
     
-------------------------------------------
--3.4
-------------------------------------------
/*
At 2 PM on the day the book is due, Ada goes to the library and renews the book as her exam for FIT9132 is in 2 weeks.
		
You may assume that there is no other borrower named Ada Lovelace.
    
Please note: The due date cannot be extended and the loan must be completed and then a new loan is to be created. The due date will still be for 4 weeks 
even if Ada wants the book for 2 weeks as per the brief.
*/

UPDATE loan
    SET
        loan_actual_return_date = TO_DATE('20-Sep-2018','DD-MON-YYYY') + 7 + 28
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    )
    AND   bc_id = (
        SELECT
            bc_id
        FROM
            book_copy
        WHERE
            book_call_no = '005.74 C822D 2018'
            AND   branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_contact_no = '8888888883'
            )
    )
    AND   loan_due_date = TO_DATE('20-Sep-2018','DD-MON-YYYY') + 7 + 28;

COMMIT;


INSERT INTO loan VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    (
        SELECT
            bc_id
        FROM
            book_copy
        WHERE
            book_call_no = '005.74 C822D 2018'
            AND   branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_contact_no = '8888888883'
            )
    ),
    (TO_DATE('20-Sep-2018 4:00 PM','DD-MON-YYYY HH:MI PM') - INTERVAL '2' HOUR) + 7 + 28,
    TO_DATE('20-Sep-2018','DD-MON-YYYY') + 7 + 28 + 28,
    NULL,
    (
        SELECT
            bor_no
        FROM
            borrower
        WHERE
            bor_fname = 'Ada'
            AND   upper(bor_lname) = 'LOVELACE'
    )
);

COMMIT;

/* Check values NOT required as part of submission */

SELECT
    branch_code,
    bc_id,
    TO_CHAR(loan_date_time,'DD-MON-YYYY HH:MI PM')AS loandt,
    loan_due_date,
    loan_actual_return_date,
    bor_no
FROM
    loan
ORDER BY
    ROWID;

-------------------------------------------
----------------- Q4 ----------------------
-------------------------------------------


-------------------------------------------
--4.1
-------------------------------------------
/*
Record whether a book is damaged (D) or lost (L). If the book is not damaged or lost,then it  is good (G) which means, it can be loaned. 
The value cannot be left empty  for this. Change the "live" database and add this required information for all the  books currently in the database. 
You may assume that condition of all existing books will be recorded as being good. The information can be updated later, if need be. 
*/

------------
--APPROACH 1 (4.1)
------------

ALTER TABLE book_copy ADD (
    bc_status   CHAR(1) DEFAULT 'G' NOT NULL
);

COMMENT ON COLUMN book_copy.bc_status IS
    'Status of book copy';

ALTER TABLE book_copy
    ADD CONSTRAINT bc_status_chk CHECK ( bc_status IN (
        'D',
        'L',
        'G'
    ) );

/*
------------
--APPROACH 2 (4.1)
------------
ALTER TABLE book_copy ADD (
    bc_status   CHAR(1)
);

ALTER TABLE book_copy
    ADD CONSTRAINT bc_status_chk CHECK ( bc_status IN (
        'D',
        'L',
        'G'
    ) );

COMMENT ON COLUMN book_copy.bc_status IS
    'Status of book copy'; 
    
UPDATE book_copy
    SET
        bc_status = 'G';

COMMIT;

ALTER TABLE book_copy MODIFY (
    bc_status
        CONSTRAINT bc_status_nn NOT NULL
);
*/

/* Check values NOT required as part of submission  */

SELECT
    *
FROM
    book_copy
ORDER BY
    bc_id;

-------------------------------------------
--4.2
-------------------------------------------
/*
Allow borrowers to be able to return the books they have loaned to any library branch as MonLib is getting a number of requests regarding this from 
borrowers. As part of this process MonLib wishes to record which branch a particular loan is returned to. Change the "live" database and add this 
required information for all the loans currently in the database. For all the existing loans, books were returned at the same branch from where those
were loaned.
*/

ALTER TABLE loan ADD (
    loan_return_branch   NUMBER(2)
);

COMMENT ON COLUMN loan.loan_return_branch IS
    'Branch where book is returned.';

--Please note that PK is optional in REFERENCES clause.
ALTER TABLE loan ADD CONSTRAINT loan_ret_branch_fk FOREIGN KEY ( loan_return_branch )
    REFERENCES branch;

UPDATE loan 
set LOAN_RETURN_BRANCH = branch_code
where LOAN_ACTUAL_RETURN_DATE is not null;

COMMIT;

/* Check values NOT required as part of submission */

SELECT
    *
FROM
    loan
ORDER BY
    branch_code,
    bc_id,
    loan_date_time;
    
-------------------------------------------
--4.3
-------------------------------------------
/*
Some of the MonLib branches have become very large and it is difficult for a single manager to look after all aspects of the branch. For this reason 
MonLib are intending to appoint two managers for the larger branches starting in the new year - one manager for the Fiction collection (fiction books) 
and another for the Non-Fiction collection (non-fiction ie. reference books). The libraries which continue to have one manager will ask this manager 
to manager the branches Full collection (all books). The number of libraries which will require two managers is quite small. Change the "live" database 
to allow monLib the option of appointing two managers to a branch and track, for all managers, which collection they are managing. 
*/

------------
--APPROACH 1 (4.3)
------------
-- DROP TABLE branch_manager PURGE;

CREATE TABLE branch_manager
    AS
        SELECT
            branch_code,
            man_id
        FROM
            branch;

COMMENT ON COLUMN branch_manager.branch_code IS
    'Branch number ';

COMMENT ON COLUMN branch_manager.man_id IS
    'Manager ID';
    
ALTER TABLE branch_manager ADD CONSTRAINT branch_manager_pk PRIMARY KEY ( branch_code,
man_id );

ALTER TABLE branch_manager ADD (
    collection CHAR(1) DEFAULT 'A' NOT NULL
);

COMMENT ON COLUMN branch_manager.collection IS
    'Type of collection managed by the manager in the library';   

ALTER TABLE branch DROP COLUMN man_id;

ALTER TABLE branch_manager
    ADD CONSTRAINT branch_manager_chk CHECK ( collection IN (
        'F',
        'R',
        'A'
    ) );

ALTER TABLE branch_manager
    ADD CONSTRAINT branch_manager_bc FOREIGN KEY ( branch_code )
        REFERENCES branch ( branch_code );

ALTER TABLE branch_manager
    ADD CONSTRAINT manager_branch_mi FOREIGN KEY ( man_id )
        REFERENCES manager ( man_id );

UPDATE branch_manager SET collection = 'R' WHERE branch_code = (SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883')
     AND man_id = 2;
----------------------------------------------------------------------
----------------------------------------------------------------------
--INSTEAD OF THE ABOVE UPDATE STATEMENT, FOLLOWING TWO SQL STATEMENTS CAN ALSO BE USED.

--DELETE FROM branch_manager WHERE branch_code = (SELECT  branch_code FROM branch WHERE branch_contact_no = '8888888883');
    
--INSERT INTO branch_manager VALUES ((SELECT branch_code FROM branch WHERE branch_contact_no = '8888888883'), 2, 'R');
----------------------------------------------------------------------
----------------------------------------------------------------------

INSERT INTO branch_manager VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    1,
    'F'
);

COMMIT;

--select * from branch_manager;
/*
------------
--APPROACH 2 (4.3)
------------
DROP TABLE branch_manager PURGE;

CREATE TABLE branch_manager (
        branch_code          NUMBER(2) NOT NULL,
        man_id           NUMBER(2) NOT NULL,
        collection  CHAR(1) NOT NULL
        );
        
COMMENT ON COLUMN branch_manager.branch_code IS
    'Branch number ';

COMMENT ON COLUMN branch_manager.man_id IS
    'Manager ID';

COMMENT ON COLUMN branch_manager.collection IS
    'Type of collection managed by the manager in the library';
    
ALTER TABLE branch_manager ADD CONSTRAINT branch_manager_pk PRIMARY KEY ( branch_code, man_id );

ALTER TABLE branch_manager
    ADD CONSTRAINT branch_manager_chk CHECK ( collection IN (
        'F',
        'R',
        'A'
    ) );
    
ALTER TABLE branch_manager
    ADD CONSTRAINT branch_manager_bc FOREIGN KEY ( branch_code )
        REFERENCES branch ( branch_code );

ALTER TABLE branch_manager
    ADD CONSTRAINT manager_branch_mi FOREIGN KEY ( man_id )
        REFERENCES manager ( man_id );
   
INSERT into branch_manager
        (
            SELECT
                branch_code,
                man_id,
                'A'
            FROM
                branch
        );    
 
DELETE FROM branch_manager
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    );
----------------------------------------------------------------------- 
-----------------------------------------------------------------------
--INSTEAD OF THE ABOVE TWO STATEMENTS, FOLLOWING TWO STATEMENTS CAN ALSO BE USED.

--INSERT INTO branch_manager VALUES ((SELECT branch_code FROM branch WHERE branch_contact_no = '8888888881'), 1, 'A');

--INSERT INTO branch_manager VALUES ((SELECT branch_code FROM branch WHERE branch_contact_no = '8888888882'), 2, 'A');
-----------------------------------------------------------------------    
----------------------------------------------------------------------- 

INSERT INTO branch_manager VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    1,
    'F'
);

INSERT INTO branch_manager VALUES (
    (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_contact_no = '8888888883'
    ),
    2,
    'R'
); 


COMMIT;

ALTER TABLE branch DROP COLUMN man_id;
*/


/* Check values NOT required as part of submission  */

SELECT
    *
FROM
    branch_manager
ORDER BY
    branch_code,
    man_id;

SPOOL OFF

SET ECHO OFF


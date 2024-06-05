DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS books_format;


-- #################################

DROP TABLE IF EXISTS books;

CREATE TABLE books(
    book_pk          TEXT UNIQUE,
    book_name        TEXT,
    publisher_fk     TEXT,
    book_version     INTEGER,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_fk) REFERENCES publishers(publisher_pk), 
    PRIMARY KEY (book_pk)
    
) WITHOUT ROWID;

-- Insert values into the books table
INSERT INTO books VALUES ("1", "It begins with us", "1", 1, CURRENT_TIMESTAMP);
INSERT INTO books VALUES ("2", "Harry Potter", "2", 1, CURRENT_TIMESTAMP);


-- #################################
-- Lookup table

DROP TABLE IF EXISTS books_format;

CREATE TABLE books_format (
    book_fk         TEXT,
    format_type     TEXT,
    FOREIGN KEY (book_fk) REFERENCES books(book_pk),
    PRIMARY KEY (book_fk, format_type) -- Composite key
) WITHOUT ROWID;


INSERT INTO books_format VALUES (1, "E-Book");
INSERT INTO books_format VALUES (2, "Paperback");
-- #################################

DROP TABLE IF EXISTS publishers;

CREATE TABLE publishers (
    publisher_pk    TEXT UNIQUE,
    publisher_name  TEXT UNIQUE,
    PRIMARY KEY (publisher_pk)
) WITHOUT ROWID;

INSERT INTO publishers VALUES (1, "Gyldendal");
INSERT INTO publishers VALUES (2, "Lindhardt & Ringhof");

-- #################################

DROP TABLE IF EXISTS authors;

CREATE TABLE authors (
    author_pk       TEXT UNIQUE,
    author_name     TEXT,
    PRIMARY KEY (author_pk)
) WITHOUT ROWID;

INSERT INTO authors VALUES (1, "Coleen Hoover");
INSERT INTO authors VALUES (2, "J.K. Rowling");

-- #################################

DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    category_pk     TEXT UNIQUE,
    category_name   TEXT,
    PRIMARY KEY (category_pk)
) WITHOUT ROWID;

INSERT INTO categories VALUES (1, "Fiction");
INSERT INTO categories VALUES (2, "Fantasy");




-- #################################
-- Junction table for books and authors

DROP TABLE IF EXISTS book_authors;

CREATE TABLE book_authors (
    book_fk         TEXT,
    author_fk       TEXT,
    FOREIGN KEY (book_fk) REFERENCES books(book_pk),
    FOREIGN KEY (author_fk) REFERENCES authors(author_pk), 
    PRIMARY KEY (book_fk, author_fk) -- Compound key
) WITHOUT ROWID;

INSERT INTO book_authors VALUES (1, 1); -- It begins with us by Coleen H.
INSERT INTO book_authors VALUES (2, 2); -- Harry Potter by JK Rowling

-- #################################
-- Junction table for books and categories

DROP TABLE IF EXISTS book_categories;

CREATE TABLE book_categories (
    book_fk         TEXT,
    category_fk     TEXT,
    FOREIGN KEY (book_fk) REFERENCES books(book_pk), 
    FOREIGN KEY (category_fk) REFERENCES categories(category_pk), 
    PRIMARY KEY (book_fk, category_fk) -- Compound key
) WITHOUT ROWID;


INSERT INTO book_categories VALUES (1, 1); -- It begins with us by Coleen H. - Fiction
INSERT INTO book_categories VALUES (2, 2); -- Harry Potter by JK Rowling - Fantasy

SELECT * FROM book_categories;




-- #################################
-- JOINS

-- Inner join - books and publishers
SELECT books.book_pk, books.book_name, publishers.publisher_name 
FROM books INNER JOIN publishers ON books.publisher_fk = publishers.publisher_pk;


-- Left join - books with publishers amd categories
SELECT books.book_pk, books.book_name, publishers.publisher_name, categories.category_name
FROM books
INNER JOIN publishers ON books.publisher_fk = publishers.publisher_pk
LEFT JOIN book_categories ON books.book_pk = book_categories.book_fk
LEFT JOIN categories ON book_categories.category_fk = categories.category_pk;



-- ############# NEW JOINS example #############
-- Cross join - joins all rows from books with all rows from authors
SELECT b.book_name, a.author_name  
FROM books b
CROSS JOIN authors a;

-- Self join - find books by the same publisher
SELECT b1.book_name AS Book1, b2.book_name AS Book2, p.publisher_name
FROM books b1
JOIN books b2 ON b1.publisher_fk = b2.publisher_fk AND b1.book_pk != b2.book_pk
JOIN publishers p ON b1.publisher_fk = p.publisher_pk;

-- Natural join automatically joins tables based on columns with the same name and compatible types in both tables- books and publishers
SELECT book_pk, book_name, publisher_pk, publisher_name
FROM books
NATURAL JOIN publishers;



-- ############# UNION (list books from two different categories) #############

-- union combine book name with category name
SELECT b.book_name, c.category_name
FROM books b
JOIN book_categories bc ON b.book_pk = bc.book_fk
JOIN categories c ON bc.category_fk = c.category_pk
WHERE c.category_name IN ('Fiction', 'Fantasy');

-- ############# GROUP BY (check number of books for publishers) #############
-- 
SELECT p.publisher_name, COUNT(b.book_pk) AS NumberOfBooks
FROM books b
JOIN publishers p ON b.publisher_fk = p.publisher_pk
GROUP BY p.publisher_name;

-- ############# HAVING (check for publishers that have published fewer than two books) #############
-- Having filters out publishers with more than 2 books
SELECT p.publisher_name, COUNT(b.book_pk) AS NumberOfBooks
FROM books b
JOIN publishers p ON b.publisher_fk = p.publisher_pk
GROUP BY p.publisher_name
HAVING COUNT(b.book_pk) < 2;



-- ############# Full text search (fts) #############

DROP TABLE IF EXISTS books_fts;

-- Create the FTS5 virtual table
CREATE VIRTUAL TABLE books_fts USING fts5(
    book_pk,
    book_name,
    category_fk
);

-- Insert values into FTS5 virtual table with data from the books table and category_fk from the book_categories table
INSERT INTO books_fts (book_pk, book_name, category_fk)
SELECT books.book_pk, books.book_name, book_categories.category_fk
FROM books
JOIN book_categories ON books.book_pk = book_categories.book_fk;

-- Do the full text search for the word "Potter"
SELECT book_pk, book_name, category_fk
FROM books_fts
WHERE books_fts MATCH 'Potter';


-- ################### Triggers ##############


-- Trigger will update the updated_at column whenever a book is updated 
CREATE TRIGGER IF NOT EXISTS update_book_by_name
AFTER UPDATE ON books
FOR EACH ROW
BEGIN
    UPDATE books
    SET updated_at = CURRENT_TIMESTAMP
    WHERE book_pk = OLD.book_pk;
END;

-- Trigger that will dynamically increment book_version on book_name update 
CREATE TRIGGER IF NOT EXISTS increment_book_version
BEFORE UPDATE OF book_name ON books
FOR EACH ROW
BEGIN
    UPDATE books
    SET book_version = book_version + 1
    WHERE book_pk = OLD.book_pk;
END;

-- Example of updating a book 
UPDATE books SET book_name = 'It begins with us - version 2' WHERE book_pk = '1';

-- view result in table
SELECT * FROM books;





-- ######################  VIEWS  ######################


DROP VIEW IF EXISTS book_authors_view;

-- EXAMPLE 1) Create the view that combine books and authors
CREATE VIEW book_authors_view AS
SELECT books.book_pk, books.book_name, authors.author_name
FROM books 
JOIN book_authors ON books.book_pk = book_authors.book_fk
JOIN authors ON book_authors.author_fk = authors.author_pk;

-- Show result in table
SELECT * FROM book_authors_view;

-- view with only books that are in the category 'Fiction'
DROP VIEW IF EXISTS fiction_books_view;



-- EXAMPLE 2) Create the view with books that are in the category 'Fiction'
CREATE VIEW fiction_books_view AS
SELECT books.book_pk, books.book_name, categories.category_name
FROM books
JOIN book_categories ON books.book_pk = book_categories.book_fk
JOIN categories ON book_categories.category_fk = categories.category_pk
WHERE categories.category_name = 'Fiction';

-- Select from the view to verify
SELECT * FROM fiction_books_view;





-- ######################  SELECT ALL  ######################
-- Primary tables
SELECT * FROM books; -- also main table 
SELECT * FROM publishers;
SELECT * FROM authors;
SELECT * FROM categories;

-- junction (and lookup) tables
SELECT * FROM book_authors;
SELECT * FROM book_categories;
SELECT * FROM books_format



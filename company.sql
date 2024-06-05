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
    FOREIGN KEY (publisher_fk) REFERENCES publishers(publisher_pk), 
    PRIMARY KEY (book_pk)
    
) WITHOUT ROWID;

-- Insert values into the books table
INSERT INTO books VALUES ("1", "It begins with us", 1);
INSERT INTO books VALUES ("2", "Harry Potter", 2);


-- #################################
-- Lookup table

DROP TABLE IF EXISTS books_format;

CREATE TABLE books_format (
    book_fk         TEXT,
    format_type     TEXT,
    PRIMARY KEY (book_fk, format_type) -- Composite key
) WITHOUT ROWID;


INSERT INTO books_format VALUES (1, "E-Book");
INSERT INTO books_format VALUES (2, "paperback");
-- #################################

DROP TABLE IF EXISTS publishers;

CREATE TABLE publishers (
    publisher_pk    TEXT UNIQUE,
    publisher_name  TEXT UNIQUE,
    PRIMARY KEY (publisher_pk)
) WITHOUT ROWID;

INSERT INTO publishers VALUES (1, "Gyldendal");
INSERT INTO publishers VALUES (2, "Lindhardt og Ringhof");

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
    category_name   TEXT UNIQUE,
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


INSERT INTO book_categories VALUES (1, 2); -- It begins with us by Coleen H. - Fiction
INSERT INTO book_categories VALUES (2, 1); -- Harry Potter by JK Rowling - Fantasy

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


-- ############# UNION (list books from two different categories) #############
SELECT b.book_name, c.category_name
FROM books b
JOIN book_categories bc ON b.book_pk = bc.book_fk
JOIN categories c ON bc.category_fk = c.category_pk
WHERE c.category_name = 'Fiction'

UNION

SELECT b.book_name, c.category_name
FROM books b
JOIN book_categories bc ON b.book_pk = bc.book_fk
JOIN categories c ON bc.category_fk = c.category_pk
WHERE c.category_name = 'Fantasy';

-- ############# GROUP BY (check number of books for publishers)#############
SELECT p.publisher_name, COUNT(b.book_pk) AS NumberOfBooks
FROM books b
JOIN publishers p ON b.publisher_fk = p.publisher_pk
GROUP BY p.publisher_name;

--############# HAVING (check for publishers that has published less/or more than two books)#############
SELECT p.publisher_name, COUNT(b.book_pk) AS NumberOfBooks
FROM books b
JOIN publishers p ON b.publisher_fk = p.publisher_pk
GROUP BY p.publisher_name
HAVING COUNT(b.book_pk) < 2;


-- ######################

SELECT * FROM books;
SELECT * FROM publishers;
SELECT * FROM authors;
SELECT * FROM categories;
SELECT * FROM book_authors;
SELECT * FROM book_categories;
SELECT * FROM books_format
-- library_system.sql
-- Library Management System
-- Deliverable: CREATE DATABASE, CREATE TABLEs, Constraints, and sample data

-- 1) Create database and select it
CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

-- 2) Authors table (one author can write many books)
CREATE TABLE IF NOT EXISTS authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  bio TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3) Categories table (one category has many books)
CREATE TABLE IF NOT EXISTS categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4) Books table (one book can have many copies)
CREATE TABLE IF NOT EXISTS books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  isbn VARCHAR(20) NOT NULL UNIQUE,
  publisher VARCHAR(150),
  published_year YEAR,
  category_id INT, -- FK to categories
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_books_category
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5) Many-to-many: Book <-> Author
CREATE TABLE IF NOT EXISTS book_authors (
  book_id INT NOT NULL,
  author_id INT NOT NULL,
  contribution VARCHAR(100), -- e.g. 'Author', 'Editor'
  PRIMARY KEY (book_id, author_id),
  CONSTRAINT fk_ba_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6) Book copies table: physical copies of each book (one-to-many: book -> copies)
CREATE TABLE IF NOT EXISTS book_copies (
  copy_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  copy_number INT NOT NULL DEFAULT 1, -- sequence number for copies
  condition_note VARCHAR(255),
  status ENUM('available','on_loan','reserved','lost') NOT NULL DEFAULT 'available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_copy_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE (book_id, copy_number)
) ENGINE=InnoDB;

-- 7) Members table (library users)
CREATE TABLE IF NOT EXISTS members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(30),
  address VARCHAR(255),
  joined_date DATE DEFAULT CURRENT_DATE,
  is_active TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

-- 8) Loans table (tracks lending of a copy to a member)
CREATE TABLE IF NOT EXISTS loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  copy_id INT NOT NULL,
  member_id INT NOT NULL,
  loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date DATE NOT NULL,
  return_date DATE DEFAULT NULL,
  status ENUM('borrowed','returned','overdue') NOT NULL DEFAULT 'borrowed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_loans_copy FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_loans_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Optional useful indexes
CREATE INDEX idx_books_category ON books (category_id);
CREATE INDEX idx_copies_book ON book_copies (book_id);
CREATE INDEX idx_loans_member ON loans (member_id);
CREATE INDEX idx_loans_copy ON loans (copy_id);

-- ------------------------
-- Sample data (for testing)
-- ------------------------

-- Categories
INSERT INTO categories (name, description) VALUES
('Fiction', 'Fictional works including novels and stories'),
('Non-Fiction', 'Non-fiction, biographies, essays'),
('Science', 'Science and technology books'),
('Children', 'Books for children');

-- Authors
INSERT INTO authors (name, bio) VALUES
('Jane Austen', 'English novelist known for Pride and Prejudice'),
('Isaac Asimov', 'Prolific science fiction author'),
('Dr. Seuss', 'Children book author and illustrator');

-- Books
INSERT INTO books (title, isbn, publisher, published_year, category_id) VALUES
('Pride and Prejudice', '9780141199078', 'Penguin Classics', 1813, 1),
('Foundation', '9780553293357', 'Bantam', 1951, 3),
('The Cat in the Hat', '9780394800011', 'Random House', 1957, 4);

-- Link books to authors (many-to-many)
INSERT INTO book_authors (book_id, author_id, contribution) VALUES
(1, 1, 'Author'),
(2, 2, 'Author'),
(3, 3, 'Author');

-- Book copies (each book has 2 copies except one)
INSERT INTO book_copies (book_id, copy_number, condition_note) VALUES
(1, 1, 'Good'),
(1, 2, 'Good'),
(2, 1, 'Fair'),
(2, 2, 'New'),
(3, 1, 'Like new');

-- Members
INSERT INTO members (first_name, last_name, email, phone, address) VALUES
('Alice', 'Johnson', 'alice@example.com', '08010000001', '12 Maple St'),
('Bob', 'Smith', 'bob@example.com', '08010000002', '34 Oak Ave');

-- Loans (Alice borrows copy 1 of book 1)
INSERT INTO loans (copy_id, member_id, loan_date, due_date, status) VALUES
(1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'borrowed');

-- Mark the copy as on_loan
UPDATE book_copies SET status = 'on_loan' WHERE copy_id = 1
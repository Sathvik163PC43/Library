create database libarydb;
use libarydb;

create  table tbl_publisher(
publisher_PublisherName  varchar(255) primary key , publisher_PublisherAddress longtext ,publisher_PublisherPhone varchar(25)
);


# creating the table of borrower 

create table tbl_borrowers(
borrower_CardNo int primary key, borrower_BorrowerName varchar(255), 
borrower_BorrowerAddress text , borrower_BorrowerPhone char(12)
);

# creating the table of book with PK & FK

create table tbl_book( 
book_BookID int  auto_increment primary key, book_Title varchar(255), 
book_PublisherName varchar(255),
constraint fk_PublisherName 
foreign key (book_PublisherName)
references tbl_publisher(publisher_PublisherName) on update cascade on delete cascade
);

create table tbl_book_authors(
book_authors_AuthorID  int auto_increment primary key,
book_authors_BookID int,
book_authors_AuthorName varchar(255),
constraint fk_bookid 
foreign key (book_authors_BookID)
references tbl_book(book_BookID) on update cascade on delete cascade
);

# creating library branch table.

create table tbl_library_branch(
library_branch_BranchID int auto_increment primary key, library_branch_BranchName varchar(255),
library_branch_BranchAddress text
);

# creating 	book_copies table with PK and FK

create table tbl_book_copies(
book_copies_CopiesID int auto_increment primary key , book_copies_BookID int , 
book_copies_BranchID int , book_copies_No_Of_Copies int ,
constraint FK_bookid1
foreign key (book_copies_BookID)
references tbl_book(book_BookID) on update cascade on delete cascade,

constraint FK_brankid
foreign key (book_copies_BranchID)
references tbl_library_branch(library_branch_BranchID) on update cascade on delete cascade
);

create table tbl_book_loans (
book_loans_LoansID int auto_increment primary key not null, book_loans_BookID int ,
book_loans_BranchID int, book_loans_CardNo int, book_loans_DateOut date , book_loans_DueDate date
);

ALTER TABLE tbl_book_loans
ADD 
constraint FK_bookid2
foreign key (book_loans_BookID)
references tbl_book(book_BookID) on update cascade on delete cascade;

ALTER TABLE tbl_book_loans
ADD constraint FK_branch2
foreign key (book_loans_BranchID)
references tbl_library_branch(library_branch_BranchID) on update cascade on delete cascade;

CREATE INDEX idx_borrower_CardNo ON tbl_borrowers(borrower_CardNo);



ALTER TABLE tbl_book_loans
ADD constraint FK_book_loans_borrow
foreign key (book_loans_CardNo)
references tbl_borrowers(borrower_CardNo) on update cascade on delete cascade;

-- Add the FK_borrower1 foreign key constraint to tbl_book_loans


-- Add the FK_borrower1 foreign key constraint to tbl_book_loans
#1 How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
SELECT bc.book_copies_No_Of_Copies,lb.library_branch_BranchName,b.book_Title
FROM tbl_book_copies bc
JOIN tbl_book b ON bc.book_copies_BookID = b.book_BookID
JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe'
  and  lb.library_branch_BranchName = 'Sharpstown';

#2 How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select  tbl_book.book_title, tbl_library_branch.library_branch_branchname, 
 tbl_book_copies.book_copies_no_of_copies from tbl_book
 inner join tbl_book_copies on tbl_book.book_bookid = tbl_book_copies.book_copies_bookid
 inner join tbl_library_branch on tbl_library_branch.library_branch_branchid = tbl_book_copies.book_copies_branchid
 where tbl_book.book_title = 'The Lost Tribe';

#3 Retrieve the names of all borrowers who do not have any books checked out.
SELECT b.borrower_BorrowerName
FROM tbl_borrowers b
LEFT JOIN tbl_book_loans bl ON b.borrower_CardNo = bl.book_loans_CardNo
WHERE bl.book_loans_CardNo IS NULL;

#4 For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 
SELECT 
    b.book_Title AS BookTitle,
    br.borrower_BorrowerName AS BorrowerName,
    br.borrower_BorrowerAddress AS BorrowerAddress
FROM 
    tbl_book_loans bl
JOIN 
    tbl_book b ON bl.book_loans_BookID = b.book_BookID
JOIN 
    tbl_borrowers br ON bl.book_loans_CardNo = br.borrower_CardNo
JOIN 
    tbl_library_branch lb ON bl.book_loans_BranchID = lb.library_branch_BranchID
WHERE 
    lb.library_branch_BranchName = 'Sharpstown'
    AND bl.book_loans_DueDate = '0002-03-18';

#5 For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
SELECT
    lb.library_branch_BranchName AS BranchName,
    COUNT(bl.book_loans_LoansID) AS TotalBooksLoaned
FROM
    tbl_library_branch lb
LEFT JOIN
    tbl_book_loans bl ON lb.library_branch_BranchID = bl.book_loans_BranchID
GROUP BY
    lb.library_branch_BranchID, lb.library_branch_BranchName;

#6 Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
SELECT
    b.borrower_BorrowerName AS BorrowerName,
    b.borrower_BorrowerAddress AS BorrowerAddress,
    COUNT(bl.book_loans_LoansID) AS NumBooksCheckedOut
FROM
    tbl_borrowers b
JOIN
    tbl_book_loans bl ON b.borrower_CardNo = bl.book_loans_CardNo
GROUP BY
    b.borrower_CardNo, b.borrower_BorrowerName, b.borrower_BorrowerAddress
HAVING
    COUNT(bl.book_loans_LoansID) > 5;

#7  For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
SELECT
    b.book_Title AS Title,
    COUNT(bc.book_copies_BookID) AS NumCopiesOwned
FROM
    tbl_book_authors a
JOIN
    tbl_book b ON a.book_authors_BookID = b.book_BookID
JOIN
    tbl_book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN
    tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE
    a.book_authors_AuthorName = 'Stephen King'
    AND lb.library_branch_BranchName = 'Central'
GROUP BY
    b.book_BookID, b.book_Title;

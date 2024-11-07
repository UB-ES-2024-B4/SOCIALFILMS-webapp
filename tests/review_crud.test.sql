BEGIN;

SELECT plan(4);

SELECT is(
    (SELECT COUNT(*) FROM reviews),
    0,
    'Initial count of reviews should be 0'
);

INSERT INTO reviews (id, content) VALUES (1, 'Great product!');
SELECT is(
    (SELECT COUNT(*) FROM reviews),
    1,
    'Count of reviews should be 1 after insert'
);

UPDATE reviews SET content = 'Amazing product!' WHERE id = 1;
SELECT is(
    (SELECT content FROM reviews WHERE id = 1),
    'Amazing product!',
    'Content should be updated correctly'
);

DELETE FROM reviews WHERE id = 1;
SELECT is(
    (SELECT COUNT(*) FROM reviews),
    0,
    'Count of reviews should be 0 after delete'
);

SELECT finish(); 

ROLLBACK;
\unset ECHO
\i test_setup.sql

-- $Id$

SELECT plan(28);
--SELECT * FROM no_plan();

/****************************************************************************/
-- Test todo tests.
\echo ok 1 - todo fail
\echo ok 2 - todo pass
SELECT * FROM todo('just because', 2 );
SELECT is(
    fail('This is a todo test' ) || '
'
      || pass('This is a todo test that unexpectedly passes' ),
    'not ok 1 - This is a todo test # TODO just because
# Failed (TODO) test 1: "This is a todo test"
ok 2 - This is a todo test that unexpectedly passes # TODO just because',
   'TODO tests should display properly'
);

-- Try just a reason.
\echo ok 4 - todo fail
SELECT * FROM todo( 'for whatever reason' );
SELECT is(
    fail('Another todo test'),
    'not ok 4 - Another todo test # TODO for whatever reason
# Failed (TODO) test 4: "Another todo test"',
    'Single default todo test should display properly'
);
UPDATE __tresults__ SET ok = true, aok = true WHERE numb IN( 2, 4 );

-- Try just a number.
\echo ok 6 - todo fail
\echo ok 7 - todo pass
SELECT * FROM todo( 2 );
SELECT is(
    fail('This is a todo test' ) || '
'
      || pass('This is a todo test that unexpectedly passes' ),
    'not ok 6 - This is a todo test # TODO 
# Failed (TODO) test 6: "This is a todo test"
ok 7 - This is a todo test that unexpectedly passes # TODO ',
   'TODO tests should display properly'
);

/****************************************************************************/
-- Test skipping tests.
SELECT * FROM check_test(
    skip('Just because'),
    true,
    'simple skip',
    'SKIP: Just because',
    ''
);

SELECT * FROM check_test(
    skip('Just because', 1),
    true,
    'skip with num',
    'SKIP: Just because',
    ''
);

\echo ok 15 - Skip multiple
\echo ok 16 - Skip multiple
\echo ok 17 - Skip multiple
SELECT is(
   skip( 'Whatever', 3 ),
   'ok 15 - SKIP: Whatever
ok 16 - SKIP: Whatever
ok 17 - SKIP: Whatever',
   'We should get the proper output for multiple skips'
);

-- Test inversion.
SELECT * FROM check_test(
    skip(1, 'Just because'),
    true,
    'inverted skip',
    'SKIP: Just because',
    ''
);

-- Test num only.
SELECT * FROM check_test(
    skip(1),
    true,
    'num only',
    'SKIP: ',
    ''
);

/****************************************************************************/
-- Try nesting todo tests.
\echo ok 25 - todo fail
\echo ok 26 - todo fail
\echo ok 27 - todo fail
SELECT * FROM todo('just because', 2 );
SELECT is(
    ARRAY(
        SELECT fail('This is a todo test 1')
        UNION
        SELECT todo::text FROM todo('inside')
        UNION
        SELECT fail('This is a todo test 2')
        UNION
        SELECT fail('This is a todo test 3')
    ),
    ARRAY[
        'not ok 25 - This is a todo test 1 # TODO just because
# Failed (TODO) test 25: "This is a todo test 1"',
        'not ok 26 - This is a todo test 2 # TODO inside
# Failed (TODO) test 26: "This is a todo test 2"',
        'not ok 27 - This is a todo test 3 # TODO just because
# Failed (TODO) test 27: "This is a todo test 3"'
    ],
    'Nested todos should work properly'
);

UPDATE __tresults__ SET ok = true, aok = true WHERE numb IN( 25, 26, 27 );

/****************************************************************************/
-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;
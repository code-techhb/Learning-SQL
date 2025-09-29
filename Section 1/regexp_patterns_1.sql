-- ============================================================================
-- SQL VOWEL QUERIES - CHEAT SHEET to REMEMBER SOME REGEXP PATTERNS
-- All queries use REGEXP syntax (with LEFT/RIGHT alternatives provided)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Cities STARTING with vowels
-- ----------------------------------------------------------------------------
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '^[AEIOU]';

-- Alternative using LEFT:
-- WHERE LEFT(CITY, 1) IN ('A', 'E', 'I', 'O', 'U')


-- ----------------------------------------------------------------------------
-- 2. Cities ENDING with vowels
-- ----------------------------------------------------------------------------
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '[AEIOU]$';

-- Alternative using RIGHT:
-- WHERE RIGHT(CITY, 1) IN ('A', 'E', 'I', 'O', 'U')


-- ----------------------------------------------------------------------------
-- 3. Cities STARTING AND ENDING with vowels (AND logic)
-- ----------------------------------------------------------------------------
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '^[AEIOU].*[AEIOU]$';

-- Alternative using LEFT/RIGHT:
-- WHERE LEFT(CITY, 1) IN ('A', 'E', 'I', 'O', 'U')
--   AND RIGHT(CITY, 1) IN ('A', 'E', 'I', 'O', 'U')


-- ----------------------------------------------------------------------------
-- 4. Cities NOT STARTING with vowels
-- ----------------------------------------------------------------------------
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '^[^AEIOU]';

-- Alternative using LEFT:
-- WHERE LEFT(CITY, 1) NOT IN ('A', 'E', 'I', 'O', 'U')


-- ----------------------------------------------------------------------------
-- 5. Cities NOT ENDING with vowels
-- ----------------------------------------------------------------------------
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '[^AEIOU]$';

-- Alternative using RIGHT:
-- WHERE RIGHT(CITY, 1) NOT IN ('A', 'E', 'I', 'O', 'U')


-- ----------------------------------------------------------------------------
-- 6. Cities that EITHER do not start OR do not end with vowels (OR logic)
-- ----------------------------------------------------------------------------
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '^[^AEIOU]|[^AEIOU]$';

-- Alternative using LEFT/RIGHT:
-- WHERE LEFT(CITY, 1) NOT IN ('A', 'E', 'I', 'O', 'U')
--    OR RIGHT(CITY, 1) NOT IN ('A', 'E', 'I', 'O', 'U')


-- ----------------------------------------------------------------------------
-- 7. Cities that do NOT start AND do NOT end with vowels (AND logic)
-- ----------------------------------------------------------------------------
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '^[^AEIOU].*[^AEIOU]$';

-- Alternative using LEFT/RIGHT:
-- WHERE LEFT(CITY, 1) NOT IN ('A', 'E', 'I', 'O', 'U')
--   AND RIGHT(CITY, 1) NOT IN ('A', 'E', 'I', 'O', 'U')


-- ============================================================================
-- REGEXP SYMBOL REFERENCE
-- ============================================================================
-- ^           Start of string (or NOT when inside brackets)
-- $           End of string
-- [AEIOU]     Match any vowel
-- [^AEIOU]    Match anything EXCEPT vowels
-- .*          Any character, zero or more times
-- |           OR operator

-- ============================================================================
-- QUICK REFERENCE TABLE
-- ============================================================================
-- Query Type                          | REGEXP Pattern
-- ------------------------------------|----------------------------------
-- Starts with vowel                   | '^[AEIOU]'
-- Ends with vowel                     | '[AEIOU]$'
-- Starts AND ends with vowel          | '^[AEIOU].*[AEIOU]$'
-- Doesn't start with vowel            | '^[^AEIOU]'
-- Doesn't end with vowel              | '[^AEIOU]$'
-- Doesn't start OR doesn't end        | '^[^AEIOU]|[^AEIOU]$'
-- Doesn't start AND doesn't end       | '^[^AEIOU].*[^AEIOU]$'

-- ============================================================================

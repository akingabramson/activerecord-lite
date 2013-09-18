# Activerecord Lite

A watered-down version of Rails' ActiveRecord ORM tool.

## Testing

1. Populate the test database by running: `cat test/cats.sql | sqlite3 test/cats.db`.
2. Run the tests with commands such as `ruby -I./lib test/mass_object_test.rb`.

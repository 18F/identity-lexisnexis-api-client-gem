setup:
	bundle check || bundle install

lint:
	bundle exec rubocop

test:
	bundle exec rspec spec/lib

test_integration:
	# TODO: set up required files?
	bundle exec rspec spec/
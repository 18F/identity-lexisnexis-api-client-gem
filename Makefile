setup:
	bundle check || bundle install

unit_test:
	bundle exec rspec spec/lib

integration_test:
	# TODO: set up required files?
	bundle exec rspec spec/
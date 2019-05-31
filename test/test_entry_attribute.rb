# -*- coding: utf-8 -*-

require "al-test-utils"

class TestEntryAttribute < Test::Unit::TestCase
  include AlTestUtils

  class TestExist < self
    priority :must
    def test_existence
      schema = ActiveLdap::Base.connection.schema
      object_classes = ["posixAccount"]
      entry_attribute = ActiveLdap::EntryAttribute.new(schema, object_classes)
      assert_true(entry_attribute.exist?("cn"))
    end

    def test_non_existence
      schema = nil
      object_classes = []
      entry_attribute = ActiveLdap::EntryAttribute.new(schema, object_classes)
      assert_false(entry_attribute.exist?("nonExistence"))
    end
  end

  # Run just this test
  # ruby -I lib test/run-test.rb -n test_add_entry_with_attribute_with_nested_options
  class TestMay < self
    def test_extensible_object_may_include_all_user_attributes
      schema = ActiveLdap::Base.connection.schema
      object_classes = %w[posixAccount]
      entry_attribute = ActiveLdap::EntryAttribute.new(schema, object_classes)
      assert_true(entry_attribute.names.length, schema.attributes.length)
      # assert_true(entry_attribute.exist?("cn"))
      # assert_true(entry_attribute.exist?("owner"))
      # assert_true(entry_attribute.exist?("street"))
      # assert_true(entry_attribute.exist?("uid"))
    end
  end
end

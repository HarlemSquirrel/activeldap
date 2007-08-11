require 'al-test-utils'

class TestConnectionPerDN < Test::Unit::TestCase
  include AlTestUtils

  priority :must
  def test_establish_connection
    make_temporary_user do |user, password|
      begin
        assert_equal(user.class.connection, user.connection)
        assert_raises(ActiveLdap::AuthenticationError) do
          user.establish_connection(:bind_dn => nil,
                                    :allow_anonymous => false,
                                    :retry_limit => 0)
        end
        assert_equal(user.class.connection, user.connection)

        assert_nothing_raised do
          user.establish_connection(:bind_dn => nil,
                                    :allow_anonymous => true)
        end
        assert_not_equal(user.class.connection, user.connection)

        assert_equal(user.connection, user.class.find(user.dn).connection)
        assert_equal(user.connection, user.find(user.dn).connection)
      ensure
        user.remove_connection
      end
    end
  end

  def test_find
    make_temporary_user do |user, password|
      begin
        make_temporary_user do |user2, password2|
          user.establish_connection(:bind_dn => user.dn,
                                    :password => password)
          assert_not_equal(user.class.connection, user.connection)

          found_user2 = user.find(user2.dn)
          assert_not_equal(user2.connection, found_user2.connection)
          assert_equal(user.connection, found_user2.connection)

          assert_equal(found_user2.class.connection,
                       found_user2.class.find(found_user2.dn).connection)

          found_user2.establish_connection(:bind_dn => user2.dn,
                                           :password => password2)
          assert_not_equal(user.connection, found_user2.connection)
          assert_equal(user2.connection, found_user2.connection)
        end
      ensure
        user.remove_connection
      end
    end
  end

  def test_associations
    make_temporary_user do |user, password|
      begin
        make_temporary_group do |group1|
          make_temporary_group do |group2|
            user.groups = [group1]
            assert_equal(group1.connection, user.connection)

            user.establish_connection(:bind_dn => user.dn,
                                      :password => password)
            assert_not_equal(user.class.connection, user.connection)
            assert_not_equal(group1.connection, user.connection)

            assert_raise(ActiveLdap::LdapError::InsufficientAccess) do
              user.groups << group2
            end
            assert_equal([group1.cn], user.groups.collect(&:cn))

            assert_not_equal(group1.connection, user.connection)
            assert_not_equal(user.groups[0].connection, user.connection)
            user.reload
            assert_equal(user.groups[0].connection, user.connection)

            found_user = user.class.find(user.dn)
            assert_equal(user.connection, found_user.connection)
            assert_equal(found_user.connection,
                         found_user.groups[0].connection)
          end
        end
      ensure
        user.remove_connection
      end
    end
  end
end
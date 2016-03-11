require "test_helper"

class TorbaTest < Minitest::Test
  def test_home_path
    Torba.home_path = "/new/home/path"
    assert_equal "/new/home/path", Torba.home_path
  end

  def test_cache_path
    Torba.cache_path = "/new/cache/path"
    assert_equal "/new/cache/path", Torba.cache_path
  end
end

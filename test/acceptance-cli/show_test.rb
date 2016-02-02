require "test_helper"

module Torba
  class ShowTest < Minitest::Test
    def test_runs_pack
      out, err, status = torba("show trumbowyg", torbafile: "01_zip.rb")
      assert status.success?, err
      compare_dirs "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_outputs_package_directory
      out, err, status = torba("show trumbowyg", torbafile: "01_zip.rb")
      assert status.success?, err
      assert_includes out, path_to_packaged("trumbowyg")
    end

    def test_finds_by_partial_package_name
      out, err, status = torba("show trumbo", torbafile: "01_zip.rb")
      assert status.success?, err
      assert_includes out, path_to_packaged("trumbowyg")
    end

    def test_could_not_find_package
      out, err, status = torba("show dumbo", torbafile: "01_zip.rb")
      refute status.success?, err
      assert_includes out, "Could not find package 'dumbo'."
    end

    def test_similar_names_show_options
      out, err, status = torba("show bourbon", torbafile: "04_similar_names.rb")
      refute status.success?, err
      assert_includes out, <<OUT
1 : bourbon
2 : bourbon-neat
0 : - exit -
OUT
    end

    def test_similar_names_chosen_option
      out, err, status = torba("show bourbon", torbafile: "04_similar_names.rb", stdin_data: "2")
      assert status.success?, err
      refute_includes out, path_to_packaged("bourbon")
      assert_includes out, path_to_packaged("bourbon-neat")
    end

    def test_similar_names_chosen_exit
      out, err, status = torba("show bourbon", torbafile: "04_similar_names.rb", stdin_data: "0")
      refute status.success?, err
      refute_includes out, path_to_packaged("bourbon")
      refute_includes out, path_to_packaged("bourbon-neat")
    end

    def test_similar_names_chosen_unexisted_option
      out, err, status = torba("show bourbon", torbafile: "04_similar_names.rb", stdin_data: "7")
      refute status.success?, err
      refute_includes out, path_to_packaged("bourbon")
      refute_includes out, path_to_packaged("bourbon-neat")
    end
  end
end

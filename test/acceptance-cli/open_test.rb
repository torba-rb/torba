require "test_helper"

module Torba
  class OpenTest < Minitest::Test
    def test_complains_no_editor_set
      out, err, status = torba("open trumbowyg", torbafile: "01_zip.rb", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => nil
      })
      refute status.success?, err
      assert_includes out, "To open a package, set $EDITOR or $TORBA_EDITOR"
    end

    def test_runs_pack
      out, err, status = torba("open trumbowyg", torbafile: "01_zip.rb", env: {
        "TORBA_EDITOR" => "echo torba_editor", "VISUAL" => "echo visual", "EDITOR" => "echo editor"
      })
      assert status.success?, err
      assert_dirs_equal "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_uses_torba_editor_first
      out, err, status = torba("open trumbowyg", torbafile: "01_zip.rb", env: {
        "TORBA_EDITOR" => "echo torba_editor", "VISUAL" => "echo visual", "EDITOR" => "echo editor"
      })
      assert status.success?, err
      assert_includes out, "torba_editor #{path_to_packaged "trumbowyg"}"
    end

    def test_uses_visual_editor_second
      out, err, status = torba("open trumbowyg", torbafile: "01_zip.rb", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => "echo visual", "EDITOR" => "echo editor"
      })
      assert status.success?, err
      assert_includes out, "visual #{path_to_packaged "trumbowyg"}"
    end

    def test_uses_editor_third
      out, err, status = torba("open trumbowyg", torbafile: "01_zip.rb", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => "echo editor"
      })
      assert status.success?, err
      assert_includes out, "editor #{path_to_packaged "trumbowyg"}"
    end

    def test_finds_by_partial_package_name
      out, err, status = torba("open trumbo", torbafile: "01_zip.rb", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => "echo editor"
      })
      assert status.success?, err
      assert_includes out, "editor #{path_to_packaged "trumbowyg"}"
    end

    def test_could_not_find_package
      out, err, status = torba("open dumbo", torbafile: "01_zip.rb", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => "echo editor"
      })
      refute status.success?, err
      assert_includes out, "Could not find package 'dumbo'."
    end

    def test_similar_names_show_options
      out, err, status = torba("open bourbon", torbafile: "04_similar_names.rb", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => "echo editor"
      })
      refute status.success?, err
      assert_includes out, <<OUT
1 : bourbon
2 : bourbon-neat
0 : - exit -
OUT
    end

    def test_similar_names_chosen_option
      skip_java_capture3_bug
      out, err, status = torba("open bourbon", torbafile: "04_similar_names.rb", stdin_data: "2", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => "echo editor"
      })
      assert status.success?, err
      refute_includes out, "editor #{path_to_packaged "bourbon"}"
      assert_includes out, "editor #{path_to_packaged "bourbon-neat"}"
    end

    def test_similar_names_chosen_exit
      out, err, status = torba("open bourbon", torbafile: "04_similar_names.rb", stdin_data: "0", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => "echo editor"
      })
      refute status.success?, err
      refute_includes out, "editor #{path_to_packaged "bourbon"}"
      refute_includes out, "editor #{path_to_packaged "bourbon-neat"}"
    end

    def test_similar_names_chosen_unexisted_option
      out, err, status = torba("open bourbon", torbafile: "04_similar_names.rb", stdin_data: "7", env: {
        "TORBA_EDITOR" => nil, "VISUAL" => nil, "EDITOR" => "echo editor"
      })
      refute status.success?, err
      refute_includes out, "editor #{path_to_packaged "bourbon"}"
      refute_includes out, "editor #{path_to_packaged "bourbon-neat"}"
    end
  end
end

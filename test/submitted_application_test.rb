require_relative "test_helper"

class SubmittedApplicationTest < Minitest::Test
  def test_renders_pdf
    upload = SubmittedApplication.new(make_csv_upload("upload.csv"))
    rendered_pdf = upload.to_pdf
    page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
    assert_equal 2, page_analysis.pages.size
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
    refute_includes text_analysis.strings, "Application Summary"
    assert_includes text_analysis.strings, "Jane Doe"
    assert_includes text_analysis.strings, "3.70"
  end

  def test_renders_pdf_with_summary
    params = make_csv_upload("upload.csv").merge(show_summary: "1")
    upload = SubmittedApplication.new(params)
    rendered_pdf = upload.to_pdf
    page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
    assert_equal 3, page_analysis.pages.size
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
    assert_includes text_analysis.strings, "Application Summary"
    assert_includes text_analysis.strings, "Jane Doe"
    assert_includes text_analysis.strings, "3.70"
  end

  def test_renders_pdf_with_identifiers_hidden
    params = make_csv_upload("upload.csv").merge(show_summary: "1", hide_identifiers: "1")
    upload = SubmittedApplication.new(params)
    rendered_pdf = upload.to_pdf
    page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
    assert_equal 3, page_analysis.pages.size
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
    assert_includes text_analysis.strings, "Application Summary"
    refute_includes text_analysis.strings, "Jane Doe"
    assert_includes text_analysis.strings, "3.70"
  end

  def test_raises_for_invalid_file
    error = assert_raises(RuntimeError) do
      SubmittedApplication.new(make_csv_upload("upload_invalid.csv"))
    end
    assert_equal "File is missing expected header `First Name`.", error.message
  end

  def test_raises_for_no_file
    error = assert_raises(RuntimeError) do
      SubmittedApplication.new({})
    end
    assert_equal "No file provided.", error.message
  end
end

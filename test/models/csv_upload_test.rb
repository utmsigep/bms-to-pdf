require 'test_helper'

class CsvUploadTest < ActionDispatch::IntegrationTest
  test "should render a PDF" do
    params = {}
    params[:csv] = fixture_file_upload('upload.csv', 'text/csv')
    upload = CsvUpload.new(params)
    rendered_pdf = upload.to_pdf
    page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
    assert_equal 2, page_analysis.pages.size
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
    refute_includes text_analysis.strings, 'Application Summary'
    assert_includes text_analysis.strings, 'Jane Doe'
    assert_includes text_analysis.strings, '3.70'
  end

  test "should render a PDF with summary page" do
    params = {}
    params[:csv] = fixture_file_upload('upload.csv', 'text/csv')
    params[:show_summary] = "1"
    upload = CsvUpload.new(params)
    rendered_pdf = upload.to_pdf
    page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
    assert_equal 3, page_analysis.pages.size
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
    assert_includes text_analysis.strings, 'Application Summary'
    assert_includes text_analysis.strings, 'Jane Doe'
    assert_includes text_analysis.strings, '3.70'
  end

  test "should render a PDF with identifiers hidden" do
    params = {}
    params[:csv] = fixture_file_upload('upload.csv', 'text/csv')
    params[:show_summary] = "1"
    params[:hide_identifiers] = "1"
    upload = CsvUpload.new(params)
    rendered_pdf = upload.to_pdf
    page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
    assert_equal 3, page_analysis.pages.size
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
    assert_includes text_analysis.strings, 'Application Summary'
    refute_includes text_analysis.strings, 'Jane Doe'
    assert_includes text_analysis.strings, '3.70'
  end

  test "should raise an exception for invalid file" do
    error = assert_raise RuntimeError do
      params = {}
      params[:csv] = fixture_file_upload('upload_invalid.csv', 'text/csv')
      upload = CsvUpload.new(params)
    end
    assert_equal 'File is missing expected header `First Name`.', error.message
  end

  test "should raise an exception for no file" do
    error = assert_raise RuntimeError do
      params = {}
      upload = CsvUpload.new(params)
    end
    assert_equal 'No file provided.', error.message
  end
end

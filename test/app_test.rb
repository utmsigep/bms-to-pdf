require_relative "test_helper"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_index
    get "/"
    assert last_response.ok?
  end

  def test_convert_file
    post "/convert", csv: Rack::Test::UploadedFile.new(
      File.join(FIXTURES_DIR, "upload.csv"), "text/csv"
    )
    assert last_response.ok?
    assert_equal "application/pdf", last_response.content_type
  end
end

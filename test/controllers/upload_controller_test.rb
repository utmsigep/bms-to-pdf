require 'test_helper'

class UploadControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get upload_index_url
    assert_response :success
  end

  test "should convert file" do
    csv_file = fixture_file_upload('upload.csv', 'text/csv')
    post upload_convert_url, params: { csv: csv_file }
    assert_response :success
  end
end

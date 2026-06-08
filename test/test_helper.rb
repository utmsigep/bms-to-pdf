ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "pdf/inspector"

require_relative "../app"
require_relative "../lib/submitted_application"

FIXTURES_DIR = File.expand_path("fixtures/files", __dir__)

def make_csv_upload(filename, type = "text/csv")
  path = File.join(FIXTURES_DIR, filename)
  { csv: { filename: filename, type: type, tempfile: File.open(path) } }
end

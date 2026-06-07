require "sinatra"
require_relative "lib/submitted_application"

set :public_folder, File.join(__dir__, "public")
set :views, File.join(__dir__, "views")
enable :sessions

before do
  @flash_error = session.delete(:flash_error)
end

get "/" do
  erb :index
end

post "/convert" do
  begin
    upload = SubmittedApplication.new(params)
    filename = params[:csv][:filename].sub(/\.csv$/i, ".pdf")
    content_type "application/pdf"
    attachment filename
    upload.to_pdf
  rescue => e
    session[:flash_error] = e.message
    redirect "/"
  end
end

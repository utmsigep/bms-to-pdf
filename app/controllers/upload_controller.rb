require "prawn"

class UploadController < ApplicationController
  def index
  end

  def convert
    upload = CsvUpload.new(upload_params)
    send_data upload.to_pdf, filename: upload_params[:csv].original_filename.gsub('.csv', '.pdf'),
                             type: 'application/pdf', disposition: 'download'
  rescue => e
    redirect_to root_path(), alert: e.message
  end

  private

  def upload_params
    params.permit(:csv, :hide_identifiers, :show_summary, :authenticity_token, :commit)
  end
end

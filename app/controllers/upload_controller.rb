require "prawn"

class UploadController < ApplicationController
  def index
  end

  def convert
    upload = CsvUpload.new(upload_params)
    send_data upload.to_pdf, filename: upload_params[:csv].original_filename.gsub('.csv', '.pdf'), type: 'application/pdf', disposition: 'download'
  end

  private

    def upload_params
      params.permit(:csv, :hide_identifiers)
    end

end

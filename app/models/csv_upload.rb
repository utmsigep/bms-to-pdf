require 'csv'

EXPECTED_HEADERS = [
    'First Name',
    'Last Name',
    'Email',
    'Cell Phone Number',
    'Date of Birth',
    'Expected Graduation Year',
    'Current or Intended Major/Minor',
    'ACT/SAT Score',
    'Cumulative High School or College GPA',
    'Leadership and Community Involvement',
    'Honors, Awards and Scholarships',
    'Work Experience',
    'Submission Date',
    'How did you hear about the Balanced Man Scholarship?',
    'Gender Identity',
    'Self Described Gender Identity'
]

FILE_SIZE_LIMIT_MB = 10
RECORD_COUNT_LIMIT = 1000

class CsvUpload
    def initialize(upload_params)
        @upload_params = upload_params
        raise 'Invalid file format. Must be a CSV.' unless upload_params['csv'].content_type == 'text/csv'
        raise "File is too large. Must be below #{FILE_SIZE_LIMIT_MB} MB." unless upload_params['csv'].size < FILE_SIZE_LIMIT_MB * 125000
        @table = CSV.parse(File.read(upload_params['csv'].path), headers: true, header_converters: lambda { |h| h.strip })
        EXPECTED_HEADERS.each do |header|
            next if ['Gender Identity', 'Self Described Gender Identity'].include? header
            raise "File is missing expected header `#{header}`." unless @table.headers.include? header
        end
        raise "Too many rows to process. Please run in batches of less than #{RECORD_COUNT_LIMIT}." unless @table.length < RECORD_COUNT_LIMIT
    end

    def to_pdf
        pdf = Prawn::Document.new
        pdf.font_size 12
        pdf.font_families.update('Lato' => {
            :normal => "#{Rails.root}/app/assets/fonts/Lato-Regular.ttf",
            :italic => "#{Rails.root}/app/assets/fonts/Lato-Italic.ttf",
            :bold => "#{Rails.root}/app/assets/fonts/Lato-Bold.ttf",
            :bold_italic => "#{Rails.root}/app/assets/fonts/Lato-BoldItalic.ttf",
          })
        pdf.font 'Lato'
        pdf.fill_color '000000'

        if @upload_params[:show_summary] == "1"
            pdf.text "<font size='18'><b>Application Summary<b></font>", inline_format: true
            pdf.stroke_horizontal_rule

            pdf.move_down 20

            gpas = @table.by_col['Cumulative High School or College GPA'].map! { |g| g.to_f }
            gpas = gpas.delete_if { |g| g < 0.0 || g > 5.0 }
            submission_dates = @table.by_col['Submission Date'].map! { |sd| sd.to_date }

            gender = {}
            @table.by_col['Gender Identity'].each do |gi|
                gi = '(Not Set)' if gi.nil?
                if gender[gi].nil?
                    gender[gi] = 0
                end
                gender[gi] += 1
            end

            sources = {}
            @table.by_col['How did you hear about the Balanced Man Scholarship?'].each do |source|
                source = '(Not Set)' if source.nil?
                if sources[source].nil?
                    sources[source] = 0
                end
                sources[source] += 1
            end

            histogram = {}
            submission_dates.min.step(submission_dates.max, 1.0).to_a.each do |date|
                histogram[date.strftime('%Y-%m-%d')] = 0
            end
            @table.by_col['Submission Date'].each do |date|
                date = '(Not Set)' if date.nil?
                histogram[date] += 1
            end

            y_position = pdf.cursor
            pdf.text_box "<strong>Total Applications</strong><br><font size='16'><b>#{@table.count}</b></font>",
                at: [0, y_position],
                width: 180,
                height: 50,
                inline_format: true

            pdf.text_box "<strong>Median GPA</strong><br><font size='16'><b>#{self.median(gpas).round(2)}</b></font>",
                at: [180, y_position],
                width: 180,
                height: 50,
                inline_format: true

            pdf.text_box "<strong>Average GPA</strong><br><font size='16'><b>#{self.average(gpas).round(2)}</b></font>",
                at: [360, y_position],
                width: 180,
                height: 50,
                inline_format: true

            pdf.move_down 50

            y_position = pdf.cursor
            pdf.text_box "<strong>First Submission</strong><br><font size='16'><b>#{submission_dates.min.strftime('%-m/%-d/%Y')}</b></font>",
                at: [0, y_position],
                width: 180,
                height: 50,
                inline_format: true

            pdf.text_box "<strong>Last Submission</strong><br><font size='16'><b>#{submission_dates.max.strftime('%-m/%-d/%Y')}</b></font>",
                at: [180, y_position],
                width: 180,
                height: 50,
                inline_format: true

            pdf.move_down 50

            pdf.text "<strong>Submission Trend</strong>", inline_format: true
            pdf.move_down 85
            y_position = pdf.cursor
            pdf.stroke { pdf.line [20, y_position], [540, y_position] }
            pdf.stroke { pdf.line [20, y_position], [20, y_position + 75] }
            max = histogram.values.max
            bar_width = 520.to_f/histogram.length
            pdf.fill_color '522e62'
            pdf.text_box max.to_s, size: 8, width: 20, at: [0, y_position + 75]
            pdf.text_box "0", size: 8, width: 20, at: [0, y_position + 10]
            histogram.each_with_index do |element, index|
                bar_height = ((element[1].to_f/max.to_f) * -75.to_f)
                pdf.fill_rectangle [(bar_width * index) + 20, y_position], bar_width, bar_height
            end
            pdf.fill_color '000000'
            pdf.move_down 10
            y_position = pdf.cursor
            pdf.text_box histogram.keys.min.to_date.strftime('%-m/%-d/%Y'),
                at: [20, y_position],
                width: 250,
                height: 20,
                size: 8,
                inline_format: true

            pdf.text_box histogram.keys.max.to_date.strftime('%-m/%-d/%Y'),
                at: [270, y_position],
                width: 270,
                height: 20,
                size: 8,
                align: :right

            pdf.move_down 20

            pdf.text "<strong>Gender Identity</strong>", inline_format: true
            pdf.move_down 5
            pdf.table(gender)
            pdf.move_down 20

            pdf.text "<strong>Source</strong>", inline_format: true
            pdf.move_down 5
            pdf.table(sources)
            pdf.move_down 20

            pdf.stroke_horizontal_rule
            pdf.move_down 10

            pdf.text "<font size='10'><b>File:</b> #{@upload_params[:csv].original_filename}      <b>Generated:</b> #{DateTime.now.in_time_zone('US/Eastern').strftime('%-m/%-d/%Y %-I:%M %p ET')}</font>", inline_format: true

            pdf.start_new_page
        end

        @table.each_with_index do |row, i|
            pdf.font_size 12
            application_id = i + 1
            pdf.text "<font size='9'><b>Application ##{application_id}</b></font>", inline_format: true, align: :right
            pdf.move_down 10
            unless @upload_params[:hide_identifiers] == "1"
                y_position = pdf.cursor
                pdf.bounding_box [0, y_position], width: 400, height: 40, overflow: :shrink_to_fit do
                    pdf.text "<font size='18'><b>#{row['First Name']} #{row['Last Name']}</b> (#{row['Expected Graduation Year']})</font>", inline_format: true
                    pdf.text "#{row['Email']}    #{row['Cell Phone Number'].gsub(/^(\d{3})(\d{3})(\d{4})$/, '(\1) \2-\3')}"
                end
                pdf.bounding_box [400, y_position], width: 140, height: 40, overflow: :shrink_to_fit do
                    begin
                        birth_date = Date.parse(row['Date of Birth']).strftime('%-m/%-d/%Y')
                    rescue
                        birth_date = 'Not Set'
                    end
                    pdf.text "D.O.B. #{birth_date}", align: :right
                    pdf.text "#{row['Gender Identity']} #{row['Self Described Gender Identity']}", align: :right, fit_text: true
                end
                pdf.move_down 10
            end
            pdf.stroke_horizontal_rule
            pdf.move_down 10
            pdf.font_size 10
            y_position = pdf.cursor
            pdf.text_box "<strong>Current or Intended Major/Minor</strong>\n#{row['Current or Intended Major/Minor']}",
                at: [0, y_position],
                width: 280,
                height: 25,
                overflow: :shrink_to_fit,
                inline_format: true

            pdf.text_box "<strong>Cumulative HS or College GPA</strong>\n#{row['Cumulative High School or College GPA']}",
                at: [280, y_position],
                width: 160,
                height: 25,
                overflow: :shrink_to_fit,
                inline_format: true

            pdf.text_box "<strong>ACT/SAT Score</strong>\n#{row['ACT/SAT Score']}",
                at: [440, y_position],
                width: 100,
                height: 25,
                overflow: :shrink_to_fit,
                inline_format: true

            pdf.move_down 30
            pdf.stroke_horizontal_rule
            pdf.move_down 10
            pdf.span 540, position: :left do
                pdf.text "<b>Leadership & Community Involvement</b>", inline_format: true
                pdf.move_down 10
                pdf.text "#{row['Leadership and Community Involvement']}", align: :justify
                pdf.move_down 10
                pdf.text "<b>Honors, Awards and Scholarships</b>", inline_format: true
                pdf.move_down 10
                pdf.text "#{row['Honors, Awards and Scholarships']}", align: :justify
                pdf.move_down 10
                pdf.text "<b>Work Experience</b>", inline_format: true
                pdf.move_down 10
                pdf.text "#{row['Work Experience']}", align: :justify
                pdf.move_down 10
                (@table.headers - EXPECTED_HEADERS).each do |key|
                    pdf.text "<b>#{key}</b>", inline_format: true
                    pdf.move_down 10
                    pdf.text "#{row[key]}", align: :justify
                    pdf.move_down 10
                end
                pdf.move_down 10
                pdf.stroke_horizontal_rule
                pdf.move_down 10
                pdf.text "<font size='10'><b>Submitted:</b> #{Date.parse(row['Submission Date']).strftime('%-m/%-d/%Y')}      <b>Source:</b> #{row['How did you hear about the Balanced Man Scholarship?']}</font>", inline_format: true
            end
            pdf.start_new_page if i < @table.length - 1
        end
        pdf.render
    end

    private

    def average(array)
        return nil if array.empty?
        array.sum(0.0) / array.length
    end

    def median(array)
        return nil if array.empty?
        sorted = array.sort
        len = sorted.length
        (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end

end
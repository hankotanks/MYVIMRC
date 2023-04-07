# frozen_string_literal: true

require 'asciidoctor'

pages = Dir['./*.adoc'].concat Dir['./*txt']

pages.each do |page|
  page_contents = File.read(page)
  page_contents.scan(/(?<=[^`]<<).*(?=>>[^`])/).each do |match|
    page_name = File.basename(match, File.extname(match))
    page_contents.sub!("<<#{match}>>", "xref:#{page_name}.html[#{page_name}]")
  end

  page_contents.scan(/(?<=[^`]\[images:).*(?=\][^`])/).each do |match|
    gallery_string = '[cols="'

    gallery_image_names = match.to_s.split(',')
    (0..(gallery_image_names.length - 2)).each { gallery_string += 'a,' } if gallery_image_names.length > 1

    gallery_string += "a\", frame=none, grid=none]\n"
    gallery_string += "|===\n"

    gallery_image_names.each { |image| gallery_string += "| image:#{image.strip}[]\n" }
    gallery_string += "|===\n"

    page_contents.sub!("[images:#{match}]", gallery_string)
  end

  html_contents = Asciidoctor.convert page_contents, standalone: true, attributes: {
    'imagesdir' => './../images',
    'stylesheet' => 'styles.css'
  }

  output_file_name = File.join(File.basename(page, File.extname(page)))
  File.open("./web/#{output_file_name}.html", 'w') do |file|
    file.write(html_contents)
  end
end

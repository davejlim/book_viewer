require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.read('data/toc.txt').split("\n")
end

helpers do
  def split_chapters(text)
    array = text.split("\n\n")
    array.map.with_index { |paragraph, index| "<p id='#{index + 1}'>#{paragraph}</p>" }.join("\n")
  end

  def bold(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  redirect '/' unless (1..@contents.size).include?(number)
  @title = "Chapter #{number} - #{@contents[number - 1]}"
  @text = File.read("data/chp#{number}.txt")

  erb :chapter
end

def each_chapter()
  @contents.each_with_index do |chapter, index|
    number = index + 1
    content = File.read("data/chp#{number}.txt")
    yield chapter, number, content
  end
end

def chapter_matching(query)
  results = []
  return results if !query || query.empty?

  each_chapter do |name, number, content|
    matches = {}
    content.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {name: name, number: number, paragraph: matches} if content.include?(query)
  end

  results
end

get "/search" do
  @title = "Search"
  @results = chapter_matching(params[:query])

  erb :search
end

not_found do
  redirect "/"
end
require "rubygems"
require "sinatra"
require "haml"
require "babosa"
require "date"
require "bundler/setup"
require "prequel"
require "prequel/cookie_adapter"

class Book
  extend Prequel::Model
  attr_accessor :title, :author
  attr_id :slug

  def slug
    title.to_slug.normalize!
  end
end

set :session, false
Prequel::CookieAdapter.new(:secret => "25b5eddbd9d183364baae6a060733896")

before do
  adapter = Prequel.adapters[:main]
  adapter.data = request.cookies["prequel_data"]
  adapter.load_database
end

after do
  set_cookie
end

def set_cookie
  adapter = Prequel.adapters[:main]
  response.set_cookie "prequel_data", {
    :path    => "/",
    :expires => (Date.today + 100).to_time,
    :value   => adapter.export_data
  }
end

get "/" do
  @header = "Books"
  @books = Book.find
  haml :index
end

get "/books/new" do
  @header = "Add a Book"
  @action = "/books"
  haml :new
end

get "/books/:slug/edit" do |slug|
  @book           = Book.get(slug)
  @action         = "/books/#{@book.slug}"
  @header         = @book.title
  params[:title]  = @book.title
  params[:author] = @book.author
  haml :book
end

get "/books/:slug" do |slug|
  @book = Book.get(slug)
  @header = @book.title
  haml :book
end

post "/books" do
  @book = Book.create(:title => params[:title], :author => params[:author])
  if @book
    set_cookie
    redirect "/"
  else
    "Sorry, could not create book."
  end
end

__END__
@@layout
!!! 5
%html
  %head
    %meta(http-equiv="Content-Type" content="text/html; charset=utf-8")
    %title CookieAdapter Demo
  %body
    %h2= @header
    = yield

@@edit
haml(:form, :layout => false)

@@index
%ul
  - @books.each do |book|
    %li= '<a href="/books/%s">%s</a>' % [book.slug, book.title, book.author]
%p.controls
  <a href="/books/new">New book</a>

@@new
= haml(:form, :layout => false)
%p.controls
  <a href="/">Books</a>

@@book
by #{@book.author}
%p.controls
  <a href="/">Books</a>
  <a href="/books/#{@book.slug}/edit">Edit</a>

@@form
%form(method="post" enctype="utf-8" action=@action)
  %p
    %label(for="title") Title:
    %br
    %input#title{:type => "text", :value => params[:title], :name => "title"}
  %p
    %label(for="author") Author:
    %br
    %input#author{:type => "text", :value => params[:author], :name => "author"}
  %p
    %input(type="submit" value="Submit")

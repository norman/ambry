$LOAD_PATH << File.expand_path("../../lib", __FILE__)
$LOAD_PATH.uniq!

require "rubygems"
require "sinatra"
require "haml"
require "babosa"
require "date"
require "norman"
require "norman/adapters/cookie"
require "rack/norman"

set :session, false

use Rack::Cookies
use Rack::Norman, :name => :cookie, :secret => "Sssshhhh! This is a secret."

class Book
  extend Norman::Model
  field :slug, :title, :author
  use :cookie

  def title=(value)
    @slug  = value.to_slug.normalize.to_s
    @title = value
  end
end

get "/" do
  @header = "Books"
  @books  = Book.all
  haml :index
end

get "/books/new" do
  @header = "Add a Book"
  @action = "/books"
  haml :new
end

get "/books/:slug/edit" do |slug|
  @book           = Book.get(slug)
  @action         = "/books"
  @header         = @book.title
  params[:title]  = @book.title
  params[:author] = @book.author
  haml :edit
end

get "/books/:slug" do |slug|
  @book   = Book.get(slug)
  @header = @book.title
  haml :book
end

post "/books" do
  Book.delete params[:slug] unless params[:slug].blank?
  @book = Book.create params unless params[:title].blank?
  redirect "/"
end

__END__
@@layout
!!! 5
%html
  %head
    %meta(http-equiv="Content-Type" content="text/html; charset=utf-8")
    %title Norman Cookie Adapter Demo
  %body
    %h2= @header
    = yield

@@edit
= haml(:form, :layout => false)

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
    - if @book
      %input#slug{:type => "hidden", :value => @book.slug, :name => "slug"}
    %label(for="title") Title:
    %br
    %input#title{:type => "text", :value => params[:title], :name => "title"}
  %p
    %label(for="author") Author:
    %br
    %input#author{:type => "text", :value => params[:author], :name => "author"}
  %p
    %input(type="submit" value="save it")
- if @book
  %form{:method => "post", :enctype => "utf-8", :action => "/books"}
    %input#slug{:type => "hidden", :value => @book.slug, :name => "slug"}
    %input(type="submit" value="or delete it")

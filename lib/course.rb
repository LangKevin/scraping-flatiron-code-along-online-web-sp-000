require 'pry'
class Course
  attr_accessor :title, :schedule, :description
  @@all = []
  def initialize
    @@all << self
  end
  def self.all
    @@all
  end
  def self.reset_all
    @@all.clear
  end
end

# class Transaction
#   attr_accessor :date, :description, :team
#   @@all = []
#   def initialize
#     @@all << self
#   end
#   def self.all
#     @@all
#   end
#   def self.reset_all
#     @@all.clear
#   end
# end

class Schedule
  attr_accessor :week, :day, :team, :network, :ticketPrice, :ticketSite, :time, :location
  @@all = []
  def self.load_all(team)
    self.clear_all
#{team.abbreviation}"
    url = "https://www.espn.com/nfl/team/schedule/_/name/#{team.abbreviation}"
    doc = Nokogiri::HTML(open(url))
    cssSched = doc.css(".Table2__td")
    cnt = 0
    week = 0
    sched = nil
    cssSched.each do |schedule|
      cnt = cnt + 1
      if cnt > 8
          if (schedule.attributes["class"].value == "Table2__td") &&
             !(schedule.children == nil) && !(schedule.children.size < 1) && !(schedule.children[0].attributes == nil)
              (schedule.children[0].respond_to?('text'))
            day = schedule.children[0].text
            if day.match? /Sun|Mon|Thu|Fri|Sat/
              sched = Schedule.new
              week = week + 1
              sched.week = week
              sched.day = day
            end
          end
          if (schedule.css(".pr2").size > 0)
            sched.location = schedule.css(".pr2").children[0]
            sched.team = schedule.search("a").children[0].attributes["title"].value
          end
          if (schedule.css(".network-container").size > 0)
            sched.network = schedule.css(".network-container").children.search("div").text
          end
          if (schedule.css(".Schedule__ticket").size > 0)
            sched.ticketPrice = schedule.css(".Schedule__ticket").children[0]
            sched.ticketSite = schedule.children[0].attributes["href"].value
          end
          if (schedule.search("a").children.size > 0)
            if (schedule.search("a").children[0].text != "") && !(schedule.search("a").children[0].text.match? /Ticket/)
              sched.time = schedule.search("a").children[0].text
            end
          end
      end
    end
  end
  def self.clear_all
    @@all = []
  end
  def self.create_and_fill(team)
    self.load_all(team)
  end
  def initialize
    @@all << self
  end
  def self.display_schedule
    # cnt = 10
    @@all.each do |schedule|
      if schedule.week
        puts "Week: #{schedule.week}"
      end
      if schedule.day && schedule.time
        puts "   Day: #{schedule.day}  Time: #{schedule.time} "
      end
      if schedule.team && schedule.location
        puts "   Team: #{schedule.location} #{schedule.team}"
      end
      if schedule.network
        puts "   Network: #{schedule.network}"
      end
      if schedule.ticketPrice
        puts "   Ticket Price: #{schedule.ticketPrice}"
      end
      if schedule.ticketSite
        puts "   Ticket Site: #{schedule.ticketSite}"
      end
    end
  end
end
class News
  @@all = []
  attr_reader :team, :author, :note
  def self.all
    @@all
  end
  def self.load_all(team)
    self.clear_all
    doc = Nokogiri::HTML(open(team.website))
    news = doc.css(".news-feed-shortstop").css(".bloom-content")
    newsItem = nil
    news.each do |newsItem|
      nw = News.new(team, newsItem.children[1].text, newsItem.children[2].text)
    end
  end
  def self.clear_all
    all = []
  end
  def self.create_and_fill(team)
    self.load_all(team)
  end
  def initialize(team, author, note)
    @team = team
    @author = author
    @note = note
    @@all << self
  end
  def self.display_news
    cnt = 1
    all.each do |news|
      puts "#{cnt}. #{news.author}"
      puts "   #{news.note}"
      cnt = cnt + 1
    end
  end
end

class Transactions
  @@all = []
  attr_accessor :note
  attr_reader :team, :date
  def self.all
    @@all
  end
  def initialize(team, date, note)
    @team = team
    @date = date
    @note = note
    @@all << self
  end
  def self.load_all(team)
    self.clear_all
    url = "https://www.espn.com/nfl/team/transactions/_/name/#{team.abbreviation}"
    doc = Nokogiri::HTML(open(url))
    trans = doc.css(".transactions-table").css(".Table2__table__wrapper").css(".Table2__td")
    cnt = 1
    transaction = nil
    trans.each do |tran|
      cnt = cnt + 1
      if cnt%2 == 0
        transaction = Transactions.new(team, tran.search("span").children.text, "a")
      elsif (transaction != nil)
        transaction.note = tran.search("span").children.text
      end
    end
  end
  def self.clear_all
    all = []
  end
  def self.create_and_fill(team)
    self.load_all(team)
  end
  def self.display_transactions
    cnt = 1
    all.each do |transaction|
      puts "#{cnt}. #{transaction.date}"
      puts "   #{transaction.note}"
      cnt = cnt + 1
    end
  end
end

class Team
  @@all = []
  attr_accessor :name, :website, :abbreviation, :number
  attr_reader :schedule, :transactions, :news

  def initialize(name, website, abbreviation, number)
    @name = name
    @website = website
    @abbreviation = abbreviation
    @number = number
    @@all << self
  end
  def self.all
    @@all
  end
  def self.fill_teams
    doc = Nokogiri::HTML(open("https://www.espn.com/nfl/teams"))
    teams = doc.css(".mt7").css(".ContentList__Item").css(".pl3")
    cnt = 1
    teams.each do |team|
      str = "https://www.espn.com" + team.children[0].attributes["href"].value
      idx = str.index("/name/") + 6
      str = str.slice(idx..idx+2).sub("/", "")
      url = "https://www.espn.com" + team.children[0].attributes["href"].value
      Team.new(team.search("h2").children.text, url, str, cnt)
      cnt = cnt + 1
    end
  end

  def self.create_and_fill
    self.load_all
  end

  def self.team_by_index(idx)
    all[idx]
  end

  def self.clear_all
    all = []
  end

  def self.load_all
    #load all teams
    self.clear_all
    self.fill_teams
  end

  def self.display_teams
    # self.load_all
    all.each do |team|
      puts "#{team.number}. #{team.name} "
      puts "    #{team.website}"
    end
  end

  def schedule
    #lazy load
    if @schedule == nil
      @schedule = Schedule.create_and_fill(self)
    end
    @schedule
  end

  def transactions
    #lazy load
    if @transactions == nil
      @transactions = Transactions.create_and_fill(self)
    end
    @transactions
  end

  def display_transactions
    if transactions != nil
      Transactions.display_transactions
    end
  end

  def news
    #lazy load
    if @news == nil
      @news = News.create_and_fill(self)
    end
    @news
  end

  def display_news
    if news != nil
      News.display_news
    end
  end

  def display_schedule
    if schedule != nil
      Schedule.display_schedule
    end
  end
  #
end

class CLIController
  def initialize
    display_intro
  end
  def display_options(idx)
    puts "**********************************************"
    puts "1. To see the lastest transactions type 1"
    puts "2. To see the lastest news blurbs type 2"
    puts "3. To see the schedule and lowest ticket prices please type 3"
    puts "4. To see the full team list again type 4"
    puts "5. To quit type 5."
    puts "**********************************************"
    input = gets.chomp.to_i
    team = Team.team_by_index(idx)
    case input
      when 1
        #transactions
        team.display_transactions
        display_options(idx)
      when 2
#latest news
        team.display_news
        display_options(idx)
      when 3
#schedule
        team.display_schedule
        display_options(idx)
      when 4
#full schedule
        Team.display_teams
        display_options(idx)
      when 5

      else
        team.display_news
        # display_options(idx)
    end

  end
  def display_intro
    puts "Welcome.  Please select which team you want to select.  Once the team is selected you can choose what you want to see."
    Team.create_and_fill
    Team.display_teams
    idx = gets.chomp.to_i
    display_options(idx-1)
  end
end

class FreeMalaysiaService
  require 'mechanize'

  def initialize()
    @mechanize = Mechanize.new
    @mechanize.keep_alive   = true
    @base_url = "https://www.freemalaysiatoday.com"
  end

class WoodchucksController < ApplicationController

  before_filter :setup
  before_filter :apply_filter
  before_filter :format_data

  def index
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  def apply_filter
    if(@log)
      @entries = LogEntry.where(:log_id => @log.id)
    else
      @entries = LogEntry.where(:log_id => @logs.map(&:id))
    end
    if(params[:search])
      if(terms = params[:search][:terms])
        @current_terms = terms
        @entries = @entries.full_text_search(:entry, terms)
      end
    end
    @entries = @entries.order(:entry_time.desc).paginate(page, per_page)
    enable_pagination_on(@entries)
  end

  def format_data
    @logs = {}.tap do |logs|
      @logs.each do |log|
        logs[log.source] ||= []
        logs[log.source].push(log)
      end
    end
    @entries = {}.tap do |entries|
      @paged_entries = @entries.all
      @paged_entries.each do |entry|
        time = Time.at(entry.entry_time)
        date = time.strftime('%Y-%m-%d')
        entries[date] ||= []
        entries[date] << entry
      end
    end
  end

  def setup
    @logs = current_user.run_state.current_account.logs_dataset
    if(params[:id])
      @log = @logs.where(:id => params[:id]).first
    end
  end

end

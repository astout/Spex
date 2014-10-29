module ActiveRecordExtension

  extend ActiveSupport::Concern

  # add your instance methods here

  # add your static(class) methods here
  module ClassMethods

    # index will provide the standardized paginated, sortable, searchable (if defined) collection of the class 
    # for creating a list of the class  
    def index(search='', sort_column="updated_at", sort_direction="desc", page=1, per_page=10, exclude=[], select=[])
      puts "#{self.class} class index"
      # the class has a search method, search on it 
      if self.respond_to?(:search)
        if exclude.blank? && !select.blank?
          self.search(search).order(sort_column + ' ' + sort_direction).select { |item| select.any? { |in_item| in_item[:id] == item[:id] } }.paginate(page: page.blank? ? 1 : page, per_page: per_page)
        elsif select.blank?  && !exclude.blank?
          self.search(search).order(sort_column + ' ' + sort_direction).reject { |item| exclude.any? { |ex_item| ex_item[:id] == item[:id] } }.paginate(page: page.blank? ? 1 : page, per_page: per_page)
        else
          self.search(search).order(sort_column + ' ' + sort_direction).paginate(page: page.blank? ? 1 : page, per_page: per_page)
        end
      #otherwise, skip the searching
      else
        if exclude.blank? && !select.blank?
          self.all.order(sort_column + ' ' + sort_direction).select { |item| select.any? { |in_item| in_item[:id] == item[:id] } }.paginate(page: page.blank? ? 1 : page, per_page: per_page)
        elsif select.blank?  && !exclude.blank?
          self.all.order(sort_column + ' ' + sort_direction).reject { |item| exclude.any? { |ex_item| ex_item[:id] == item[:id] } }.paginate(page: page.blank? ? 1 : page, per_page: per_page)
        else
          self.all.order(sort_column + ' ' + sort_direction).paginate(page: page.blank? ? 1 : page, per_page: per_page)
        end
      end
    end

  end
end

# include the extension 
ActiveRecord::Base.send(:include, ActiveRecordExtension)
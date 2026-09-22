module Admin
  class DashboardController < Admin::BaseController
    def index
      @categories = Category.all
    end
  end
end

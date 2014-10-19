module Mammoth::Controllers::Analytics
  class Index
    include Mammoth::Action
    expose :type, :controller

    def call(params)
      @type = params[:type] || 'current_activity'
      @controller = 'analytics'
    end
  end
end

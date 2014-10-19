module Mammoth::Controllers::Analytics
  class Index
    include Mammoth::Action
    expose :type

    def call(params)
      @type = params[:type] || 'current_activity'
    end
  end
end

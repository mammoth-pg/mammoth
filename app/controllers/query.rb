module Mammoth::Controllers::Query
  class Index
    include Mammoth::Action
    expose :controller

    def call(params)
      @controller = 'query'
    end
  end

  class Do
    include Mammoth::Action

    # params do
    #   param :query
    #   param :explain, type: Boolean
    # end

    def call(params)
      @controller = 'query'
    end
  end
end

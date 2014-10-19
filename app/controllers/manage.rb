module Mammoth::Controllers::Manage
  class Index
    include Mammoth::Action
    expose :controller

    def call(params)
      @controller = 'manage'
    end
  end
end

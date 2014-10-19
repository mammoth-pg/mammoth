require './config/applications'

use Rack::Session::Cookie, secret: 'fd167930ac152f56fff387971d44dbeaef1c1c283a55b852ef1a759e343185bc3dae8c13e4f63456498d4249a74ae50a68de8227f8d4137633ec096a2b91c346'
run Mammoth::Application.new

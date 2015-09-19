require './app'
require './middlewares/stats_collector'

use ManufacturerBattle::StatsCollector
run ManufacturerBattle::App
